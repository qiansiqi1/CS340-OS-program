# Provenance: hosted performance batch

- Source commit: `fb54e2b2d2f0d6adadc62450f35853aa3e0e83fc`; recorded working-tree status is empty and merge head is `none`.
- Run: [46114837908, attempt 1](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46114837908).
- Artifact: `asan-perf-fb54e2b2d2f0d6adadc62450f35853aa3e0e83fc-46114837908-1`; supplied by the user as the downloaded ZIP.
- ZIP SHA-256: `1154dfa9e67ae64574864b3a9cb3a81338d03468936b714efc0c1bdd94d3ebe2`.
- Environment capture: `2026-11-28T06:03:36Z` (2026-11-28 14:03:36 Asia/Shanghai). Exact download time was not recorded.
- Inspected and archived on 2026-11-28 (Asia/Shanghai).
- Command: `CC=gcc-13 python3 scripts/run_week3_perf.py --output-dir results/performance-ci/benchmark`.
- All seven original files are copied byte-for-byte, including line endings. `SHA256SUMS` covers those original members; this note and manifest are new documentation. The ZIP itself is not committed.
- The benchmark and runner SHA-256 values match Git blobs at the recorded source commit.
- All 30 logged executions exit 0: one warmup and nine measured trials per condition. Trial/variant combinations and rotating positions match the protocol. All 27 CSV rows match the measured log entries exactly.
- Means, sample SD (n-1), ratios to the native mean and slowdown percentages were independently recalculated and agree with the summary within its rounding precision. Warmups are excluded from the CSV and statistics.
- This new batch is separate from historical GCC 14.2 evidence. Compiler is GCC 13.3.0; the installed `libasan8` package version is `14.2.0-4ubuntu2~24.04.1`. Record the compiler and runtime independently; do not label both GCC 13.
- Shared GitHub hardware, changing images/packages and short process timings limit generalization. No peak RSS, detection coverage or original SPEC aggregate is measured.
- Evidence documentation is committed after the source run; any later CI run has separate provenance.
