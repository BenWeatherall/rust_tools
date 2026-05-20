#!/usr/bin/env bash
# Multi-agent validation pipeline: Validator → Critic handoff.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

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
echo "==> Phase 3: Critic handoff"
REVIEW_FILE="$ROOT/docs/planning_docs/adversarial_review.md"

if [ -f "$REVIEW_FILE" ]; then
  SCORE=$(grep -oP 'Confidence Score:\s*\K\d+' "$REVIEW_FILE" 2>/dev/null || echo "")
  if [ -n "$SCORE" ] && [ "$SCORE" -lt 90 ]; then
    echo "Critic score $SCORE/100 — below threshold (90). Revision required."
    echo "See $REVIEW_FILE"
    exit 1
  elif [ -n "$SCORE" ]; then
    echo "Critic score $SCORE/100 — APPROVED"
    exit 0
  fi
fi

echo ""
echo "Critic review pending. In a fresh Cursor session:"
echo "  1. Load @adversarial-review skill"
echo "  2. Use prompt: .cursor/prompts/04-adversarial-review.md"
echo "  3. Write output to docs/planning_docs/adversarial_review.md"
echo ""
echo "Review context: docs/planning_docs/review_context.json"
exit 0
