#!/usr/bin/env python3
"""Benchmark valid allocations and measure one ASan runtime setting."""
import csv
import hashlib
import os
from pathlib import Path
import platform
import shlex
import statistics
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "perf_bench/perf_micro.c"
VARIANTS = ("native", "asan_q0", "asan_q64")
RUNS = 9


def capture(*args):
    return subprocess.check_output(args, cwd=ROOT, text=True).strip()


def run():
    output = ROOT / "results/week3"
    output.mkdir(parents=True, exist_ok=True)
    compiler = os.environ.get("CC", "gcc")
    settings = "detect_leaks=0:malloc_context_size=1:halt_on_error=1"
    environment = os.environ.copy()
    # Avoid inheriting options that would silently change the experiment.
    for variable in ("ASAN_OPTIONS", "LSAN_OPTIONS", "LD_PRELOAD"):
        environment.pop(variable, None)
    metadata = [
        "utc=" + time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "source_commit=" + capture("git", "rev-parse", "HEAD"),
        "benchmark_sha256=" + hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
        "runner_sha256=" + hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        "os=" + platform.platform(),
        "compiler=" + capture(compiler, "--version").splitlines()[0],
        "libc=" + " ".join(platform.libc_ver()),
        "cpu=" + next(line.split(":", 1)[1].strip()
                      for line in Path("/proc/cpuinfo").read_text().splitlines()
                      if line.startswith("model name")),
        "cpu_affinity_count=" + str(len(os.sched_getaffinity(0))),
        "memory=" + Path("/proc/meminfo").read_text().splitlines()[0],
        "cgroup_memory_max=" + (Path("/sys/fs/cgroup/memory.max").read_text().strip() if Path("/sys/fs/cgroup/memory.max").is_file() else "unavailable"),
        f"repetitions={RUNS}; warmup=one per variant; clock=perf_counter_ns",
        f"ASAN_OPTIONS={settings}:quarantine_size_mb={{0,64}}",
    ]
    rows = []
    with tempfile.TemporaryDirectory() as temporary:
        binaries = {}
        for variant in ("native", "asan"):
            binary = Path(temporary) / variant
            flags = ["-O2", "-g", "-fno-pie", "-no-pie"]
            if variant == "asan":
                flags.append("-fsanitize=address")
            command = [compiler, *flags, str(SOURCE.relative_to(ROOT)), "-o", str(binary)]
            subprocess.run(command, cwd=ROOT, check=True)
            metadata.append("build_" + variant + "=" + shlex.join(
                command[:-1] + ["<temporary>/" + variant]))
            binaries[variant] = binary
        metadata.append("asan_runtime=" + next(
            line.strip() for line in capture("ldd", str(binaries["asan"])).splitlines()
            if "libasan" in line))
        runtime = Path(capture(compiler, "-print-file-name=libasan.so")).resolve()
        metadata.append("asan_runtime_sha256=" + hashlib.sha256(runtime.read_bytes()).hexdigest())
        (output / "environment.txt").write_text("\n".join(metadata) + "\n")
        with (output / "execution.log").open("w") as log:
            for trial in range(RUNS + 1):
                shift = max(trial - 1, 0) % len(VARIANTS)
                for position, variant in enumerate(VARIANTS[shift:] + VARIANTS[:shift], 1):
                    env = environment.copy()
                    binary = binaries["native"]
                    if variant != "native":
                        binary = binaries["asan"]
                        size = variant.removeprefix("asan_q")
                        env["ASAN_OPTIONS"] = settings + ":quarantine_size_mb=" + size
                    started = time.perf_counter_ns()
                    completed = subprocess.run([binary], env=env, capture_output=True, text=True)
                    elapsed = (time.perf_counter_ns() - started) / 1e9
                    log.write(f"trial={trial} position={position} variant={variant} "
                              f"seconds={elapsed:.9f} exit={completed.returncode}\n")
                    log.write(completed.stdout + completed.stderr)
                    completed.check_returncode()
                    if trial:
                        rows.append((trial, position, variant, f"{elapsed:.9f}"))
    with (output / "raw.csv").open("w", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(("trial", "position", "variant", "elapsed_seconds"))
        writer.writerows(rows)
    report = ["variant,n,mean_seconds,sample_sd_seconds,ratio_to_native,slowdown_pct"]
    elapsed = {variant: [float(row[3]) for row in rows if row[2] == variant]
               for variant in VARIANTS}
    baseline = statistics.mean(elapsed["native"])
    for variant, values in elapsed.items():
        mean = statistics.mean(values)
        ratio = mean / baseline
        report.append(f"{variant},{len(values)},{mean:.9f},{statistics.stdev(values):.9f},"
                      f"{ratio:.6f},{100 * (ratio - 1):.4f}")
    report.append("")
    (output / "summary.csv").write_text("\n".join(report))
    print("\n".join(report))


if __name__ == "__main__":
    run()
