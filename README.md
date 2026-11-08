# CS340: AddressSanitizer Replication

This repository prepares a reproducible AddressSanitizer (ASan) smoke test and a focused heap-redzone experiment for **AddressSanitizer: A Fast Address Sanity Checker**, Konstantin Serebryany, Derek Bruening, Alexander Potapenko, and Dmitry Vyukov, USENIX ATC 2012 (paper 8 in the course list).

- [Original paper](https://www.usenix.org/system/files/conference/atc12/atc12-final39.pdf)
- [Official Clang AddressSanitizer documentation](https://clang.llvm.org/docs/AddressSanitizer.html)
- [Run history and downloadable evidence](https://github.com/qiansiqi1/CS340-OS-program/actions/workflows/asan-smoke.yml)

## Scope and current status

The first milestone checks that we can build an instrumented C program, execute an in-bounds control, and obtain a symbolized ASan report for a one-byte heap-buffer overflow. This is an installation and instrumentation check, **not a reproduction of the paper's performance results or detection coverage**.

The smoke test passed in GitHub Actions for source commit `2c6e30f` (the run's raw logs still need to be preserved in this repository). A separate experiment now targets the paper's Section 3.5 claim about accesses within heap redzones, using the shadow-memory layout in Figure 1. Its protocol, result fields, and limitations are in [Claim 1](docs/claim1.md). Treat its results as verified only after the new CI job passes and its raw logs have been inspected. See [environment notes](docs/environment.md) and [evidence instructions](evidence/README.md). No uninspected output in this README is represented as a measured result.

## Setup: Ubuntu 24.04 x86-64

Use an Ubuntu machine, VM, or WSL2 Ubuntu installation. From Windows without a Linux environment, use the GitHub Actions workflow below. Installing Git Bash alone does not provide the required Linux compiler/runtime.

```bash
sudo apt-get update
sudo apt-get install --yes git clang-18 libclang-rt-18-dev llvm-18
git clone https://github.com/qiansiqi1/CS340-OS-program.git
cd CS340-OS-program
bash scripts/run_smoke.sh
```

The compiler and symbolizer defaults are `clang-18` and `llvm-symbolizer-18`. Explicit overrides are supported, for example `CC=clang-18 SYMBOLIZER=llvm-symbolizer-18 bash scripts/run_smoke.sh`. Run the command from a shell; the script locates the repository relative to itself and does not hard-code a machine's checkout path.

The workflow also runs on pushes and pull requests, and supports manual runs from **Actions > ASan smoke test > Run workflow** once it exists on the default branch. It needs no repository secrets. On each run, it installs the dependencies, executes the same script, prints logs, and uploads a text evidence artifact for 30 days.

Ubuntu and compiler major version are specified, but hosted-runner images and APT package patch versions can change. Every run records the exact kernel, compiler, runtime packages, hardware, source commit, and source checksums. This is an initial reproducibility baseline; it is not yet a fully immutable historical reproduction environment.

## Build and run

`bash scripts/run_smoke.sh` compiles with:

```bash
clang-18 -std=c11 -O1 -g -Wall -Wextra -Werror \
  -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls \
  examples/heap_bounds.c -o build/heap_bounds
```

The script runs the same instrumented binary in two modes:

| Command | Allocation and access | Required observation |
| --- | --- | --- |
| `./build/heap_bounds safe` | Allocate 8 bytes; write byte at index 7 | Exit 0; successful-write message; no ASan error |
| `./build/heap_bounds overflow` | Allocate 8 bytes; write byte at index 8 | Exit 1; `heap-buffer-overflow`; `WRITE of size 1`; source file and line |

The out-of-bounds case is deliberately invalid and is expected to terminate. The wrapper succeeds only if the safe control and all error-report checks pass. It must not be interpreted as an unexpected workflow failure simply because the overflow program itself exits nonzero.

The script fixes `ASAN_OPTIONS=detect_leaks=0:halt_on_error=1:abort_on_error=0:exitcode=1:symbolize=1` and selects the LLVM symbolizer explicitly. Leak detection is disabled to keep this milestone about address errors; no leak-detection claim is tested. Addresses, process IDs, allocation traces, and timing can differ across runs.

Expected final wrapper message (an acceptance criterion, not a measured result):

```text
PASS: safe control succeeded; ASan detected and symbolized the one-byte heap overflow.
```

The two small programs should complete within seconds after dependencies are installed. CI provisioning and package installation may take several minutes; this is a planning estimate, not a benchmark measurement.

## Outputs and evidence

The build creates `build/heap_bounds`. A run creates:

```text
results/latest/
  environment.txt  # OS/kernel, CPU/RAM, tools, source revision, and settings
  build.log        # Exact build command and compiler diagnostics
  safe.log         # Raw output of the in-bounds control
  overflow.log     # Raw ASan report
  summary.txt      # Exit statuses and verification verdict
```

These generated directories are ignored by Git. After verifying a real run, preserve the five text files in `evidence/week1/` with a provenance note linking its Actions run and source commit. See [evidence instructions](evidence/README.md). This is necessary because uploaded CI artifacts expire. Keep the raw report intact; do not replace it with an illustrative example. Do not commit binaries, credentials, disk images, or files larger than 50 MB.

The `redzone` CI job runs `bash scripts/run_redzone.sh` separately from the smoke test. It saves `results/redzone/environment.txt`, `build.log`, `summary.txt`, `trials.tsv`, and the raw `logs/` directory as an `asan-redzone-<source SHA>` artifact. The 84 trials consist of 42 valid controls and 42 immediate one-byte boundary violations, with three repetitions per allocation size and mode. See [Claim 1](docs/claim1.md) for the exact protocol and interpretation.

## Repository layout

```text
examples/heap_bounds.c         Original intentional-bug demo and safe control
scripts/run_smoke.sh           Build, run, and check both modes
examples/heap_redzone.c        Parameterized heap-boundary experiment
scripts/run_redzone.sh         Run and check repeated boundary trials
scripts/collect_environment.sh Record the environment and source identity
docs/environment.md           Observed preparation environment and deviations
docs/claim1.md                First paper claim, protocol, and result record
evidence/                     Instructions and selected real text logs
.github/workflows/            Ubuntu automated execution
```

## Next milestones

1. Inspect and preserve the Claim 1 CI evidence, then select any additional claim tied to an original figure or table with matching metrics and workloads.
2. Specify the performance baseline and benchmark procedure; record all deviations from the paper's hardware, tools, and settings.
3. Perform at least three runs for reported results, present mean and standard deviation, and trace each reported number to committed logs.
4. Compare paper and reproduced results; investigate discrepancies; add a motivated experiment that changes one factor at a time.

The current smoke test is not a performance benchmark, so it does not provide slowdown estimates, paper-versus-ours comparisons, or claim verdicts.

## Contributions and source attribution

Each member should contribute through their own GitHub account. Every commit message must contain the actual student's ID and full name, followed by a description of the work. Before the first commit, configure a verified GitHub email (or the account's GitHub-provided no-reply address). Do not publish credentials or proxy settings in the repository.

The demo, scripts, workflow, and documentation are newly authored for this course project with AI assistance; they are not copied from the paper or an upstream repository. The installed compiler/runtime come from Ubuntu's LLVM packages. Their versions are recorded per run, and their upstream project is [llvm/llvm-project](https://github.com/llvm/llvm-project), licensed under [Apache-2.0 WITH LLVM-exception](https://github.com/llvm/llvm-project/blob/main/LICENSE.TXT). No upstream compiler source is vendored or modified in this milestone. A starting upstream source commit and modified-upstream-file list are therefore not applicable yet; any later source-based work must record those details and include the required upstream license.

AI assistance was used to draft the initial documentation, demo, automation, and checks. Student review, execution evidence, individual contributions, and any later AI use must be accurately reflected in the final report. A successful smoke test demonstrates only the narrowly stated behavior above.
