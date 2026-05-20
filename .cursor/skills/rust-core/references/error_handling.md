# Error Handling Architecture

## Library Crates (`core_domain`, `infrastructure`)

Use `thiserror` for typed, composable errors:

```rust
#[derive(Debug, Error, PartialEq, Eq)]
pub enum DomainError {
    #[error("user not found: {0}")]
    UserNotFound(String),
}
```

## Binary Crates (`ui_application`)

Use `anyhow` for context-rich propagation:

```rust
fn main() -> Result<()> {
    let user = load_user(&id).context("failed to load user")?;
    Ok(())
}
```

## Rules

- Every error must carry provenance via `.context()` or structured variants.
- Never use raw `String` or `&str` as error types.
- Map domain errors to UI messages at the boundary, not deep in logic.
