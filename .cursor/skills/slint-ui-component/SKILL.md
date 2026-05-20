---
name: slint-ui-component
description: >-
  Creates and edits Slint UI components with declarative .slint markup separated
  from Rust logic. Use when building UI layouts, adding Slint widgets, creating
  new views, or working with ui_application/ui/ files.
---

# Slint UI Component Development

## Workflow

1. Read [slint_layout_rules.md](references/slint_layout_rules.md) and [component_patterns.md](references/component_patterns.md).
2. Edit `.slint` files in `ui_application/ui/` for layout and appearance.
3. Edit `.rs` files for business logic and callback handlers.
4. Build with `./scripts/build_ui.sh`.
5. Run `./scripts/lint_and_fmt.sh` after Rust changes.

## Separation of Concerns

| Layer | Location | Responsibility |
|-------|----------|----------------|
| Declarative UI | `ui_application/ui/*.slint` | Layout, styling, bindings |
| Logic | `ui_application/src/*.rs` | Callbacks, domain calls, state |

## Scripts

```bash
./scripts/build_ui.sh
./scripts/run_headless.sh   # requires display or xvfb
```

## Hard Rules

- Import widgets: `import { Button, LineEdit, VerticalBox } from "std-widgets.slint";`
- Never import `infrastructure/` from UI code.
- Use callbacks to bridge UI events to Rust.
