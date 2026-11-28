# Claim 1: immediate heap-boundary detection

## Paper claim and scope

Serebryany et al., *AddressSanitizer: A Fast Address Sanity Checker* (USENIX ATC 2012), Section 3.5, state that out-of-bounds accesses within a heap redzone are detected with 100% probability. Figure 1 and Sections 3.1-3.3 explain the shadow mapping, poisoned redzones, and access checks behind this claim. [Original paper](https://www.usenix.org/system/files/conference/atc12/atc12-final39.pdf).

This experiment checks a narrow, deterministic subset: one-byte writes immediately before and immediately after small heap allocations. It does not test every address in a redzone, every access width, use-after-free, or the paper's SPEC CPU2006 performance results. A 42/42 result supports the claim for these sampled cases; it is not proof of universal 100% detection.

## Protocol

- Platform: GitHub-hosted Ubuntu 24.04 x86-64; actual kernel, CPU, memory, package versions, and source identity are captured in `environment.txt`.
- Compiler: Clang 18, C11, `-O1 -g -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls`, plus strict warnings. ASan's LLVM symbolizer is selected explicitly.
- Runtime: `detect_leaks=0:halt_on_error=1:abort_on_error=0:exitcode=1:symbolize=1`.
- Workload: allocate 1, 7, 8, 9, 16, 31, or 64 bytes. In separate processes, write one byte at index 0 (left control), `size-1` (right control), -1 (underflow), or `size` (overflow). Repeat each size/mode pair three times.
- Primary metric: detected boundary violations / attempted boundary violations (42 total). Secondary metric: correct safe controls / attempted safe controls (42 total). These are counts, not performance measurements; mean and standard deviation do not describe timing here.
- Acceptance: each violation exits with the configured ASan status 1, reports `heap-buffer-overflow` and `WRITE of size 1`, includes the source location, and stops before the completion message. Each control exits 0 with its completion message and no ASan error.

Run locally on the specified Ubuntu environment with `bash scripts/run_redzone.sh`, or use the `redzone` job in the Actions workflow. `trials.tsv` indexes one raw log per trial. The script exits nonzero if any trial fails.

## Result record

The artifacts for [Actions #26](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46110961155), source `40e5f0fd5a139f405e6fa6f4e14c96393c558adf`, were inspected on 2026-11-28 against all 84 raw trial logs. Their five source/script hashes match that commit. See [redzone provenance](../evidence/claim1/provenance.md) and [smoke provenance](../evidence/week1/provenance.md).

| Measure | Observed result | Source |
| --- | --- | --- |
| Boundary violations detected | **42/42 (100% of sampled violations)** | [trials.tsv](../evidence/claim1/trials.tsv), [raw logs](../evidence/claim1/logs/) |
| Safe controls passed | **42/42; no ASan error observed** | Same TSV and logs |
| All protocol checks | **84/84; 0 failed** | [summary.txt](../evidence/claim1/summary.txt) |
| Source commit | `40e5f0fd5a139f405e6fa6f4e14c96393c558adf` | [environment.txt](../evidence/claim1/environment.txt) |
| Actions run | [ASan smoke test #26](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46110961155); public run status: success | Run listing and artifact source identity |
| Verdict for this sampled subset | **Supported** | Independent counts and raw-log inspection |

| Allocation, bytes | Safe controls passed | Underflows detected | Overflows detected |
| ---: | ---: | ---: | ---: |
| 1 | 6/6 | 3/3 | 3/3 |
| 7 | 6/6 | 3/3 | 3/3 |
| 8 | 6/6 | 3/3 | 3/3 |
| 9 | 6/6 | 3/3 | 3/3 |
| 16 | 6/6 | 3/3 | 3/3 |
| 31 | 6/6 | 3/3 | 3/3 |
| 64 | 6/6 | 3/3 | 3/3 |
| **Total** | **42/42** | **21/21** | **21/21** |

The separate smoke control exited 0; its overflow exited 1 with `heap-buffer-overflow`, `WRITE of size 1`, an allocation trace, shadow bytes and source location `examples/heap_bounds.c:22:19`. See the [raw report](../evidence/week1/overflow.log). These two setup cases are not counted in the 84 redzone trials.

## Actual environment and evidence caveat

Both jobs recorded Ubuntu 24.04.5 LTS x86-64, Clang/LLVM 18.1.3, `libclang-rt-18-dev` package `1:18.1.3-1ubuntu1` and glibc `2.39-0ubuntu8.12`.

- Redzone: Intel Xeon 6975P-C, four visible logical CPUs, kernel `7.0.0-1018-aws`; environment capture `2026-11-28T05:11:53Z`.
- Smoke: AMD EPYC 9V74, four visible logical CPUs, kernel `7.0.0-1020-azure`; environment capture `2026-11-28T05:11:42Z`.

These are separate hosted machines; do not pool their timings. The collector's fixed eight-byte allocation sentence describes the smoke demo only. Redzone's actual seven sizes and modes are established by its TSV and raw logs. The original metadata is preserved unchanged with this caveat.

## Comparison and limitations

The paper's detector was evaluated in 2012 with its then-current implementation. This experiment uses Ubuntu's Clang/ASan 18 and a purpose-built microprogram, not the original SPEC CPU2006 workloads or the paper's HP Z600 hardware. The paper's 73% average slowdown and Table 1 memory overhead are therefore outside this experiment. Immediate boundary writes are expected to land in poisoned redzones; the raw ASan report must confirm the classification and location. Three repetitions establish consistency for these exact inputs, not a statistical estimate of detection probability across arbitrary programs.

No ASan error was observed among these 42 controls; this does not establish a general false-positive rate. Wider/unaligned accesses, reads, deeper redzone offsets, stack/global errors and use-after-free remain untested here. See [replication status and remaining work](replication-status.md).
