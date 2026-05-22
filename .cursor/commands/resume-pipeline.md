# Resume Pipeline

Continue an in-progress RPI feature from saved session state. Use after plan approval, context compaction, or mid-feature interruption.

## Instructions

1. Read `docs/planning_docs/session_state.json`
2. Read `docs/planning_docs/implementation_plan.md`
3. Read `docs/planning_docs/implementation_research.md` if needed for context

Branch on `pipeline_phase` in session state:

### `research`

Research was interrupted. Load `@rpi-research`, follow [.cursor/prompts/01-research.md](../prompts/01-research.md), complete `implementation_research.md`, then continue to Plan (Phase 2 in `/develop-feature`).

### `plan`

Plan was interrupted. Follow [.cursor/prompts/02-plan.md](../prompts/02-plan.md), complete `implementation_plan.md`, set `"pipeline_phase": "awaiting_approval"`, and **STOP** for approval.

### `awaiting_approval`

Do **not** implement. Remind the user:

- Feature: `{feature_request from session_state}`
- Review `docs/planning_docs/implementation_plan.md`
- Reply **approved** to proceed, or request plan revisions

If the user replies **approved**, check the approval gate in the plan and continue to Implement below.

### `implement`

1. Verify approval gate is checked in `implementation_plan.md`
2. Load `@rpi-implement`
3. Follow [.cursor/prompts/03-implement-step.md](../prompts/03-implement-step.md)
4. Claim the **next unchecked** step from the Step Checklist
5. Run validation:
   ```bash
   ./scripts/lint_and_fmt.sh
   ./scripts/orchestrate_review.sh
   ```
6. If Critic review is required, set `"pipeline_phase": "review"` and follow Critic handoff below
7. If more steps remain, stay at `"pipeline_phase": "implement"` and loop
8. If all steps complete with score ≥ 90, set `"pipeline_phase": "complete"`

### `review`

Critic review is pending:

1. If you are in a **fresh session** (no implementation chain-of-thought): load `@adversarial-review`, follow [.cursor/prompts/04-adversarial-review.md](../prompts/04-adversarial-review.md), write `docs/planning_docs/adversarial_review.md`
2. Re-run `./scripts/orchestrate_review.sh`
3. If score ≥ 90: set `"pipeline_phase": "implement"` (if steps remain) or `"complete"` (if done)
4. If score < 90: address feedback, fix code, re-validate

### `complete`

Summarize delivered work from the plan progress log. No further action unless the user starts a new feature with `/develop-feature`.

## Hard Rules

- Same constraints as `/develop-feature`: one step per cycle, approval gate required, Critic score ≥ 90 for merge
- Do not batch unrelated steps
- Update the plan progress log after each completed step
