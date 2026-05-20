# SOLID Rust Review Guide

## Single Responsibility

**Red flag**: Generic names like `Manager`, `Handler`, `Utils`.
**Good**: `UserRegistrationValidator`, `InMemoryStorage`.

## Open/Closed

**Red flag**: Large edits to existing core files.
**Good**: New file implementing existing trait.

```rust
// Good — new adapter file
// infrastructure/src/postgres_storage.rs
impl Storage for PostgresStorage { ... }
```

## Liskov Substitution

**Red flag**: Mock/test impl panics where real impl returns errors.
**Good**: All `Storage` impls return `DomainError` variants consistently.

## Interface Segregation

**Red flag**: Trait with 10+ methods when caller uses 1.
**Good**: Focused traits like `Storage` with `save_user` and `find_user`.

## Dependency Inversion

**Red flag**: `ui_application` imports `infrastructure::PostgresStorage`.
**Good**: `ui_application` uses `core_domain::Storage` trait; wiring in `main.rs` or DI module.

## Workspace Boundaries

| Crate | May Depend On |
|-------|---------------|
| `core_domain` | std, error crates only |
| `infrastructure` | `core_domain` |
| `ui_application` | `core_domain`, `infrastructure` (wiring only) |
