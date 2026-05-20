#!/usr/bin/env bash
# Quality gate: fmt → clippy → tests → UI build. Emits JSON report.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

RESULTS_FILE=$(mktemp)
echo '[]' > "$RESULTS_FILE"
OVERALL=true

append_result() {
  local entry_file="$1"
  python3 - "$RESULTS_FILE" "$entry_file" <<'PY'
import json, sys
results_path, entry_path = sys.argv[1], sys.argv[2]
results = json.load(open(results_path))
entry = json.load(open(entry_path))
results.append(entry)
json.dump(results, open(results_path, "w"))
PY
}

# Format + Clippy
FMT_TMP=$(mktemp)
ENTRY_TMP=$(mktemp)
if ./scripts/lint_and_fmt.sh > "$FMT_TMP" 2>&1; then
  echo '{"phase":"clippy","passed":true,"failures":[]}' > "$ENTRY_TMP"
else
  OVERALL=false
  python3 - "$FMT_TMP" "$ENTRY_TMP" <<'PY'
import json, sys
msg = open(sys.argv[1]).read()[:500]
json.dump({"phase": "clippy", "passed": False, "failures": [{"file": "", "line": 0, "message": msg}]}, open(sys.argv[2], "w"))
PY
fi
append_result "$ENTRY_TMP"
rm -f "$FMT_TMP" "$ENTRY_TMP"

run_phase() {
  local script="$1"
  local tmp entry
  tmp=$(mktemp)
  entry=$(mktemp)
  if "$script" > "$tmp" 2>&1; then
    cp "$tmp" "$entry"
  else
    OVERALL=false
    if python3 -c "import json; json.load(open('$tmp'))" 2>/dev/null; then
      python3 - "$tmp" "$entry" <<'PY'
import json, sys
entry = json.load(open(sys.argv[1]))
entry["passed"] = False
json.dump(entry, open(sys.argv[2], "w"))
PY
    else
      python3 - "$tmp" "$entry" <<'PY'
import json, sys
msg = open(sys.argv[1]).read()[:500]
json.dump({"phase": "unknown", "passed": False, "failures": [{"file": "", "line": 0, "message": msg}]}, open(sys.argv[2], "w"))
PY
    fi
  fi
  append_result "$entry"
  rm -f "$tmp" "$entry"
}

run_phase ./scripts/test_json.sh
run_phase ./scripts/run_ui_tests.sh

python3 - "$RESULTS_FILE" <<'PY'
import json, sys
results = json.load(open(sys.argv[1]))
overall = all(r.get("passed", False) for r in results)
print(json.dumps({"phase": "quality_gate", "passed": overall, "results": results}, indent=2))
PY

RM_OVERALL=$OVERALL
rm -f "$RESULTS_FILE"
[ "$RM_OVERALL" = true ]
