#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
compiler="${CC:-clang-18}"
symbolizer="${SYMBOLIZER:-llvm-symbolizer-18}"
command -v "$compiler" >/dev/null || { printf 'Missing compiler: %s\n' "$compiler" >&2; exit 2; }
command -v "$symbolizer" >/dev/null || { printf 'Missing symbolizer: %s\n' "$symbolizer" >&2; exit 2; }

mkdir -p build results/redzone/logs
export CC="$compiler" SYMBOLIZER="$symbolizer"
export ASAN_SYMBOLIZER_PATH="$(command -v "$symbolizer")"
export ASAN_OPTIONS='detect_leaks=0:halt_on_error=1:abort_on_error=0:exitcode=1:symbolize=1'
bash scripts/collect_environment.sh > results/redzone/environment.txt 2>&1

flags=(-std=c11 -O1 -g -Wall -Wextra -Werror -fsanitize=address
       -fno-omit-frame-pointer -fno-optimize-sibling-calls)
{
    printf 'Command: %s ' "$compiler"
    printf '%s ' "${flags[@]}"
    printf 'examples/heap_redzone.c -o build/heap_redzone\n'
    "$compiler" "${flags[@]}" examples/heap_redzone.c -o build/heap_redzone
} > results/redzone/build.log 2>&1

printf 'size\trepetition\tmode\texit_status\tverdict\tlog\n' > results/redzone/trials.tsv
passed=0
failed=0
for size in 1 7 8 9 16 31 64; do
    for repetition in 1 2 3; do
        for mode in left right underflow overflow; do
            log="logs/${size}-${repetition}-${mode}.log"
            set +e
            ./build/heap_redzone "$size" "$mode" > "results/redzone/$log" 2>&1
            status=$?
            set -e
            verdict=FAIL
            if [[ "$mode" == left || "$mode" == right ]]; then
                if [[ "$status" -eq 0 ]] &&
                   grep -Fq "Completed $mode write (allocation: $size bytes)" "results/redzone/$log" &&
                   ! grep -Fq 'ERROR: AddressSanitizer:' "results/redzone/$log"; then
                    verdict=PASS
                fi
            elif [[ "$status" -eq 1 ]] &&
                 grep -Fq 'ERROR: AddressSanitizer: heap-buffer-overflow' "results/redzone/$log" &&
                 grep -Fq 'WRITE of size 1' "results/redzone/$log" &&
                 grep -Fq 'examples/heap_redzone.c:' "results/redzone/$log" &&
                 ! grep -Fq 'Completed' "results/redzone/$log"; then
                verdict=PASS
            fi
            printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$size" "$repetition" "$mode" "$status" "$verdict" "$log" >> results/redzone/trials.tsv
            if [[ "$verdict" == PASS ]]; then
                ((passed+=1))
            else
                ((failed+=1))
            fi
        done
    done
done

{
    printf 'Paper claim: Section 3.5, out-of-bounds accesses within heap redzones are detected.\n'
    printf 'Scope: one-byte writes immediately before or after 1, 7, 8, 9, 16, 31, and 64-byte allocations.\n'
    printf 'Repetitions per size/mode: 3\n'
    printf 'Passed trials: %s / 84\n' "$passed"
    printf 'Failed trials: %s\n' "$failed"
    printf 'Expected controls: 42; expected boundary violations: 42\n'
    if [[ "$failed" -eq 0 ]]; then
        printf 'PASS: all safe controls and immediate heap boundary violations behaved as expected.\n'
    else
        printf 'FAIL: inspect trials.tsv and the corresponding raw logs.\n'
    fi
} | tee results/redzone/summary.txt
[[ "$failed" -eq 0 ]]
