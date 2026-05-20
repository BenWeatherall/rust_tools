#!/usr/bin/env bash
# Save session state before context compaction.
set -euo pipefail

INPUT=$(cat)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE_FILE="$ROOT/docs/planning_docs/session_state.json"
PLAN="$ROOT/docs/planning_docs/implementation_plan.md"

CURRENT_STEP=""
PENDING='[]'
if [ -f "$PLAN" ]; then
  CURRENT_STEP=$(grep -m1 '^\- \[ \]' "$PLAN" 2>/dev/null | sed 's/^- \[ \] //' || echo "")
  PENDING=$(grep '^\- \[ \]' "$PLAN" 2>/dev/null | sed 's/^- \[ \] //' | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))' || echo '[]')
fi

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

python3 - <<PY
import json
state = {
    "saved_at": "$TIMESTAMP",
    "current_prd_step": """$CURRENT_STEP""",
    "pending_checklist": $PENDING,
    "recent_decisions": [],
    "active_skill": "",
    "note": "Auto-saved by preCompact hook"
}
with open("$STATE_FILE", "w") as f:
    json.dump(state, f, indent=2)
PY

echo "{}"
exit 0
