# Clippy AI Guardrails

Workspace-enforced lints that agents must not bypass.

## Denied (build fails)

| Lint | Rule |
|------|------|
| `clippy::unwrap_used` | No `.unwrap()` — use `?` with proper error types |
| `clippy::expect_used` | No `.expect()` — use `?` with proper error types |
| `rust::unsafe_code` | No `unsafe` blocks |
| `rust::missing_docs` | All public items documented (library crates) |

## Warned

| Lint | Rule |
|------|------|
| `clippy::pedantic` | Strict idiomatic Rust |
| `rust::unused_crate_dependencies` | Keep Cargo.toml lean |

## Agent Workflow

After every file modification:

```bash
./scripts/lint_and_fmt.sh
```

If Clippy denies a lint, fix the root cause — do not add `#[allow(...)]` unless Slint-generated code requires it.

## UI Crate Exception

`ui_application` allows `missing_docs`, `unwrap_used`, and `expect_used` for Slint-generated code only via crate-level attributes in `main.rs`.
