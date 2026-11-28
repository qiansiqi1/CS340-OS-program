#!/usr/bin/env python3
"""Plot the preserved Week 3 timing records."""
import csv
from pathlib import Path
import statistics

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

root = Path(__file__).resolve().parents[1] / "evidence/week3"
variants = ("native", "asan_q0", "asan_q64")
labels = ("Native", "ASan: 0 MiB", "ASan: 64 MiB")
fig, axes = plt.subplots(1, 2, figsize=(8.5, 3.6), sharey=True, layout="constrained")
for ax, folder, title in zip(axes, (root, root / "single-cpu"),
                             ("Original affinity", "Single logical CPU")):
    with (folder / "raw.csv").open() as stream:
        rows = list(csv.DictReader(stream))
    for x, variant in enumerate(variants):
        values = [float(row["elapsed_seconds"]) for row in rows
                  if row["variant"] == variant]
        offsets = [(i - (len(values) - 1) / 2) * .025
                   for i in range(len(values))]
        ax.scatter([x + dx for dx in offsets], values, color="#3374a7", alpha=.7)
        ax.errorbar(x + .17, statistics.mean(values), yerr=statistics.stdev(values),
                    fmt="D", color="#932e28", capsize=4, markersize=4)
    ax.set_xticks(range(len(labels)), labels)
    ax.set_title(title)
    ax.set_ylim(bottom=0)
    ax.grid(axis="y", alpha=.25)
axes[0].set_ylabel("Elapsed time (seconds)")
fig.suptitle("Allocation benchmark | individual runs and mean ± sample SD")
matplotlib.rcParams["svg.hashsalt"] = "cs340-week3"
fig.savefig(root / "runtime.svg", metadata={"Date": None})
svg = root / "runtime.svg"
svg.write_text("\n".join(line.rstrip() for line in svg.read_text().splitlines()) + "\n")
