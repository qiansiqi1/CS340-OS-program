# CS340: AddressSanitizer Replication

[简体中文版](README.zh-CN.md)

This repository prepares a reproducible AddressSanitizer (ASan) smoke test and a focused heap-redzone experiment for **AddressSanitizer: A Fast Address Sanity Checker**, Konstantin Serebryany, Derek Bruening, Alexander Potapenko, and Dmitry Vyukov, USENIX ATC 2012 (paper 8 in the course list).

- [Original paper](https://www.usenix.org/system/files/conference/atc12/atc12-final39.pdf)
- [Official Clang AddressSanitizer documentation](https://clang.llvm.org/docs/AddressSanitizer.html)
- [Run history and downloadable evidence](https://github.com/qiansiqi1/CS340-OS-program/actions/workflows/asan-smoke.yml)

## Scope and current status

The first milestone checks that we can build an instrumented C program, execute an in-bounds control, and obtain a symbolized ASan report for a one-byte heap-buffer overflow. This is an installation and instrumentation check, **not a reproduction of the paper's performance results or detection coverage**.

For source commit `40e5f0f`, [Actions #26](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46110961155) passed. The downloaded artifacts have been inspected and archived unchanged: all 42 immediate one-byte heap-boundary violations were detected and all 42 safe controls passed. [Claim 1](docs/claim1.md) records per-size results, actual environments and limits. See [smoke evidence](evidence/week1/), [redzone evidence](evidence/claim1/) and [replication status](docs/replication-status.md). [Claim 2](docs/claim2.md) preserves historical performance data; the integrated runner completed its [first hosted performance run](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46113854580); the subsequent [run at `fb54e2b`](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46114837908) has now been inspected and archived. [Claim 2](docs/claim2.md) records 2.222x / 2.268x native elapsed time for the 0 / 64 MiB conditions (nine trials each).

## Run in your browser: no Linux installation needed

For a detailed Chinese walkthrough, including missing-button troubleshooting and how to read every output file, see [第一次运行：Windows 用户也能直接操作](README.zh-CN.md#第一次运行windows-用户也能直接操作).

GitHub Actions runs the programs on a hosted Ubuntu machine. Your own Windows computer only needs a browser. Sign in with an account that has write access to this repository. Read-only visitors can inspect public runs; to start their own run, they need access or a fork with Actions enabled.

### 1. Choose the experiment

| Goal | Workflow to select in Actions | Artifacts to download |
| --- | --- | --- |
| Check memory-error detection | [ASan smoke test](https://github.com/qiansiqi1/CS340-OS-program/actions/workflows/asan-smoke.yml) | `asan-smoke-…` and `asan-redzone-…` |
| Measure runtime overhead | [ASan performance benchmark](https://github.com/qiansiqi1/CS340-OS-program/actions/workflows/asan-performance.yml) | `asan-perf-…` |

Run both workflows to check both parts. A successful detection run does not execute the performance benchmark. One performance run already includes one warmup and nine measured trials per condition; you do not need to click the button nine times.

### 2. Start the run

1. Open the repository's **Actions** tab, then select one workflow in the left sidebar, or follow a workflow link above.
2. Make sure you see a list of runs. If you see `.yml` source code with line numbers, you are still in **Code**: click **View runs** in the top right or use the **Actions** tab.
3. Above the run list, click **Run workflow ▾**. Select branch **main**, then click the green **Run workflow** button inside that menu.
4. Wait briefly, refresh the page, and open the new run entry. Installation and queueing can take several minutes; avoid launching duplicates while waiting.
5. Yellow means queued/running, green means success, and red means failure. Detection requires both `smoke` and `redzone` to succeed; performance requires `performance` to succeed. Open a failed job and expand its failed step for diagnostics.

The detection examples intentionally access invalid memory. `heap-buffer-overflow`, `ABORTING`, and exit code 1 in an individual violation log are expected. Use the overall job status and `summary.txt` to judge the experiment, not the presence of the word ERROR alone.

### 3. Download the data

Open that individual run's **Summary**, scroll down to **Artifacts**, and click its artifact name to download a ZIP. In Windows, right-click the ZIP and choose **Extract All**. Download both artifacts for detection, or the single artifact for performance. Artifacts expire after **30 days**; downloading normally requires signing in.

For example, the supplied `asan-perf-fb54e2b…-46114837908-1.zip` belongs to [run 46114837908](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46114837908). The name identifies the source SHA, run ID and attempt. Downloaded files do not automatically become repository evidence: preserve a separate batch and its provenance as described in [evidence instructions](evidence/README.md).

### 4. Read the outputs

For detection, open each artifact's `summary.txt` first. Smoke includes `safe.log` and `overflow.log`; redzone includes `trials.tsv` and 84 individual files in `logs/`. A fully passing redzone protocol has 42 safe controls and 42 detected violations, not 84 violations. Each artifact's `environment.txt` records its own source and host.

The performance ZIP has these seven files (confirmed against the supplied artifact):

| File | What to use it for |
| --- | --- |
| `benchmark/summary.csv` | Mean time, sample SD, ratio and slowdown; open in Excel |
| `benchmark/raw.csv` | 27 measured samples: nine per condition |
| `benchmark/execution.log` | All 30 executions, including warmups, order, exit statuses and output |
| `benchmark/environment.txt` | Source/status, hashes, flags, CPU and compiler/runtime identity |
| `workflow-environment.txt` | Run URL/attempt, image and installed package versions |
| `runner.log` | Runner console output |
| `setup.log` | Dependency installation output |

In `summary.csv`, `native` means no ASan; `asan_q0` and `asan_q64` use ASan with 0/64 MiB quarantine. `n` is the measured sample count. `mean_seconds` is average elapsed seconds; `sample_sd_seconds` describes variability. `ratio_to_native=2.2` means 2.2 times the native elapsed time, corresponding to `slowdown_pct=120`, not 220 percent additional time.

Use Notepad for TXT/log files, Excel for CSV, and tab-separated import for TSV. Keep untouched originals and analyze copies. Shared hosted hardware can vary, so compare conditions within a batch and label different environments. This is a runtime microbenchmark; peak RSS and the original SPEC aggregate are not measured.

### Troubleshooting

- **No Run workflow button:** leave the Code view, select the specific workflow under Actions, and check sign-in/write access and the workflow on main.
- **No Artifacts:** open one run's Summary, wait for completion and scroll down. Old artifacts may have expired.
- **An artifact exists but the job failed:** partial logs are uploaded on failure; inspect them before reporting results. A ZIP alone does not establish success.
- **No automatic performance run after editing docs:** expected; use manual dispatch. Only relevant source/workflow changes trigger it automatically.
- **No compiler on Windows:** use the browser path above. The commands below require an Ubuntu shell, not ordinary Windows PowerShell.

## Optional: run locally on Ubuntu 24.04 x86-64

Use an Ubuntu machine, VM, or WSL2 Ubuntu installation. From Windows without a Linux environment, use the GitHub Actions workflow below. Installing Git Bash alone does not provide the required Linux compiler/runtime.

```bash
sudo apt-get update
sudo apt-get install --yes git clang-18 libclang-rt-18-dev llvm-18 gcc-13 libasan8 python3
git clone https://github.com/qiansiqi1/CS340-OS-program.git
cd CS340-OS-program
bash scripts/run_smoke.sh
bash scripts/run_redzone.sh
CC=gcc-13 python3 scripts/run_week3_perf.py
```

Clone only once. If you already have a checkout, enter it and select/update the intended version after saving your own work. Run commands at the repository root containing `scripts/`, `examples/` and `perf_bench/`. Smoke writes `results/latest/`; redzone writes `results/redzone/`; performance prints its new `results/week3-…/` directory. Generated local results are not uploaded automatically.

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

1. Claim 1 evidence is inspected and archived. Define a separate protocol and evidence batch for any broader detection experiment.
2. Run the integrated performance runner on Linux and archive a fresh batch; the historical workload and modern GCC setup differ from the paper.
3. Preserve mean and sample SD from the nine measured trials per Week 3 condition, and trace every reported number to the committed CSVs and logs.
4. Retain the limits of the quarantine extension: the two batches changed direction, and affinity and batch time changed together.

The current smoke test is not a performance benchmark, so it does not provide slowdown estimates, paper-versus-ours comparisons, or claim verdicts.

## Contributions and source attribution

Each member should contribute through their own GitHub account. Every commit message must contain the actual student's ID and full name, followed by a description of the work. Before the first commit, configure a verified GitHub email (or the account's GitHub-provided no-reply address). Do not publish credentials or proxy settings in the repository.

The demo, scripts, workflow, and documentation are newly authored for this course project with AI assistance; they are not copied from the paper or an upstream repository. The installed compiler/runtime come from Ubuntu's LLVM packages. Their versions are recorded per run, and their upstream project is [llvm/llvm-project](https://github.com/llvm/llvm-project), licensed under [Apache-2.0 WITH LLVM-exception](https://github.com/llvm/llvm-project/blob/main/LICENSE.TXT). No upstream compiler source is vendored or modified in this milestone. A starting upstream source commit and modified-upstream-file list are therefore not applicable yet; any later source-based work must record those details and include the required upstream license.

AI assistance was used to draft the initial documentation, demo, automation, and checks. Student review, execution evidence, individual contributions, and any later AI use must be accurately reflected in the final report. A successful smoke test demonstrates only the narrowly stated behavior above.

## Week 3 performance results

Run `python3 scripts/run_week3_perf.py` with Linux, GCC/libasan, Python
3.9+, Git and ldd. The runner builds the Week 2 allocation benchmark
and writes timings, tool information, raw process logs and statistics
to a unique `results/week3-<UTC timestamp>-<random suffix>/` directory.
Use `--output-dir results/new-batch` to select a new directory explicitly.
Existing explicit output directories are rejected to preserve evidence. The two measured batches and a visual comparison
are documented in [Week 3 performance and quarantine](docs/week3-performance.md).
On the measured host, allow roughly 10 seconds per batch. Use the
preserved evidence for reported numbers.


The detection workflow runs `smoke` and `redzone`. The separate
[ASan performance benchmark workflow](.github/workflows/asan-performance.yml)
runs the performance script with GCC 13 on Ubuntu and uploads CSVs and logs.
See [web execution and downloads](docs/performance-actions.md). The old `bash scripts/run_perf.sh` command
now forwards to the Week 3 Python runner and produces the same CSV format.
The saved historical evidence is unchanged. Fresh runs record working-tree
status and current source hashes; do not label a dirty integration run as
one of the preserved historical measurements.
