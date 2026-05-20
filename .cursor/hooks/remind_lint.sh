#!/usr/bin/env bash
# Remind agent to run lint after editing Rust or Slint files.
set -euo pipefail

INPUT=$(cat)
echo '{"additional_context": "Reminder: run ./scripts/lint_and_fmt.sh before finishing this task."}'
exit 0
