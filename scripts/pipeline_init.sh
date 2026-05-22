#!/usr/bin/env bash
# Bootstrap a new RPI pipeline run for a feature request.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

CLEAN_REVIEW=false
FEATURE_REQUEST=""

for arg in "$@"; do
  case "$arg" in
    --clean-review) CLEAN_REVIEW=true ;;
    -*) echo "Unknown option: $arg" >&2; exit 1 ;;
    *)
      if [ -z "$FEATURE_REQUEST" ]; then
        FEATURE_REQUEST="$arg"
      else
        FEATURE_REQUEST="$FEATURE_REQUEST $arg"
      fi
      ;;
  esac
done

if [ -z "$FEATURE_REQUEST" ]; then
  echo "Usage: ./scripts/pipeline_init.sh \"Feature request summary\" [--clean-review]" >&2
  exit 1
fi

DOCS="$ROOT/docs/planning_docs"
STATE_FILE="$DOCS/session_state.json"
RESEARCH_FILE="$DOCS/implementation_research.md"
PLAN_FILE="$DOCS/implementation_plan.md"

mkdir -p "$DOCS"

python3 - "$FEATURE_REQUEST" "$STATE_FILE" "$RESEARCH_FILE" "$PLAN_FILE" "$CLEAN_REVIEW" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

feature_request = sys.argv[1]
state_path = Path(sys.argv[2])
research_path = Path(sys.argv[3])
plan_path = Path(sys.argv[4])
clean_review = sys.argv[5].lower() == "true"

saved_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

state = {
    "saved_at": saved_at,
    "feature_request": feature_request,
    "pipeline_phase": "research",
    "current_prd_step": "",
    "pending_checklist": [],
    "recent_decisions": [],
    "active_skill": "@rpi-research",
    "note": "Initialized by pipeline_init.sh",
}

state_path.write_text(json.dumps(state, indent=2) + "\n")

research_template = f"""# Implementation Research

> Template for the Research phase of the RPI workflow.
> Do not modify `.rs` or `.slint` files during this phase.

## Feature Summary

{feature_request}

## Current Architecture Findings

<!-- Workspace members affected, existing traits, module boundaries. -->

### Workspace Members

- `core_domain/` —
- `infrastructure/` —
- `ui_application/` —

### Relevant Traits and Types

<!-- List trait interfaces, newtypes, and error types involved. -->

## Cross-Crate Impact Analysis

<!-- How UI state changes might affect core domain logic. -->

## Constraints

- [ ] No UI crate imports from `infrastructure/` beyond approved adapters
- [ ] Extend via new trait implementations rather than editing core logic
- [ ] All public APIs require documentation under strict Clippy rules

## Open Questions

<!-- Items requiring human approval before planning. -->

## Research Artifacts

<!-- Links to grep results, `cargo tree` output, or analysis script results. -->
"""

plan_template = """# Implementation Plan

> Living specification for the Plan phase of the RPI workflow.
> Implementation must not begin until this plan is approved.

## Approval Gate

- [ ] **APPROVED** — Human engineer or supervisory agent sign-off required

## Product Requirements

### Goal

<!-- What the feature delivers to the user. -->

### Non-Goals

<!-- Explicitly out-of-scope items. -->

## Architecture Decisions

<!-- Key decisions with rationale. Reference SOLID principles. -->

## Step Checklist

<!-- Atomic, verifiable implementation steps. -->

- [ ] Step 1:
- [ ] Step 2:
- [ ] Step 3:

## Active Skill

<!-- Optional: skill in use for current step, e.g. @rpi-implement -->

## Testing Strategy

<!-- Unit tests, UI validation, quality gate expectations. -->

## Rollback Plan

<!-- How to revert if a step fails validation. -->

## Progress Log

| Date | Step | Status | Notes |
|------|------|--------|-------|
|      |      |        |       |
"""

research_path.write_text(research_template)
plan_path.write_text(plan_template)

docs_dir = research_path.parent

if clean_review:
    for name in ("adversarial_review.md", "review_context.json"):
        path = docs_dir / name
        if path.is_file():
            path.unlink()

summary = {
    "status": "initialized",
    "feature_request": feature_request,
    "pipeline_phase": "research",
    "saved_at": saved_at,
    "research_file": "docs/planning_docs/implementation_research.md",
    "plan_file": "docs/planning_docs/implementation_plan.md",
    "state_file": "docs/planning_docs/session_state.json",
    "next_phase": "research",
    "active_skill": "@rpi-research",
}

print(json.dumps(summary, indent=2))
PY
