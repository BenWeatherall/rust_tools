# Planning Docs

Persistent memory for the RPI (Research → Plan → Implement) workflow.

## Files

| File | Phase | Purpose |
|------|-------|---------|
| `implementation_research.md` | Research | Codebase analysis, no code edits |
| `implementation_plan.md` | Plan | PRD, step checklist, approval gate |
| `adversarial_review.md` | Review | Critic output with confidence score |
| `review_context.json` | Review | Machine-readable diff + PRD bundle |
| `session_state.json` | Session | Context survival across compaction |

## Usage

1. Start research: invoke `@rpi-research` or use `.cursor/prompts/01-research.md`
2. Create plan from research findings; get approval before coding
3. Implement steps with `@rpi-implement`
4. Run `./scripts/orchestrate_review.sh` after each step

Templates are pre-filled with section headers. Copy and fill for each feature.

## Cursor Access

`session_state.json` and `review_context.json` are listed in `.gitignore` (ephemeral, machine-local). They are re-enabled for the agent via negation patterns in [`.cursorignore`](../../.cursorignore) so Cursor can read them for session recovery and review handoff.

## Sub-Reports

Decomposition docs from the foundation report live in `sub_reports/`.
