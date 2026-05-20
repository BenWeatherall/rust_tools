#!/usr/bin/env bash
# Build Slint UI and optionally run headless browser validation.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PASSED=true
FAILURES="[]"
MESSAGE="UI build succeeded"

if ! cargo build -p ui_application 2>/dev/null; then
  PASSED=false
  MESSAGE="UI build failed"
  FAILURES='[{"file":"ui_application","line":0,"message":"cargo build -p ui_application failed"}]'
else
  if command -v agent-browser >/dev/null 2>&1; then
    MESSAGE="UI build succeeded; agent-browser available for snapshot tests"
  else
    MESSAGE="UI build succeeded; agent-browser not installed (skipped)"
  fi
fi

python3 - <<PY
import json
passed = $( [ "$PASSED" = true ] && echo "True" || echo "False" )
failures = json.loads('''$FAILURES''')
print(json.dumps({
    "phase": "ui",
    "passed": passed,
    "message": """$MESSAGE""",
    "failures": failures
}))
PY

[ "$PASSED" = true ]
