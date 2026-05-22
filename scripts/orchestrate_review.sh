#!/usr/bin/env bash
# Multi-agent validation pipeline: Validator → Critic handoff.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SKIP_CRITIC=false
for arg in "$@"; do
  case "$arg" in
    --skip-critic) SKIP_CRITIC=true ;;
  esac
done

echo "==> Phase 1: Validator (quality gate)"
GATE_TMP=$(mktemp)
if ! ./scripts/quality_gate.sh > "$GATE_TMP" 2>&1; then
  echo "Validator FAILED:"
  cat "$GATE_TMP"
  rm -f "$GATE_TMP"
  exit 1
fi
echo "Validator PASSED"
cat "$GATE_TMP"
rm -f "$GATE_TMP"

echo ""
echo "==> Phase 2: Generate Critic review context"
./.cursor/skills/adversarial-review/scripts/generate_review_context.sh

echo ""
echo "==> Phase 3: Critic review"
REVIEW_FILE="$ROOT/docs/planning_docs/adversarial_review.md"

score_ok() {
  local score="$1"
  [ -n "$score" ] && [ "$score" -ge 90 ] 2>/dev/null
}

if [ -f "$REVIEW_FILE" ]; then
  SCORE=$(grep -oP 'Confidence Score:\s*\K\d+' "$REVIEW_FILE" 2>/dev/null || echo "")
  if [ -n "$SCORE" ] && [ "$SCORE" -lt 90 ]; then
    echo "Critic score $SCORE/100 — below threshold (90). Revision required."
    echo "See $REVIEW_FILE"
    exit 1
  elif score_ok "$SCORE"; then
    echo "Critic score $SCORE/100 — APPROVED"
    exit 0
  fi
fi

if [ "$SKIP_CRITIC" = true ]; then
  echo "Critic review skipped (--skip-critic). Complete review before merge."
  exit 0
fi

echo ""
echo "Critic review REQUIRED before merge."
echo "In a fresh Cursor session:"
echo "  1. Load @adversarial-review skill"
echo "  2. Use prompt: .cursor/prompts/04-adversarial-review.md"
echo "  3. Write output to docs/planning_docs/adversarial_review.md"
echo "  4. Re-run: ./scripts/orchestrate_review.sh"
echo ""
echo "Review context: docs/planning_docs/review_context.json"
exit 1
