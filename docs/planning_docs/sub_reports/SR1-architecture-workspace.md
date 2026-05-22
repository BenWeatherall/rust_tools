# SR1: Architecture and Workspace

## Scope

Cargo workspace with SOLID boundaries and Slint UI scaffold.

## Delivered

- Workspace members: `core_domain`, `infrastructure`, `ui_application`
- `core_domain`: `Storage` trait, `User`/`UserId`, `UserRegistrationValidator`, `DomainError`
- `infrastructure`: `InMemoryStorage` implementing `Storage`
- `ui_application`: Slint `AppWindow` with `ui/components/`, `ui/views/`, register-user callback
- `docs/planning_docs/` templates for RPI workflow

## Validation

```bash
cargo check --workspace
cargo build -p ui_application
```

## Agent Context

Agents fixing UI bugs should load only `ui_application/`. Domain changes stay in `core_domain/`.
