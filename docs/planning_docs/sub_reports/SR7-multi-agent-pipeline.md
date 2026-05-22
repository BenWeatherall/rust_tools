# SR7: Multi-Agent Pipeline

## Scope

Executor/Validator/Critic orchestration with verify-review-fix-score loop.

## Delivered

- `scripts/orchestrate_review.sh`:
  1. Runs `quality_gate.sh` (Validator)
  2. Generates `review_context.json` (diff + PRD)
  3. Hands off to Critic via `@adversarial-review` skill
  4. Parses confidence score; blocks if < 90 or review missing (use `--skip-critic` for dev)

## Cursor Integration

| Role | Invocation |
|------|------------|
| Executor | Default agent |
| Validator | `./scripts/quality_gate.sh` |
| Critic | Fresh session + `@adversarial-review` + prompt `04-adversarial-review.md` |

## Validation

```bash
./scripts/orchestrate_review.sh
# Produces docs/planning_docs/review_context.json
```
