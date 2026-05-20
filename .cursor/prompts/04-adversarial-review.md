# Adversarial Review Prompt

Use with `@adversarial-review` skill in a **fresh context** (Critic role).

## Task

Review the implementation against the approved plan.

## Instructions

1. Read `docs/planning_docs/review_context.json`
2. Read `docs/planning_docs/implementation_plan.md`
3. Review the git diff adversarially — assume the implementer may be wrong
4. Check against the critic checklist and SOLID review guide
5. Write output to `docs/planning_docs/adversarial_review.md`

## Scoring

- **90+**: APPROVE
- **70–89**: REVISE (list specific fixes)
- **<70**: BLOCK (escalate to human)

## Constraints

- Do not benefit from implementation chain-of-thought
- Flag workspace boundary violations, unwrap usage, missing tests
- Be specific: cite file paths and line numbers

## Output

Completed `docs/planning_docs/adversarial_review.md` with confidence score and verdict.
