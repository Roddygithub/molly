#!/usr/bin/env python3
"""Linux-only, bounded idle measurement of the isolated probe (not all of Moli)."""
import json
import os
from pathlib import Path
import subprocess
import time

root = Path(__file__).resolve().parent.parent
subprocess.run(["cargo", "build", "--locked", "--release"], cwd=root, check=True)
metadata = json.loads(subprocess.check_output(
    ["cargo", "metadata", "--locked", "--no-deps", "--format-version", "1"], cwd=root
))
binary = Path(metadata["target_directory"]) / "release/molly-matter-probe"
process = subprocess.Popen([str(binary), "--measure"], stdout=subprocess.PIPE, text=True)
try:
    samples = []
    start = time.monotonic()
    while process.poll() is None and time.monotonic() - start < 40:
        try:
            status = dict(line.split(":", 1) for line in Path(f"/proc/{process.pid}/status").read_text().splitlines() if ":" in line)
            # After ')' fields begin at #3; utime/stime are #14/#15.
            fields = Path(f"/proc/{process.pid}/stat").read_text().rsplit(")", 1)[1].split()
            samples.append((time.monotonic(), int(fields[11]) + int(fields[12]),
                            int(status["VmRSS"].split()[0]), int(status["RssAnon"].split()[0])))
        except (FileNotFoundError, ProcessLookupError, KeyError):
            pass  # the process may exit between /proc reads
        time.sleep(0.25)
    output, _ = process.communicate(timeout=5)
    if process.returncode:
        raise SystemExit(process.returncode)
    print(output.strip())
    steady = [s for s in samples if s[0] - start >= 2]
    if len(steady) < 2:
        raise SystemExit("probe exited before an idle sample window was available")
    first, last = steady[0], steady[-1]
    print(json.dumps({
        "binary_bytes": binary.stat().st_size,
        "idle_seconds": round(last[0] - first[0], 2),
        "rss_kib_peak": max(s[2] for s in steady),
        "anonymous_kib_peak": max(s[3] for s in steady),
        "cpu_percent_one_core": round(100 * (last[1] - first[1]) / os.sysconf("SC_CLK_TCK") / (last[0] - first[0]), 3),
        "scope": "one empty fabric, no nodes, no subscriptions, no OTBR; process memory, not cgroup",
    }, indent=2))
finally:
    if process.poll() is None:
        process.kill()
        process.wait()
