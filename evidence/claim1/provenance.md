# Provenance: redzone

- Source commit: `40e5f0fd5a139f405e6fa6f4e14c96393c558adf`.
- Run: [ASan smoke test #26](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46110961155), push on main; public run listing reports success.
- User-supplied artifact ZIP: `asan-redzone-40e5f0fd5a139f405e6fa6f4e14c96393c558adf.zip`.
- Environment captured at `2026-11-28T05:11:53Z` (UTC). Exact download time was not recorded.
- Inspected and archived on 2026-11-28 (Asia/Shanghai).
- Command: `bash scripts/run_redzone.sh`; workflow job: `redzone`.
- ZIP SHA-256: `3ef89ee012cd189b5b7f4c2f77b1dd024a68eaabd2d3b96e1032b43861f2e576`.
- All original members were copied byte-for-byte, including line endings. `SHA256SUMS` covers original members only. The manifest and this note are new documentation; the ZIP itself is not committed.
- All five source/script hashes match Git blobs at the recorded source commit. The source section records no working-tree changes.
- Inspection: all 84 size/repetition/mode combinations appear exactly once; each TSV verdict agrees with its raw log. All 42 controls exit 0 without ASan error; all 42 violations exit 1 with a symbolized one-byte heap-buffer-overflow and no completion message.
- The evidence/documentation commit will be later than the source commit. Later CI runs do not replace this provenance.

## Historical metadata caveat

The collector prints a fixed smoke-demo allocation sentence (8 bytes, indices 7 and 8) for both jobs. For the redzone job, use `trials.tsv`, raw logs and `run_redzone.sh` for the actual seven sizes and four modes. This historical line is retained unchanged. Smoke and redzone ran on separate machines (AMD/Azure and Intel/AWS); do not pool their timings.
