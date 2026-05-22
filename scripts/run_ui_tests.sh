#!/usr/bin/env bash
# Build Slint UI and optionally run headless browser validation.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PASSED=true
FAILURES="[]"
MESSAGE="UI build succeeded"
SNAPSHOT_FILE=""
AGENT_BROWSER_URL="${AGENT_BROWSER_URL:-}"

if ! cargo build -p ui_application 2>/dev/null; then
  PASSED=false
  MESSAGE="UI build failed"
  FAILURES='[{"file":"ui_application","line":0,"message":"cargo build -p ui_application failed"}]'
elif command -v agent-browser >/dev/null 2>&1; then
  if [ -n "$AGENT_BROWSER_URL" ]; then
    SNAPSHOT_TMP=$(mktemp)
    set +e
    agent-browser open "$AGENT_BROWSER_URL" >/dev/null 2>&1
    agent-browser snapshot -i --json > "$SNAPSHOT_TMP" 2>/dev/null
    SNAPSHOT_EXIT=$?
    agent-browser close >/dev/null 2>&1 || true
    set -e
    if [ "$SNAPSHOT_EXIT" -eq 0 ] && [ -s "$SNAPSHOT_TMP" ]; then
      SNAPSHOT_FILE="$ROOT/docs/planning_docs/ui_snapshot.json"
      cp "$SNAPSHOT_TMP" "$SNAPSHOT_FILE"
      MESSAGE="UI build succeeded; agent-browser snapshot saved to docs/planning_docs/ui_snapshot.json"
    else
      PASSED=false
      MESSAGE="agent-browser snapshot failed for $AGENT_BROWSER_URL"
      FAILURES='[{"file":"scripts/run_ui_tests.sh","line":0,"message":"agent-browser snapshot failed"}]'
    fi
    rm -f "$SNAPSHOT_TMP"
  else
    MESSAGE="UI build succeeded; set AGENT_BROWSER_URL for wasm/web snapshot tests (native Slint skipped)"
  fi
else
  MESSAGE="UI build succeeded; agent-browser not installed (skipped)"
fi

python3 - <<PY
import json
passed = $( [ "$PASSED" = true ] && echo "True" || echo "False" )
failures = json.loads('''$FAILURES''')
out = {
    "phase": "ui",
    "passed": passed,
    "message": """$MESSAGE""",
    "failures": failures,
}
snapshot = """$SNAPSHOT_FILE"""
if snapshot:
    out["snapshot_file"] = snapshot
print(json.dumps(out))
PY

[ "$PASSED" = true ]
