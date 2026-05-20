#!/usr/bin/env bash
# Generate review context bundle for the Critic agent.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"

PLAN="$ROOT/docs/planning_docs/implementation_plan.md"
OUTPUT="$ROOT/docs/planning_docs/review_context.json"
DIFF=$(git diff HEAD 2>/dev/null || echo "(not a git repo or no changes)")

# Escape diff for JSON (basic)
DIFF_ESCAPED=$(printf '%s' "$DIFF" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

PLAN_CONTENT=""
if [ -f "$PLAN" ]; then
  PLAN_CONTENT=$(python3 -c 'import json,sys; print(json.dumps(open(sys.argv[1]).read()))' "$PLAN")
else
  PLAN_CONTENT='"(no plan found)"'
fi

cat > "$OUTPUT" <<EOF
{
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "prd_path": "docs/planning_docs/implementation_plan.md",
  "diff": $DIFF_ESCAPED,
  "plan_excerpt": $PLAN_CONTENT,
  "instructions": "Review diff against PRD using adversarial-review skill. Output to docs/planning_docs/adversarial_review.md with confidence score."
}
EOF

echo "Review context written to $OUTPUT"
