#!/usr/bin/env bash
# Verify Slint property bindings and callback declarations in UI files.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"

UI_DIR="$ROOT/ui_application/ui"
ISSUES=()

check_file() {
  local file="$1"
  local base
  base=$(basename "$file")

  if ! grep -qE '(in-out |in |out )?property\s+<' "$file" 2>/dev/null \
    && ! grep -qE 'callback\s+' "$file" 2>/dev/null; then
    if [[ "$base" != "status-badge.slint" ]]; then
      ISSUES+=("$file: no properties or callbacks declared")
    fi
  fi

  if [[ "$base" == "register-view.slint" ]] && ! grep -q '<=>' "$file" 2>/dev/null; then
    ISSUES+=("$file: expected two-way binding (text <=>) in register view")
  fi
}

while IFS= read -r slint_file; do
  check_file "$slint_file"
done < <(find "$UI_DIR" -name "*.slint" | sort)

if ! cargo build -p ui_application >/dev/null 2>&1; then
  ISSUES+=("ui_application: cargo build failed — bindings may not compile to Rust")
fi

python3 - "${ISSUES[@]}" <<'PY'
import json, sys

issues = sys.argv[1:]
print(json.dumps({
    "phase": "bindings",
    "passed": len(issues) == 0,
    "issues": issues,
}, indent=2))
PY

[ ${#ISSUES[@]} -eq 0 ]
