# Implement Step Prompt

Use with `@rpi-implement` skill after plan approval.

## Task

Implement plan step:

> [STEP NUMBER AND DESCRIPTION]

## Instructions

1. Verify approval gate is checked in `docs/planning_docs/implementation_plan.md`
2. Load relevant skills (`@rust-core`, `@slint-ui-component`, etc.)
3. Implement **only** this step — minimal diff
4. Run validation:
   ```bash
   ./scripts/lint_and_fmt.sh
   ./scripts/test_json.sh
   ```
5. Update progress log in the plan
6. Run `./scripts/orchestrate_review.sh`

## Constraints

- Follow `.cursor/rules/` and workspace SOLID boundaries
- No scope creep beyond the claimed step
- Fix build errors before style concerns

## Output

Working code with updated plan progress log and passing quality gate.
