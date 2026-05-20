#!/usr/bin/env bash
# Restore session state on session start.
set -euo pipefail

INPUT=$(cat)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE_FILE="$ROOT/docs/planning_docs/session_state.json"

if [ ! -f "$STATE_FILE" ]; then
  echo '{}'
  exit 0
fi

python3 - "$STATE_FILE" <<'PY'
import json, sys

state = json.load(open(sys.argv[1]))
lines = [
    "## Restored Session State",
    f"Saved at: {state.get('saved_at', 'unknown')}",
    f"Current PRD step: {state.get('current_prd_step', 'none')}",
    f"Active skill: {state.get('active_skill', 'none')}",
    "",
    "### Pending Checklist",
]
for item in state.get("pending_checklist", []):
    lines.append(f"- [ ] {item}")
for decision in state.get("recent_decisions", []):
    lines.append(f"Decision: {decision}")

print(json.dumps({"additional_context": "\n".join(lines)}))
PY

exit 0
