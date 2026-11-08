#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
compiler="${CC:-clang-18}"
symbolizer="${SYMBOLIZER:-llvm-symbolizer-18}"

printf 'Captured at (UTC): '
date -u '+%Y-%m-%dT%H:%M:%SZ'
printf '\n=== Source ===\n'
git rev-parse HEAD
git status --short
sha256sum examples/heap_bounds.c examples/heap_redzone.c \
    scripts/collect_environment.sh scripts/run_smoke.sh scripts/run_redzone.sh
printf '\n=== Operating system ===\n'
cat /etc/os-release
uname -srvmo
printf '\n=== CPU ===\n'
LC_ALL=C lscpu | grep -E '^(Architecture|CPU\(s\)|On-line CPU|Model name|Thread|Core|Socket|Hypervisor|Virtualization)'
printf '\n=== Memory (bytes) ===\n'
free --bytes
printf '\n=== Compiler ===\n'
"$compiler" --version
printf '\n=== Symbolizer ===\n'
"$symbolizer" --version
printf '\n=== Build and run tools ===\n'
bash --version | head -n 1
git --version
printf '\n=== Installed compiler/runtime packages ===\n'
if command -v dpkg-query >/dev/null 2>&1; then
    dpkg-query -W -f='${binary:Package}\t${Version}\n' \
        clang-18 libclang-rt-18-dev llvm-18 libc6
else
    printf 'dpkg-query unavailable (non-Debian environment)\n'
fi
printf '\n=== Experiment settings ===\n'
printf 'CC=%s\nSYMBOLIZER=%s\n' "$compiler" "$symbolizer"
printf 'CFLAGS=-std=c11 -O1 -g -Wall -Wextra -Werror -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls\n'
printf 'ASAN_OPTIONS=%s\n' "${ASAN_OPTIONS:-unset}"
printf 'ASAN_SYMBOLIZER_PATH=%s\n' "${ASAN_SYMBOLIZER_PATH:-unset}"
printf 'Allocation: 8 bytes; safe write: index 7; overflow write: index 8\n'
