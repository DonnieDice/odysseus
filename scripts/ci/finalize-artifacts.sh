#!/usr/bin/env bash
set -euo pipefail

artifact_dir="${1:-artifacts}"
mkdir -p "$artifact_dir"

python3 - "$artifact_dir" <<'PY'
from pathlib import Path
import hashlib
import sys

artifact_dir = Path(sys.argv[1])
artifact_dir.mkdir(parents=True, exist_ok=True)

excluded = {"manifest.txt", "SHA256SUMS"}
payload_files = sorted(
    p for p in artifact_dir.iterdir()
    if p.is_file() and p.name not in excluded
)

sha_path = artifact_dir / "SHA256SUMS"
with sha_path.open("w", encoding="utf-8") as out:
    for path in payload_files:
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        out.write(f"{digest}  {path.name}\n")

all_files = sorted(p.name for p in artifact_dir.iterdir() if p.is_file())

manifest_path = artifact_dir / "manifest.txt"
with manifest_path.open("a", encoding="utf-8") as out:
    out.write(f"artifact_count={len(payload_files)}\n")
    out.write("artifact_files<<EOF\n")
    for name in all_files:
        out.write(f"{name}\n")
    out.write("EOF\n")
PY
