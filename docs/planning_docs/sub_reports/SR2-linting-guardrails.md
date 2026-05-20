# SR2: Linting Guardrails

## Scope

Strict Clippy and rustfmt enforcement for AI-generated code.

## Delivered

- Workspace `[lints]` in root `Cargo.toml`
- `clippy.toml` with MSRV and config
- `scripts/lint_and_fmt.sh` — fmt check + clippy with `-D warnings`
- Reference doc: `.cursor/skills/rust-lint-hunter/references/clippy_ai_guardrails.md`

## Denied Lints

| Lint | Level |
|------|-------|
| `clippy::unwrap_used` | deny |
| `clippy::expect_used` | deny |
| `rust::unsafe_code` | deny |
| `rust::missing_docs` | deny (library crates) |

## Validation

```bash
./scripts/lint_and_fmt.sh
```
