#!/usr/bin/env bash
# Run cargo check and emit JSON with parse/syntax errors only.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"

TARGET="${1:-}"

CHECK_ARGS=(check --workspace --message-format=json)
if [ -n "$TARGET" ]; then
  CHECK_ARGS=(check -p "$TARGET" --message-format=json)
fi

TMP=$(mktemp)
set +e
cargo "${CHECK_ARGS[@]}" 2>"$TMP"
CHECK_EXIT=$?
set -e

python3 - "$TMP" <<'PY'
import json, sys

errors = []
for line in open(sys.argv[1]):
    line = line.strip()
    if not line:
        continue
    try:
        msg = json.loads(line)
    except json.JSONDecodeError:
        continue
    if msg.get("reason") != "compiler-message":
        continue
    payload = msg.get("message", {})
    level = payload.get("level")
    if level not in ("error", "warning"):
        continue
    code = payload.get("code")
    code_str = code.get("code") if isinstance(code, dict) else str(code or "")
    spans = payload.get("spans") or [{}]
    span = spans[0]
    errors.append({
        "level": level,
        "code": code_str,
        "file": span.get("file_name", ""),
        "line": span.get("line_start", 0),
        "message": payload.get("message", ""),
    })

passed = not any(e["level"] == "error" for e in errors)
print(json.dumps({"phase": "syntax", "passed": passed, "errors": errors}, indent=2))
PY

rm -f "$TMP"
exit "$CHECK_EXIT"
