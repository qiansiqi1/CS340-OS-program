# Environment record: Week 1

## Observed preparation machine (not an experiment run)

Recorded on 2026-11-08, Asia/Shanghai, using local system information:

| Item | Observation |
| --- | --- |
| OS | Windows NT 10.0, build 26200, update build revision 9711; registry DisplayVersion 25H2 |
| Architecture | x86-64 |
| CPU | 12th Gen Intel Core i9-12900H |
| Logical processors visible to this session | 20 |
| RAM | Not measured: the session could not access the system-memory inventory |
| Git Bash | GNU Bash 5.3.9, x86_64-pc-cygwin |
| Clang/GCC/Docker | Not found on PATH or the inspected common compiler-install paths |
| WSL | The WSL launcher reported that the Windows Subsystem for Linux is not installed |
| Experiment status on this host | No ASan execution; do not attribute Linux results to this machine |

The Windows registry's legacy ProductName string is not used to infer an OS edition; the version/build identifiers above are the observed values. Some hardware inventory calls were unavailable, so missing values are explicitly marked rather than guessed.

## Execution environment selected for the smoke test

| Item | Planned setting |
| --- | --- |
| System | GitHub-hosted `ubuntu-24.04` x86-64 runner, or a comparable local Ubuntu 24.04 environment |
| Compiler | `clang-18` from Ubuntu packages; exact patch version recorded at execution |
| ASan runtime | `libclang-rt-18-dev`; exact package version recorded at execution |
| Symbolizer | `llvm-symbolizer-18` from `llvm-18` |
| Kernel, CPU, memory | Measured by `scripts/collect_environment.sh` on each actual run |
| Build settings | C11, `-O1 -g -Wall -Wextra -Werror -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls` |
| Runtime settings | `detect_leaks=0:halt_on_error=1:abort_on_error=0:exitcode=1:symbolize=1` |
| Input | Same original C program: `safe` writes index 7; `overflow` writes index 8; allocation is 8 bytes |
| Current measured results | Pending execution and inspection of the first CI run |

Do not interpret the planned settings as measurements. `environment.txt` in a real run is the authoritative record. Its captured UTC timestamp, source commit, script hashes, compiler output, package versions, and hardware identify that run. The workflow does not pin the moving hosted image or all package patch versions.

## Deviations from the paper

The first focused claim and its deviations are documented in [Claim 1](claim1.md). The table below describes the original smoke-test milestone.

This milestone has not attempted to reconstruct the paper's original evaluation environment. Original values must be extracted from the paper when the team selects its experimental claims; unverified numbers are intentionally omitted here.

| Item | Paper setting | Week 1 setting | Reason / consequence |
| --- | --- | --- | --- |
| Compiler/runtime | Original 2012 evaluation; exact revision not yet transcribed | Modern Ubuntu Clang/ASan 18 | Accessible initial tooling; historical equivalence is not claimed |
| Hardware and OS | Original evaluation details not yet transcribed | Hosted Ubuntu runner; exact details captured per run | Avoid installing a Linux VM on the preparation machine; shared CI is not a controlled performance platform |
| Workload | Original evaluation benchmarks not yet selected | One 8-byte C allocation with safe and one-byte-out-of-bounds writes | Checks setup and reporting only; does not reproduce benchmark results |
| Metrics and repetitions | To be selected from a paper figure/table | Exit statuses and diagnostic content from one smoke-test execution | No performance or statistical claim; later reported experimental results need at least three runs |
| Extension | Not selected | None in Week 1 | Define after establishing the main reproduction experiment |

## Reproducibility limitations

The initial baseline fixes the OS release, compiler major version, flags, and workload, and records exact observed versions. A later milestone should lock the chosen benchmark environment more tightly (for example, immutable image/package versions) and record the actual paper setup. Keep performance comparisons on the same controlled host and workload. Never infer paper-level results from this smoke test.
