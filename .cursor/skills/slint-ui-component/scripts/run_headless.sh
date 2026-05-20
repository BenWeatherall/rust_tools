#!/usr/bin/env bash
# Build UI and attempt headless validation.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"

cargo build -p ui_application

if command -v agent-browser >/dev/null 2>&1; then
  echo "agent-browser available — run UI snapshot tests via ./scripts/run_ui_tests.sh"
else
  echo "Headless UI validation skipped (agent-browser not installed)."
fi
