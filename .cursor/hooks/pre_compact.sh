#!/usr/bin/env bash
# Save session state before context compaction.
set -euo pipefail

INPUT=$(cat)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE_FILE="$ROOT/docs/planning_docs/session_state.json"
PLAN="$ROOT/docs/planning_docs/implementation_plan.md"

python3 - "$PLAN" "$STATE_FILE" <<'PY'
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

plan_path = Path(sys.argv[1])
state_path = Path(sys.argv[2])

current_step = ""
pending = []
recent_decisions = []
active_skill = ""

if plan_path.is_file():
    text = plan_path.read_text()
    lines = text.splitlines()

    section = None
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("## "):
            section = stripped[3:].strip()
            continue
        if section == "Step Checklist" and line.startswith("- [ ] "):
            item = line[6:].strip()
            if item:
                pending.append(item)
                if not current_step:
                    current_step = item
        elif section == "Active Skill":
            if stripped and not stripped.startswith("<!--"):
                active_skill = stripped

    if not active_skill:
        skill_match = re.findall(r"@(?:rust|slint|rpi|adversarial)-[\w-]+", text)
        if skill_match:
            active_skill = skill_match[-1]

    in_log = False
    for line in lines:
        if line.strip() == "## Progress Log":
            in_log = True
            continue
        if in_log and line.startswith("##"):
            break
        if in_log and line.startswith("|") and not line.startswith("|---") and "Date" not in line:
            cols = [c.strip() for c in line.strip("|").split("|")]
            if len(cols) >= 4 and cols[3] and cols[3] not in ("Notes", ""):
                recent_decisions.append(cols[3])
            elif len(cols) >= 3 and cols[-1] and cols[-1] not in ("Notes", ""):
                recent_decisions.append(cols[-1])

    recent_decisions = recent_decisions[-5:]

state = {
    "saved_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "current_prd_step": current_step,
    "pending_checklist": pending,
    "recent_decisions": recent_decisions,
    "active_skill": active_skill,
    "note": "Auto-saved by preCompact hook",
}

state_path.write_text(json.dumps(state, indent=2) + "\n")
PY

echo "{}"
exit 0
