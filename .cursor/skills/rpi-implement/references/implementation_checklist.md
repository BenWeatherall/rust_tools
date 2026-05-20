# Implementation Checklist

Per-step verification before marking complete:

- [ ] Step matches approved plan item (no scope creep)
- [ ] Code compiles: `cargo check --workspace`
- [ ] Lints pass: `./scripts/lint_and_fmt.sh`
- [ ] Tests pass: `./scripts/test_json.sh`
- [ ] Public APIs documented (library crates)
- [ ] No new `.unwrap()` or `.expect()` in library code
- [ ] Workspace boundaries respected (no cross-crate violations)
- [ ] Progress log updated in `implementation_plan.md`
- [ ] Quality gate run: `./scripts/quality_gate.sh`

## After All Steps

- [ ] Full orchestration review: `./scripts/orchestrate_review.sh`
- [ ] Critic review via `@adversarial-review` if score threshold not met
