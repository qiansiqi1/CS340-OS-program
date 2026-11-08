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

The first CI execution of this protocol is pending. Do not replace the values below with expected output; fill them only after checking the actual run artifact.

| Measure | Observed result | Source |
| --- | --- | --- |
| Boundary violations detected | Pending / 42 | `trials.tsv`, `summary.txt`, and raw `logs/` |
| Safe controls passed | Pending / 42 | Same files |
| Source commit and Actions run | Pending | `environment.txt` and run URL |
| Verdict for this sampled subset | Pending | Derived from the checked counts |

## Comparison and limitations

The paper's detector was evaluated in 2012 with its then-current implementation. This experiment uses Ubuntu's Clang/ASan 18 and a purpose-built microprogram, not the original SPEC CPU2006 workloads or the paper's HP Z600 hardware. The paper's 73% average slowdown and Table 1 memory overhead are therefore outside this experiment. Immediate boundary writes are expected to land in poisoned redzones; the raw ASan report must confirm the classification and location. Three repetitions establish consistency for these exact inputs, not a statistical estimate of detection probability across arbitrary programs.
