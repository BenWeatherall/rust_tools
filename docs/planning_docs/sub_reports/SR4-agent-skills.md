# SR4: Agent Skills

## Scope

Brain-Tool-Context skill triad in `.cursor/skills/`.

## Delivered (10 skills)

### Core Rust
- `rust-core` — idiomatic patterns, `init_project.sh`, `check_workspace.sh`
- `rust-lint-hunter` — compiler errors, `explain_error.sh`, dictionary of pain
- `rust-debug` — MRE workflow, `create_mre.sh`
- `rust-security` — `audit_deps.sh`, unsafe checklist
- `rust-syntax-fix` — pre-typecheck syntax fixes, `check_syntax.sh`

### Slint UI
- `slint-ui-component` — layout, `build_ui.sh`
- `slint-state-binding` — property/callback patterns, `verify_bindings.sh`

### Workflow
- `rpi-research` — JSON `analyze_codebase.sh`, no code edits
- `rpi-implement` — step execution with validation
- `adversarial-review` — Critic persona, `generate_review_context.sh`

## Validation

Each skill has `SKILL.md` with YAML frontmatter and trigger-rich `description`.
