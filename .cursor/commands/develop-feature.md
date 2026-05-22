# Develop Feature (RPI Pipeline)

Run the full Research → Plan → Implement → Validate pipeline for a new feature request.

## Feature Request

$SELECTION

<!-- If no selection, use the user's message after the command invocation. -->

## Pipeline Orchestration

Follow [AGENTS.md](../../AGENTS.md), [.cursor/rules/rpi-workflow.mdc](../rules/rpi-workflow.mdc), and the phase prompts below. Execute phases **in order**. Do not skip gates.

### Phase 0: Initialize

1. Extract a one-line feature summary from the Feature Request above.
2. Run:
   ```bash
   ./scripts/pipeline_init.sh "FEATURE SUMMARY HERE"
   ```
3. Read the JSON summary printed to stdout before continuing.

### Phase 1: Research

1. Load skill: `@rpi-research`
2. Follow [.cursor/prompts/01-research.md](../prompts/01-research.md)
3. Write complete findings to `docs/planning_docs/implementation_research.md`
4. **Constraints:** Do NOT edit any `.rs` or `.slint` files
5. Update `docs/planning_docs/session_state.json`: set `"pipeline_phase": "plan"`

### Phase 2: Plan

1. Follow [.cursor/prompts/02-plan.md](../prompts/02-plan.md)
2. Read `docs/planning_docs/implementation_research.md`
3. Write `docs/planning_docs/implementation_plan.md` with:
   - Product requirements (goal, non-goals)
   - Architecture decisions with SOLID rationale
   - Atomic step checklist (each step independently verifiable)
   - Testing strategy
   - **Unchecked** approval gate checkbox
4. Update `docs/planning_docs/session_state.json`: set `"pipeline_phase": "awaiting_approval"`

### Phase 3: STOP — Approval Gate

**Do not implement code in this session unless the user has already explicitly approved the plan.**

Present a concise summary:

- Feature goal and non-goals
- Architecture decisions
- Step checklist
- Open questions from research

Then tell the user:

> Plan is ready for review. Reply **approved** to proceed, or request changes. After approval, run `/resume-pipeline` or reply **approved** to continue implementation.

**End your turn here.** Do not proceed to Phase 4 without explicit approval.

---

## Phases 4–7 (only after explicit approval)

If the user replies **approved** (or the approval gate is already checked in `implementation_plan.md`), continue:

### Phase 4: Implement (one step)

1. Verify the approval gate is checked in `docs/planning_docs/implementation_plan.md`
2. Load skill: `@rpi-implement`
3. Follow [.cursor/prompts/03-implement-step.md](../prompts/03-implement-step.md)
4. Claim **one** unchecked step from the Step Checklist — minimal diff, no scope creep
5. Load domain skills as needed (`@rust-core`, `@slint-ui-component`, `@slint-state-binding`, etc.)
6. Update `session_state.json`: set `"pipeline_phase": "implement"`

### Phase 5: Validate

```bash
./scripts/lint_and_fmt.sh
./scripts/orchestrate_review.sh
```

If `./scripts/orchestrate_review.sh` fails because Critic review is missing, go to Phase 6. Otherwise proceed to Phase 7.

### Phase 6: Critic Handoff

When the orchestrator requires Critic review:

1. Update `session_state.json`: set `"pipeline_phase": "review"`
2. Tell the user to open a **fresh Cursor session** (no implementation context)
3. In that session: load `@adversarial-review` and follow [.cursor/prompts/04-adversarial-review.md](../prompts/04-adversarial-review.md)
4. Write output to `docs/planning_docs/adversarial_review.md`
5. Re-run `./scripts/orchestrate_review.sh`
6. If Critic score is below 90, address feedback and re-implement; do not merge

### Phase 7: Loop or Complete

- If unchecked steps remain in the plan: mark the completed step in the progress log, then return to **Phase 4** for the next step
- If all steps are complete and Critic score ≥ 90: set `"pipeline_phase": "complete"` in `session_state.json` and summarize what was delivered

## Hard Rules

- One atomic implementation step per cycle
- Follow workspace SOLID boundaries (`core_domain`, `infrastructure`, `ui_application`)
- Fix build errors before style concerns
- Critic confidence score ≥ 90 required before merge
- Use `./scripts/orchestrate_review.sh --skip-critic` only during active development, not for final merge
