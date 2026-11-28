# Claim 2: ASan runtime overhead on an allocation workload

## Status and scope

The Week 2 allocation microbenchmark and the Week 3 performance runner were integrated into main at `40e5f0f`. The detection artifacts cover a different protocol. A separate performance artifact for source `fb54e2b` has now been independently inspected and archived. This is a focused experiment on runtime overhead, not a matched replication of the paper's SPEC CPU2006 aggregate.

The original Week 2 plan used Clang 18, Ubuntu CI and five trials. It did not preserve a completed five-trial result table. Those planned settings are not the provenance of the committed Week 3 measurements.

## Inspected hosted result: 2026-11-28

Source: `fb54e2b2d2f0d6adadc62450f35853aa3e0e83fc`; [Actions run 46114837908, attempt 1](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46114837908). The archived [raw samples](../evidence/performance/46114837908-attempt1/benchmark/raw.csv), [summary](../evidence/performance/46114837908-attempt1/benchmark/summary.csv), [execution log](../evidence/performance/46114837908-attempt1/benchmark/execution.log) and [provenance](../evidence/performance/46114837908-attempt1/provenance.md) support the table below. The source checkout was clean; source hashes match the recorded commit.

| Condition | Measured n | Mean time, s | Sample SD, s | Ratio to native | Additional time |
| --- | ---: | ---: | ---: | ---: | ---: |
| Native | 9 | 0.155898 | 0.003829 | 1.000000x | 0.0000% |
| ASan, 0 MiB quarantine | 9 | 0.346331 | 0.009404 | 2.221527x | 122.1527% |
| ASan, 64 MiB quarantine | 9 | 0.353542 | 0.008939 | 2.267785x | 126.7785% |

All 30 executions (including three warmups) exited 0. The 27 measured CSV entries agree exactly with the corresponding raw log entries. Means, sample SD, ratios and slowdown percentages were independently recalculated. No samples were discarded. Timing includes process startup and shutdown; this is neither allocator-only latency nor a memory-footprint measurement.

### Actual configuration

- GitHub-hosted Ubuntu 24.04 runner, image `20261122.23.1`, x86-64 kernel `7.0.0-1020-azure`, glibc 2.39.
- AMD EPYC 9V74; four logical CPUs in the allowed affinity mask. The workflow does not bind all trials to one core.
- GCC 13.3.0 (`13.3.0-6ubuntu2~24.04.1`), Python 3.12.3. Installed ASan runtime package: `libasan8` version `14.2.0-4ubuntu2~24.04.1`; its library hash is recorded in the environment file.
- Same allocation microbenchmark: one million 256-byte blocks, valid endpoint writes, then frees. Both builds use `-O2 -g -fno-pie -no-pie`; ASan adds `-fsanitize=address`.
- ASan options: `detect_leaks=0:malloc_context_size=1:halt_on_error=1`, with `quarantine_size_mb` 0 or 64.
- One warmup and nine measured trials per condition, rotating condition order; captured at `2026-11-28T06:03:36Z`.

### Verdict and paper comparison

**Supported for this workload:** ASan increases elapsed time. The 0 MiB condition takes approximately **2.222 times** the native time (122.15% additional time); the 64 MiB condition takes approximately **2.268 times** (126.78% additional time).

**The paper's exact aggregate is not reproduced.** Its Figure 2 reports 1.73x across SPEC CPU2006. Our workload, compiler/runtime, hardware and measurement protocol differ; 2.222x versus 1.73x is a descriptive difference, not an isolated implementation effect or evidence against the paper.

For the extension, 64 MiB has a 0.007212 s larger mean than 0 MiB in this batch, about 2.08%. This is descriptive only; no significance claim is made. The historical batches below changed direction, so this new run does not establish that larger quarantine consistently increases runtime. No peak RSS, memory-overhead or detection-window claim is supported by these timing measurements.

## Historical Week 3 configuration (separate batches)

The preserved measurements use Linux x86-64, AMD EPYC 9V74, GCC 14.2.0-19 and libasan.so.8. Both native and ASan builds use `-O2 -g -fno-pie -no-pie`. The benchmark allocates one million 256-byte blocks, writes valid endpoints and frees the allocations.

Each batch contains one warmup and nine timed trials per condition, with rotating order. Timing includes process startup and shutdown. ASan conditions change `quarantine_size_mb` between 0 and 64 while keeping the other recorded options fixed.

| Batch | Native, s | ASan 0 MiB, s | ASan 64 MiB, s | 0 MiB / native |
| --- | ---: | ---: | ---: | ---: |
| Original affinity | 0.1151 ± 0.0171 | 0.2605 ± 0.0309 | 0.3387 ± 0.1628 | 2.264x |
| Single logical CPU | 0.1184 ± 0.0176 | 0.2732 ± 0.0373 | 0.2576 ± 0.0077 | 2.307x |

Values are mean ± sample SD, n=9. Source: [original batch](../evidence/week3/) and [single-CPU batch](../evidence/week3/single-cpu/). The full environment, raw CSVs, execution logs and interpretation are in [Week 3 performance](week3-performance.md).

## Interpretation of the historical batches

The paper reports 1.73x across a different SPEC CPU2006 suite. Our workload supports the qualitative overhead observation, while the paper-level aggregate remains inconclusive. The two quarantine batches changed direction, so they do not establish a stable runtime effect. Workload, toolchain, host and batch differences do not isolate a cause for the observed gaps. Memory footprint and detection coverage were not measured here.

## Run and automation

On Linux with GCC/libasan, Python 3.9+, Git and ldd:

```bash
python3 scripts/run_week3_perf.py
# Optional: choose a new output directory explicitly.
python3 scripts/run_week3_perf.py --output-dir results/performance-review
```

Default output uses a unique directory under `results/`. An explicit existing directory is rejected to protect earlier evidence. `bash scripts/run_perf.sh` is a compatibility wrapper for this runner, with the same output format and arguments.

The separate `ASan performance benchmark` workflow runs this script on Ubuntu 24.04 with GCC 13/libasan8, supports manual dispatch, and uploads `asan-perf-<source SHA>-<run ID>-<attempt>`. See [web execution and downloads](performance-actions.md). The detection workflow still runs only smoke/redzone. This new workflow is distinct from the historical GCC 14.2 measurements; shared hosted CI is not a controlled performance platform.

The historical Week 3 evidence remains unchanged. The first hosted run at `69ec605` demonstrated execution; the user-supplied [later run at `fb54e2b`](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46114837908) is the inspected batch reported above. Its seven original files are archived separately with checksums and provenance. Do not pool it with GCC 14.2 historical batches or describe a new run as a historical measurement. See [replication status](replication-status.md).
