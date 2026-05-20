---
name: rust-core
description: >-
  Writes idiomatic Rust with explicit types, newtypes, thiserror/anyhow error
  handling, and SOLID module boundaries. Use when creating new Rust modules,
  structs, traits, or implementing core domain logic in core_domain/.
---

# Rust Core

## Workflow

1. Identify the target workspace member (`core_domain`, `infrastructure`, or `ui_application`).
2. Read [idiomatic_rust.md](references/idiomatic_rust.md) for patterns.
3. Implement with explicit types, newtype wrappers, and documented public APIs.
4. Run `./scripts/check_workspace.sh` from this skill directory.

## Hard Rules

- No `.unwrap()` or `.expect()` in library code.
- Extend via new trait implementations; do not edit large core files.
- Use `thiserror` for library errors, `anyhow` for binary error propagation.
- Every public item must have doc comments.

## Error Handling

See [error_handling.md](references/error_handling.md).

## Scripts

```bash
# Verify workspace compiles
./scripts/check_workspace.sh

# Scaffold a new workspace member (interactive)
./scripts/init_project.sh <crate_name>
```
