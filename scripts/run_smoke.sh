#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
compiler="${CC:-clang-18}"
symbolizer="${SYMBOLIZER:-llvm-symbolizer-18}"
command -v "$compiler" >/dev/null || { printf 'Missing compiler: %s\n' "$compiler" >&2; exit 2; }
command -v "$symbolizer" >/dev/null || { printf 'Missing symbolizer: %s\n' "$symbolizer" >&2; exit 2; }

mkdir -p build results/latest
export CC="$compiler" SYMBOLIZER="$symbolizer"
export ASAN_SYMBOLIZER_PATH="$(command -v "$symbolizer")"
export ASAN_OPTIONS='detect_leaks=0:halt_on_error=1:abort_on_error=0:exitcode=1:symbolize=1'
bash scripts/collect_environment.sh > results/latest/environment.txt 2>&1

flags=(-std=c11 -O1 -g -Wall -Wextra -Werror -fsanitize=address
       -fno-omit-frame-pointer -fno-optimize-sibling-calls)
{
    printf 'Command: %s ' "$compiler"
    printf '%s ' "${flags[@]}"
    printf 'examples/heap_bounds.c -o build/heap_bounds\n'
    "$compiler" "${flags[@]}" examples/heap_bounds.c -o build/heap_bounds
} > results/latest/build.log 2>&1

# Capture both exit statuses: an ASan failure is the expected overflow result.
set +e
./build/heap_bounds safe > results/latest/safe.log 2>&1
safe_status=$?
./build/heap_bounds overflow > results/latest/overflow.log 2>&1
overflow_status=$?
set -e

{
    printf 'safe exit status: %s\n' "$safe_status"
    printf 'overflow exit status: %s\n' "$overflow_status"
} > results/latest/summary.txt

fail() {
    printf 'FAIL: %s\n' "$1" | tee -a results/latest/summary.txt >&2
    exit 1
}
[[ "$safe_status" -eq 0 ]] || fail 'safe control did not exit successfully'
grep -Fq 'Completed write at index 7 (allocation: 8 bytes)' results/latest/safe.log || fail 'safe control output missing'
if grep -Fq 'ERROR: AddressSanitizer:' results/latest/safe.log; then
    fail 'unexpected sanitizer report in safe control'
fi
[[ "$overflow_status" -eq 1 ]] || fail 'overflow did not exit with the configured ASan status'
grep -Fq 'ERROR: AddressSanitizer: heap-buffer-overflow' results/latest/overflow.log || fail 'expected ASan error missing'
grep -Eq 'WRITE of size 1' results/latest/overflow.log || fail 'expected one-byte write report missing'
grep -Fq 'examples/heap_bounds.c:' results/latest/overflow.log || fail 'symbolized source location missing'
if grep -Fq 'Completed write' results/latest/overflow.log; then
    fail 'overflow continued past the invalid write'
fi
printf 'PASS: safe control succeeded; ASan detected and symbolized the one-byte heap overflow.\n' | tee -a results/latest/summary.txt
printf 'Evidence: results/latest/{environment.txt,build.log,safe.log,overflow.log,summary.txt}\n'
