# Run the performance benchmark on GitHub

No local Linux installation is required. Open **Actions > ASan performance benchmark > Run workflow**, select `main`, and start the run. The workflow also starts when its YAML, benchmark C source or Python runner changes on main. Documentation-only changes do not start a performance run.

The Ubuntu 24.04 job installs GCC 13 and libasan8, then runs:

```bash
CC=gcc-13 python3 scripts/run_week3_perf.py --output-dir results/performance-ci/benchmark
```

The three conditions are native, ASan with zero quarantine, and ASan with 64 MiB quarantine. Each has one warmup plus nine measured trials. The run Summary shows means, sample standard deviations and ratios. A green performance job confirms that this runner completed and produced the four expected evidence files; it is not a detector-coverage verdict.

Download `asan-perf-<source SHA>-<run ID>-<attempt>` under Artifacts within 30 days. Contents:

| Path | Meaning |
| --- | --- |
| `benchmark/raw.csv` | 27 measured timings: nine per condition |
| `benchmark/summary.csv` | Mean, sample SD, ratio and slowdown |
| `benchmark/execution.log` | 30 executions including warmups, order, exits and output |
| `benchmark/environment.txt` | Source revision/status, hashes, flags, CPU, memory and runtime identity |
| `workflow-environment.txt` | Actions URL/attempt, runner image and installed package versions |
| `setup.log`, `runner.log` | Installation and runner console output, useful on failure |

Partial evidence is uploaded even if a step fails; missing CSVs or a failed job are not a completed benchmark. Inspect raw logs before preserving a new evidence batch. Keep the source SHA and run URL with it, and never overwrite historical Week 3 evidence.

This uses modern Ubuntu GCC 13, whereas historical Week 3 measurements used GCC 14.2. Shared hosted hardware, package versions and image contents can change. Compare conditions within a run and describe between-run differences rather than attributing them to quarantine or code alone. Peak memory is not measured; adding RSS is a separate future extension. The original SPEC CPU2006 aggregate is not reproduced by this microbenchmark.

## First successful execution

[Run 46113854580](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46113854580) completed successfully for source `69ec605f15add83115506b983d436484371b24e9`. Artifact: `asan-perf-69ec605f15add83115506b983d436484371b24e9-46113854580-1`. This verifies hosted execution and artifact publication; inspect the downloaded raw evidence before reporting its measured values.
