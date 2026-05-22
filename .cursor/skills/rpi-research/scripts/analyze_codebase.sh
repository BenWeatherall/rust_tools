#!/usr/bin/env bash
# Structural codebase analysis for RPI research phase. Emits JSON report.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"

OUTPUT="${1:-}"

python3 - "$ROOT" "$OUTPUT" <<'PY'
import json
import os
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1])
output_path = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] else ""

def run(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, text=True, stderr=subprocess.DEVNULL).strip()
    except subprocess.CalledProcessError:
        return ""

members_line = run(f"grep -E '^members' {root / 'Cargo.toml'}")
members = []
if members_line:
    inner = members_line.split("[", 1)[-1].split("]", 1)[0]
    members = [m.strip().strip('"') for m in inner.split(",") if m.strip()]

rust_files = sorted(
    str(p.relative_to(root))
    for p in root.rglob("*.rs")
    if "target" not in p.parts
)
slint_files = sorted(
    str(p.relative_to(root))
    for p in root.rglob("*.slint")
    if "target" not in p.parts
)

traits_raw = run(f"rg 'pub trait ' --type rust -g '!target/**' {root} || true")
traits = [line.strip() for line in traits_raw.splitlines() if line.strip()]

skills = []
skills_dir = root / ".cursor" / "skills"
if skills_dir.is_dir():
    skills = sorted(p.name for p in skills_dir.iterdir() if p.is_dir())

dep_tree = run(f"cd {root} && cargo tree --workspace 2>/dev/null")

codedna = None
if run("command -v codedna"):
    codedna_raw = run(f"cd {root} && codedna . 2>/dev/null")
    if codedna_raw:
        codedna = {"available": True, "output": codedna_raw[:8000]}
else:
    codedna = {"available": False, "output": None}

report = {
    "phase": "research",
    "workspace_members": members,
    "dependency_tree": dep_tree.splitlines() if dep_tree else [],
    "rust_files": rust_files,
    "slint_files": slint_files,
    "public_traits": traits,
    "agent_skills": skills,
    "codedna": codedna,
}

text = json.dumps(report, indent=2)
if output_path:
    Path(output_path).write_text(text + "\n")
else:
    print(text)
PY
