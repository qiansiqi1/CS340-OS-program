# Claim 2: ASan runtime overhead on an allocation workload

## Status and scope

The Week 2 allocation microbenchmark and the Week 3 performance runner were integrated into main at `40e5f0f`. The inspected detection artifacts do not execute or validate this performance runner. This is a focused experiment on runtime overhead, not a matched replication of the paper's SPEC CPU2006 aggregate.

The original Week 2 plan used Clang 18, Ubuntu CI and five trials. It did not preserve a completed five-trial result table. Those planned settings are not the provenance of the committed Week 3 measurements.

## Measured configuration

The preserved measurements use Linux x86-64, AMD EPYC 9V74, GCC 14.2.0-19 and libasan.so.8. Both native and ASan builds use `-O2 -g -fno-pie -no-pie`. The benchmark allocates one million 256-byte blocks, writes valid endpoints and frees the allocations.

Each batch contains one warmup and nine timed trials per condition, with rotating order. Timing includes process startup and shutdown. ASan conditions change `quarantine_size_mb` between 0 and 64 while keeping the other recorded options fixed.

| Batch | Native, s | ASan 0 MiB, s | ASan 64 MiB, s | 0 MiB / native |
| --- | ---: | ---: | ---: | ---: |
| Original affinity | 0.1151 ± 0.0171 | 0.2605 ± 0.0309 | 0.3387 ± 0.1628 | 2.264x |
| Single logical CPU | 0.1184 ± 0.0176 | 0.2732 ± 0.0373 | 0.2576 ± 0.0077 | 2.307x |

Values are mean ± sample SD, n=9. Source: [original batch](../evidence/week3/) and [single-CPU batch](../evidence/week3/single-cpu/). The full environment, raw CSVs, execution logs and interpretation are in [Week 3 performance](week3-performance.md).

## Interpretation

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

The committed Week 3 evidence remains historical and unchanged. The revised runner still needs a fresh Linux execution after integration. Record the actual source commit, working-tree state and hashes, and preserve outputs in a new batch. Do not present a new run as a historical measurement. See [replication status](replication-status.md).
