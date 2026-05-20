# Agent Orchestration Guide

This repository uses a Research → Plan → Implement (RPI) workflow with multi-agent validation.

## Roles

| Role | Actor | Responsibility |
|------|-------|----------------|
| **Executor** | Default Cursor agent | Writes code, implements UI, generates tests |
| **Validator** | `./scripts/quality_gate.sh` | Deterministic fmt/clippy/test checks (JSON output) |
| **Critic** | Fresh agent with `@adversarial-review` skill | Reviews git diff against PRD; scores 0–100 |

## Skill Roster

### Core Rust

| Skill | When to Use |
|-------|-------------|
| `rust-core` | New modules, idiomatic Rust, error handling patterns |
| `rust-lint-hunter` | Compiler errors (E0xxx), borrow checker failures |
| `rust-syntax-fix` | Pre-typecheck syntax errors |
| `rust-debug` | Runtime bugs, state issues, MRE workflow |
| `rust-security` | `unsafe` audit, secrets, dependency audit |

### Slint UI

| Skill | When to Use |
|-------|-------------|
| `slint-ui-component` | Creating/editing `.slint` components and layouts |
| `slint-state-binding` | Property bindings, callbacks, UI↔Rust state |

### Workflow

| Skill | When to Use |
|-------|-------------|
| `rpi-research` | Phase 1: codebase analysis (no code edits) |
| `rpi-implement` | Phase 3: atomic implementation steps |
| `adversarial-review` | Post-implementation Critic review |

## Workflow Gates

```
Research → [approval] → Plan → [approval] → Implement → Validator → Critic → Merge
```

1. Run research with `@rpi-research`; output to `docs/planning_docs/implementation_research.md`.
2. Create plan in `docs/planning_docs/implementation_plan.md`; get approval.
3. Implement one step at a time with `@rpi-implement`.
4. Run `./scripts/orchestrate_review.sh` before considering a step complete.
5. If Critic score < 90, address feedback in `docs/planning_docs/adversarial_review.md`.

## Quick Commands

```bash
./scripts/lint_and_fmt.sh          # Format + Clippy
./scripts/quality_gate.sh          # Full validation (JSON)
./scripts/orchestrate_review.sh    # Validator + Critic handoff
```

## Context Survival

Session state persists across compaction via hooks in `.cursor/hooks/`.
State file: `docs/planning_docs/session_state.json`.
