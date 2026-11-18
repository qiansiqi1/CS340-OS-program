# Week 3: ASan runtime overhead and quarantine

This milestone continues Chen Yantong's allocation benchmark at
`0812304f6cfbc33897008c41aeafb1298db29575`. The benchmark allocates one
million 256-byte blocks, writes within each block, and frees each allocation.
The source is unchanged and both endpoint stores were observed in the GCC
-O2 native assembly. This experiment uses only valid memory accesses.

## Question and method

[Section 4, Figure 2 of the paper](https://www.usenix.org/system/files/conference/atc12/atc12-final39.pdf)
reports 73% average runtime slowdown (1.73x) across its SPEC CPU2006
evaluation. We test whether runtime increases on the same reduced workload
built with and without ASan. The comparison uses wall-clock elapsed time
including process startup and shutdown. This differs from reproducing the
individual SPEC workload measurements or their aggregate.

For an extension motivated by Section 4.3, we test whether changing
`quarantine_size_mb` from 0 to 64 changes the runtime of the same ASan
binary. Every other ASan option and the workload stay fixed within each
batch. Each batch contains one warmup per variant and nine measured
trials per variant. Variant order rotates so each variant occupies each
position three times. Sample standard deviations use n-1. Slowdown ratios
divide variant mean time by the native mean from the same batch.

## Table 1. Paper vs. this experiment

| Setting | Paper Figure 2 | Week 3 |
| --- | --- | --- |
| Workload | SPEC CPU2006 C/C++ benchmarks | One allocation-heavy C microbenchmark |
| Host | 64-bit Linux, HP Z600, two Xeon E5620 CPUs, 24 GB RAM | Shared x86-64 Linux container, AMD EPYC 9V74, kernel 6.18.57 |
| Compiler | Historical Clang/LLVM, -O2 | Debian GCC 14.2.0-19, -O2, libasan.so.8, non-PIE in both builds |
| ASan tuning | 32-byte redzones, allocation stack unwinding disabled, zero quarantine | Runtime-default redzones, malloc_context_size=1, leak detection off, 0 or 64 MiB quarantine |
| Zero-quarantine ratio | 1.73x across the paper's suite | 2.264x with original CPU affinity; 2.307x with one eligible logical CPU |

The settings differ because the historical toolchain, target host and
SPEC workloads were not used. GCC was available in the environment.
The zero-quarantine ratio differs from 1.73x by 0.534x (53.4 percentage
points of slowdown) in the first batch, and 0.577x (57.7 points) in the
second. These are descriptive gaps across unmatched setups. The experiment
does not isolate how much of either gap comes from workload, runtime, or
hardware. Verdict: the qualitative overhead claim is supported on this
workload. The Figure 2 aggregate remains inconclusive on the available data.

## Table 2. Measured wall time

| Batch | Native, s | ASan 0 MiB, s | ASan 64 MiB, s |
| --- | ---: | ---: | ---: |
| Original CPU affinity | 0.1151 ± 0.0171 | 0.2605 ± 0.0309 | 0.3387 ± 0.1628 |
| Single eligible logical CPU | 0.1184 ± 0.0176 | 0.2732 ± 0.0373 | 0.2576 ± 0.0077 |

Each cell is mean ± sample SD, n=9. See [Figure 1](../evidence/week3/runtime.svg).
Within the first batch, 64 MiB was 0.0782 s slower on average. In the
second batch it was 0.0156 s faster. All trials are retained, including
the first batch's 0.598 s and 0.650 s readings. The rerun restricted
CPU affinity for every condition and retained the same binary build
settings and workload. The direction reversal makes a stable runtime
effect inconclusive here. Affinity and batch time changed together, so
the data do not establish the cause of the reversal. The extension
measures runtime only and provides no estimate of memory footprint or
error-detection coverage.

## Reproduction and evidence

Run from the checkout with Linux, GCC and libasan, Python 3.9+,
Git, and ldd. GCC 14.2.0-19 and Python 3.12 were used for the saved
evidence. Allow several seconds per batch and sufficient memory for
the workload. The exact runtime binary hash, host, flags and settings
are recorded with each batch.

```bash
python3 scripts/run_week3_perf.py
# Archive results/week3 before a second run.
CPU=$(python3 -c 'import os; print(min(os.sched_getaffinity(0)))')
taskset -c "$CPU" python3 scripts/run_week3_perf.py
```

Every observation in Table 2 comes from `raw.csv` and `summary.csv` in
[evidence/week3](../evidence/week3/) or the
[single-CPU rerun](../evidence/week3/single-cpu/). `execution.log` records
exit status, trial order and timing, including warmups. Environment logs
include the starting Git commit and source/runner hashes. Figure 1 plots
individual runs and mean ± sample SD from the same CSVs. Regenerate it with
`python3 scripts/plot_week3_perf.py` using Matplotlib (3.10.8 used here).
The original experiment scripts and benchmark remain credited to their
respective authors. No upstream GCC or LLVM source was modified.

## Handoff to the fourth member

- Bring the Week 2 benchmark branch and Week 3 changes into the final
  integration branch. Main and that branch diverge in README.zh-CN.md;
  preserve both sets of progress notes when resolving it.
- Preserve actual Claim 1 artifacts before making a detection verdict.
  If SPEC or an original workload becomes available, run a matched
  comparison. Otherwise retain the scope and verdict above.
- Integrate setup, logs, discrepancies and the extension into the English
  PDF. Add the actual contribution and AI-use statements. AI assisted
  with the Week 3 runner, documentation, plot code and interpretation.
- Use Figure 1 for results. Suggested English talking point: “On our
  allocation workload, the zero-quarantine ASan build ran about 2.3 times
  as long as native. The paper's 1.73 times is a different suite. Changing
  quarantine gave opposite directions across two batches.”
- Prepare the numbered English slides or presentation PDF. The group has
  five minutes to present and two for Q&A, with all four members speaking.
  After integration and verification, tag the final repository version v1.0.
