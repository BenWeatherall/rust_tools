#!/usr/bin/env bash
# Run workspace tests and emit structured JSON results.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUTPUT=$(mktemp)
PASSED=true
FORMAT="stable"

# Attempt nightly JSON output if available
if rustup run nightly rustc --version >/dev/null 2>&1; then
  if RUSTC_BOOTSTRAP=1 cargo +nightly test --workspace -- -Z unstable-options --format json > "$OUTPUT" 2>/dev/null; then
    FORMAT="json-nightly"
  else
    PASSED=false
  fi
else
  if cargo test --workspace > "$OUTPUT" 2>&1; then
    FORMAT="stable"
  else
    PASSED=false
  fi
fi

FAILURES="[]"
if [ "$PASSED" = false ]; then
  FAILURES=$(python3 - <<'PY' "$OUTPUT"
import json, re, sys
text = open(sys.argv[1]).read()
items = []
for m in re.finditer(r"---- (.+?) stdout ----", text):
    items.append({"file": "", "line": 0, "message": f"test failed: {m.group(1)}"})
for m in re.finditer(r"error\[E\d+\]: (.+)", text):
    items.append({"file": "", "line": 0, "message": m.group(1)})
if not items:
    items.append({"file": "", "line": 0, "message": "tests failed; see cargo output"})
print(json.dumps(items[:20]))
PY
)
fi

python3 - <<PY
import json
passed = $( [ "$PASSED" = true ] && echo "True" || echo "False" )
failures = json.loads('''$FAILURES''')
print(json.dumps({
    "phase": "test",
    "passed": passed,
    "format": "$FORMAT",
    "failures": failures
}))
PY

rm -f "$OUTPUT"
[ "$PASSED" = true ]
