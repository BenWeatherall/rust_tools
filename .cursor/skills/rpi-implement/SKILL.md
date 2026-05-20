---
name: rpi-implement
description: >-
  Executes atomic implementation steps from an approved plan with lint and test
  validation. Use during the Implement phase of RPI when coding a specific plan
  step, after plan approval, or when the user says implement step N.
---

# RPI Implement Phase

## Prerequisites

- Approved plan in `docs/planning_docs/implementation_plan.md`
- Research complete in `docs/planning_docs/implementation_research.md`

## Workflow

1. Claim **one** step from the plan checklist.
2. Load relevant skills (e.g., `@rust-core`, `@slint-ui-component`).
3. Implement the step — minimal diff, no scope creep.
4. Run validation:
   ```bash
   ./scripts/lint_and_fmt.sh
   ./scripts/test_json.sh
   ```
5. Mark the step complete in the plan progress log.
6. Run `./scripts/orchestrate_review.sh` before moving to the next step.

## Checklist

See [implementation_checklist.md](references/implementation_checklist.md).

## Hard Rules

- One step at a time — do not batch unrelated changes.
- Follow `.cursor/rules/` and workspace SOLID boundaries.
- Update `implementation_plan.md` progress log after each step.
