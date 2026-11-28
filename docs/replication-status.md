# Replication status and remaining work

Updated 2026-11-28 after inspection of artifacts for `40e5f0f`.

## Current scope

| Paper connection | Completed evidence | Conclusion and limit |
| --- | --- | --- |
| Instrumentation and reporting | Smoke safe/overflow pair, source hashes, symbolized report | Setup works for modern Clang/ASan 18; not paper-wide coverage |
| Section 3.5 heap redzones | Seven allocation sizes, four modes, three repeats; all raw logs checked | 42/42 sampled immediate single-byte boundary writes detected, 42/42 controls passed; focused support |
| Section 4 / Figure 2 overhead | Two historical batches; nine trials per condition, raw CSVs and mean/sample SD | About 2.3x zero-quarantine runtime on one allocation workload; not the original SPEC suite, historical host or compiler |
| Section 4.3 motivated quarantine extension | 0/64 MiB comparison in each batch | Runtime effect inconclusive: direction reverses; affinity and batch time changed together |
| Table 1 memory overhead | Not measured | No memory-overhead conclusion |

This is a focused partial reproduction using a modern installed implementation and a related microbenchmark extension. It does not recreate the complete 2012 evaluation or reimplement ASan. No GCC/LLVM source modifications are claimed. A numerical completion percentage would obscure these scope differences.

## Remaining checks, in priority order

1. The revised runner completed [its first hosted Linux execution](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46113854580) at `69ec605`; inspect the new artifact before updating measured claims. Archive a new batch's environment, raw CSV, summary and execution log; inspect all exits and sample counts. Detection CI does not run this script; the separate [performance workflow](performance-actions.md) now supplies a hosted execution path. Its results must still be inspected before updating measured claims. Preserve historical evidence unchanged, and label Clang detection versus GCC performance separately.
2. Synchronize final English report and slides with measured counts, source SHA and Actions URL; include paper-versus-ours settings, timing mean/sample SD, scope limits, actual member contributions and AI use. Claim 1's 100% describes only these 42 sampled violations. Check final course deliverables separately against the original assignment document.
3. Correct protocol metadata in the environment collector for future runs: its fixed eight-byte allocation sentence belongs to smoke, not redzone. Keep archived bytes unchanged; existing TSVs and logs establish the true redzone workload.
4. Tighten reproducibility where practical with pinned environment dependencies. Hosted images/packages move, and these logs record rather than freeze them.
5. If course requirements specifically demand original workloads or upstream source changes, the current installed-package microbenchmark does not satisfy those requirements by itself. Obtain permitted workloads and document historical toolchain compatibility, or explicitly agree a reduced scope. Do not relabel the substitute as SPEC.

## Most useful additional experiment: memory versus quarantine

Measure native, ASan 0 MiB and ASan 64 MiB on one controlled Linux host with the same workload, compiler flags and CPU affinity. Change only quarantine within the ASan comparison. Record elapsed time and peak RSS (for example `/usr/bin/time -v`, maximum resident set size in KiB). Use warmups and at least nine measured trials per condition, rotate condition order within repeated blocks, and preserve every raw sample. Report means, sample SD and ratios.

Peak RSS includes allocator/runtime effects; this remains a microbenchmark rather than the paper's SPEC memory aggregate. Inspect how many allocations remain live concurrently before predicting a large quarantine effect. Keep affinity fixed; study it in separate repeated blocks if needed. A reversal between two batches does not establish causation.

## Optional detection extension

Use a separate protocol for reads/writes, wider or unaligned accesses and selected deeper redzone offsets. Include valid controls and verify that the tested address really lies in a poisoned redzone; arbitrary far offsets may land elsewhere. Change one factor at a time. Stack/global errors and use-after-free are separate experiments, not additions to the existing 42-case denominator.

A quarantine/use-after-free experiment must record address reuse and detection outcomes: disabling quarantine does not guarantee immediate reuse or deterministic missed detection. Do not infer coverage from runtime alone.

First validate a fresh performance batch, then add peak RSS to strengthen the extension. Broaden detection if time permits. Additional passing smoke runs add less evidence than a missing metric or a controlled comparison.
