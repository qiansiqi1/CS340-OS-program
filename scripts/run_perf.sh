#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
printf 'Compatibility entry: using the Week 3 runner (nine trials, CSV output).\n' >&2
exec python3 "$repo_root/scripts/run_week3_perf.py" "$@"
