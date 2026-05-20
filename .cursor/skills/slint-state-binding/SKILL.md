---
name: slint-state-binding
description: >-
  Manages Slint property bindings, two-way data flow, and callback wiring
  between UI and Rust state. Use when connecting UI inputs to application state,
  implementing two-way binding, or debugging stale UI updates.
---

# Slint State Binding

## Workflow

1. Read [property_binding.md](references/property_binding.md) for binding syntax.
2. Read [callback_patterns.md](references/callback_patterns.md) for event flow.
3. Define properties in `.slint`; read/write from Rust via getters/setters.
4. Use `ui.as_weak()` in callbacks to avoid circular references.

## Binding Types

| Pattern | Slint | Rust |
|---------|-------|------|
| One-way | `text: root.title;` | `ui.set_title(...)` |
| Two-way | `text <=> root.title;` | Auto-synced |
| Callback | `clicked => { root.action(); }` | `ui.on_action(...)` |

## Debugging Stale UI

- Verify callback is registered before `ui.run()`.
- Check weak handle upgrade: `ui_handle.upgrade()` returns `None` if window dropped.
- Confirm property names match between `.slint` and generated Rust API (`get_*` / `set_*`).
