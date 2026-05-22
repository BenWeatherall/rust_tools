#!/usr/bin/env bash
# Save session state before context compaction.
set -euo pipefail

INPUT=$(cat)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE_FILE="$ROOT/docs/planning_docs/session_state.json"
PLAN="$ROOT/docs/planning_docs/implementation_plan.md"
RESEARCH="$ROOT/docs/planning_docs/implementation_research.md"

python3 - "$PLAN" "$STATE_FILE" "$RESEARCH" <<'PY'
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

plan_path = Path(sys.argv[1])
state_path = Path(sys.argv[2])
research_path = Path(sys.argv[3])

current_step = ""
pending = []
recent_decisions = []
active_skill = ""
feature_request = ""
pipeline_phase = "research"
approval_checked = False
has_plan_content = False

existing = {}
if state_path.is_file():
    try:
        existing = json.loads(state_path.read_text())
    except json.JSONDecodeError:
        existing = {}

feature_request = existing.get("feature_request", "")

if research_path.is_file() and not feature_request:
    research_text = research_path.read_text()
    in_summary = False
    for line in research_text.splitlines():
        stripped = line.strip()
        if stripped == "## Feature Summary":
            in_summary = True
            continue
        if in_summary:
            if stripped.startswith("##"):
                break
            if stripped and not stripped.startswith("<!--"):
                feature_request = stripped
                break

if plan_path.is_file():
    text = plan_path.read_text()
    lines = text.splitlines()

    section = None
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("## "):
            section = stripped[3:].strip()
            continue
        if section == "Approval Gate" and line.startswith("- [x]"):
            approval_checked = True
        if section == "Step Checklist" and line.startswith("- [ ] "):
            item = line[6:].strip()
            if item and not item.endswith(":"):
                has_plan_content = True
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

    if existing.get("pipeline_phase") == "review":
        pipeline_phase = "review"
    elif not has_plan_content and not approval_checked:
        pipeline_phase = existing.get("pipeline_phase", "research")
    elif not approval_checked:
        pipeline_phase = "awaiting_approval"
    elif pending:
        pipeline_phase = "implement"
    else:
        pipeline_phase = "complete"

if not active_skill:
    phase_skills = {
        "research": "@rpi-research",
        "plan": "@rpi-research",
        "awaiting_approval": "@rpi-research",
        "implement": "@rpi-implement",
        "review": "@adversarial-review",
        "complete": "",
    }
    active_skill = phase_skills.get(pipeline_phase, "")

state = {
    "saved_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "feature_request": feature_request,
    "pipeline_phase": pipeline_phase,
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
