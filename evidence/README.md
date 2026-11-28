# Execution evidence

Performance evidence is preserved in [week3](week3/) and its
[single-CPU batch](week3/single-cpu/), including CSVs, environment records
and execution logs. These are historical Linux/GCC measurements.

Detection evidence for Week 1 / Claim 1 has not been archived here.
The instructions below describe how to preserve it after inspecting a
real run; neither a green badge nor this document replaces those logs.

1. Open the repository's **Actions > ASan smoke test** page and inspect a run for the intended source commit. The run must pass; verify the raw safe-control and ASan-report output.
2. Download the `asan-smoke-<source SHA>` artifact from that run. It contains `environment.txt`, `build.log`, `safe.log`, `overflow.log`, and `summary.txt`.
3. Copy those five files unchanged into `evidence/week1/` and add `provenance.md` recording the run URL, source commit, capture time, overall verdict, and each source command. Do not include credentials, binary outputs, or arbitrary files from the runner.
4. Commit the evidence from your own GitHub account with your student ID and full name in the commit message. The evidence commit will be later than the source commit that generated it; keep both identities clear.

For a local Ubuntu run, use the same five files from `results/latest/`. Record that it was a local run, retain the exact source commit and hashes, and state whether the checkout was dirty. Never describe a local result as GitHub-hosted or substitute expected output for real output.

Artifacts expire after 30 days. The committed text logs, not just a green badge or expiring artifact link, will support the final course report. A re-run of the evidence-only commit is a different run; the preserved evidence still refers to its original source SHA.
