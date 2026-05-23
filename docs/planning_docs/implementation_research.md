# Implementation Research

> Research phase — no `.rs` or `.slint` source edits.

## Feature Summary

Review the Rust Cursor Agent Foundation workspace and identify additional developer-facing capabilities that should be available when building desktop applications with Slint. The goal is a prioritized feature inventory grounded in the current codebase, Slint 1.16 APIs, and industry desktop-app patterns (Tauri, Electron, Slint's own desktop roadmap).

This research covers both the explicitly requested window-mode features (edge resize with redraw, minimize/maximize/close) and a broader gap analysis for a reusable desktop developer toolkit.

## Current Architecture Findings

### Workspace Members

| Member | Role today | Desktop relevance |
|--------|-----------|-------------------|
| `core_domain/` | Pure business logic: `Storage`, `User`, `UserRegistrationValidator`, `DomainError` | No desktop/window concepts yet. Settings persistence and app-lifecycle traits would belong here. |
| `infrastructure/` | `InMemoryStorage` adapter | No file-based settings, tray, or notification adapters yet. |
| `ui_application/` | Slint entry point, `AppWindow`, one demo view | Minimal window config; no custom chrome, no window-control wiring, no responsive layout hooks. |

### Current UI / Window State

`AppWindow` is a standard Slint `Window` with **native OS decorations** (default `no-frame: false`):

- Fixed `preferred-width: 480px`, `preferred-height: 320px`
- **Native title bar** with minimize, maximize/restore, and close — provided and wired by Slint/winit; no custom Rust callbacks required
- **Edge resize** handled by the window manager; Slint receives resize events and updates root `width`/`height` automatically
- No `min-width` / `max-width` constraints
- No `on_close_requested` handler in Rust (optional pattern for confirm-before-close)
- Content (`RegisterView`) uses fixed padding; layout could be improved for very small/large sizes

`main.rs` wires one callback (`register-user`) and runs the event loop. Programmatic window API (`set_minimized`, etc.) is only needed for custom chrome or tray-driven show/hide — not for standard desktop use.

### Relevant Traits and Types

**Existing (unchanged by window work):**

- `Storage` — persistence contract in `core_domain`
- `DomainError` — domain error enum
- `User` / `UserId` / `UserRegistrationValidator` — demo domain types

**Proposed (not yet present):**

- `SettingsStore` — trait for persisting window geometry, theme, and user prefs (DIP: UI depends on trait, infrastructure implements file/JSON store)
- Optional Slint components: `AppShell` layout wrapper, menu bar scaffold — **not** custom title bar/window controls (native decorations are sufficient for this foundation)

### Slint 1.16 Desktop APIs Available Now

From [Slint Window reference](https://docs.slint.dev/latest/docs/slint/reference/window/window/) and [Rust Window API](https://docs.slint.dev/latest/docs/rust/slint/struct.Window):

| Capability | Slint support | Notes |
|-----------|---------------|-------|
| Edge resize + redraw | Native via winit backend | OS resize dispatches resize events; Slint updates root `width`/`height`. No manual redraw needed if layout uses relative sizing. |
| `no-frame` + `resize-border-width` | Built-in | Frameless windows with OS-managed edge resize hit targets. |
| Minimize / maximize | `Window::set_minimized`, `set_maximized` | Available since Slint PR #4581 on winit/Qt backends. |
| Close | `Window::on_close_requested` → `CloseRequestResponse` | Allows confirm-before-close. |
| Window icon | `Window.icon` property | Taskbar/title bar icon. |
| Menu bar | `MenuBar` element | Declarative menus; shortcut support improving in Slint 1.13+. |
| Full-screen | `full-screen` property | Disables resize and title bar. |
| Title-bar drag (frameless) | `Window::start_dragging()` via winit | Requires `slint` feature `unstable-winit-030` or `with_winit_window` escape hatch. |
| System tray | **Not in Slint 1.16** | Slint roadmap item #6053; today use external crates (`tray-icon`, `ksni`). |
| Native notifications | **Not built-in** | Use `notify-rust` or platform crates via infrastructure adapter. |
| Modal dialogs | In progress upstream | PR #8135; not stable in 1.16. |
| Cross-app drag & drop | Experimental | Gated behind `SLINT_ENABLE_EXPERIMENTAL_FEATURES=1`. |
| Settings persistence | **Not built-in** | Application responsibility; pattern from Tauri plugin-store, `slint-ui-templates` settings module. |

### Agent / Developer Infrastructure Already Present

The repo already delivers strong **agent workflow** features (RPI pipeline, 10 Cursor skills, quality gates, context hooks) and **basic native desktop window behavior** via Slint defaults. What is still missing:

- Settings persistence adapter
- Menu bar / About dialog scaffold (including Slint license attribution)
- Optional lifecycle hooks (`on_close_requested` pattern)
- OS integration adapters (tray, notifications, file dialogs)
- Documented desktop patterns in skills/docs (when to use native chrome vs custom)

## Gap Analysis: Recommended Developer Features

Features are tiered by how essential they are for a credible desktop app foundation.

### P0 — Window Shell (**already provided by Slint native decorations**)

These were the original feature request items. With default `no-frame: false`, Slint/winit provides them out of the box — **no custom implementation required** for this foundation.

| Feature | Status | Notes |
|---------|--------|-------|
| Edge resize with live redraw | ✅ Native | OS resize handles + Slint layout update on `width`/`height` change |
| Minimize / maximize / close | ✅ Native | OS title bar; programmatic API available only if needed later (tray, etc.) |
| Custom title bar | ❌ Not needed | Only for branded/frameless apps; document as optional pattern, not foundation default |
| Window min/max size | ⚠️ Optional polish | Add `min-width`/`min-height` on `Window` if demo content clips at small sizes |
| Close confirmation hook | ⚠️ Optional pattern | `on_close_requested` when apps have unsaved state — not required for demo |
| Responsive content layout | ⚠️ Optional polish | Improve layout if resize testing shows clipping; native resize already works |

**Revised decision:** Keep **native OS decorations** as the foundation default. Custom frameless chrome is an opt-in pattern for apps that need branded title bars, not a prerequisite for desktop development in this repo.

### P1 — Application Lifecycle & Persistence (implement first)

| Feature | Rationale | Implementation approach |
|---------|-----------|---------------------------|
| Window geometry restore | Users expect size/position to persist | `AppSettings` struct + JSON file adapter in `infrastructure`; load on startup via `invoke_from_event_loop`, save on close/resize debounce. |
| Graceful shutdown | Clean resource release | Close handler flushes settings, returns `HideWindow`. |
| Single-instance guard (optional) | Prevent duplicate app instances | `single-instance` crate or file lock in `infrastructure`; document as optional pattern. |
| Application icon | Branding in taskbar/dock | `Window.icon` + bundled asset; document in README. |
| About dialog | License attribution (Slint royalty-free license requires it) | Simple Slint dialog component; link from Help menu. |

### P1 — Desktop UX Primitives

| Feature | Rationale | Implementation approach |
|---------|-----------|---------------------------|
| Light / dark theme | Standard desktop expectation | Slint `StyleMetrics` or custom palette properties; persist choice via settings store. |
| Menu bar skeleton | File/Edit/Help menus | Slint `MenuBar` in `AppWindow`; stub menu items agents can extend. |
| Keyboard shortcuts | Power-user productivity | Slint 1.13+ `FocusScope` + `@keys(...)` macro on root window; document in skill reference. |
| Status / toast feedback | Operation feedback beyond inline badge | Extend existing `StatusBadge` pattern or add transient toast component. |

### P2 — OS Integration (via infrastructure adapters)

Slint does not yet provide these natively. Wrap external crates behind traits in `core_domain`, implement in `infrastructure`, wire from `ui_application`.

| Feature | Rationale | External dependency | Notes |
|---------|-----------|----------------------|-------|
| System tray | Background apps, quick access | `tray-icon` (cross-platform) or `ksni` (Linux) | Slint #6053 may supersede; keep adapter swappable. |
| Desktop notifications | Async task completion alerts | `notify-rust` | Trait `NotificationSender` in core_domain. |
| Native file dialogs | Open/save workflows | `rfd` | Trait `FileDialog` in core_domain. |
| Auto-start on login | Utility apps | Platform-specific; document only initially | Defer implementation. |

### P3 — Track Slint Upstream (document, don't build yet)

Slint's [Making Slint Desktop-Ready](https://slint.dev/blog/making-slint-desktop-ready) blog (Oct 2025) lists features in active development. Document these for developers; implement when stable in Slint:

- Rich text in `Text` elements (#9560)
- Improved keyboard shortcuts in menus (#102)
- Cross-window drag & drop (#1967)
- Modal windows / dialogs (#6607, PR #8135)
- Real popup windows (#1143, #6000)
- Tooltips (#6446)
- Native system tray (#6053)
- Two-way bindings for models (#814, #2013)

Reference implementation: [`slint-ui-templates`](https://docs.rs/slint-ui-templates) crate provides AppShell, settings, theme, and platform chrome — worth studying but likely too heavy to depend on directly for this foundation.

## Cross-Crate Impact Analysis

| Change | `core_domain` | `infrastructure` | `ui_application` |
|--------|--------------|-------------------|------------------|
| P0 window shell | None | None | **No work needed** — native Slint decorations |
| P1 settings | New `AppSettings` type + `SettingsStore` trait | `JsonSettingsStore` adapter | Load/save on startup/shutdown |
| P1 theme | Theme enum in settings | Persist in JSON | Slint palette bindings |
| P2 tray/notifications | Traits only | Crate adapters | Callback wiring, optional feature flags |
| Demo domain (User/Storage) | Unchanged | Unchanged | Unaffected |

**DIP preserved:** UI never imports tray/notification crates directly; it calls traits implemented in infrastructure. Window control stays in UI layer because it is pure presentation/window-manager concern, not business logic.

**LSP note:** Mock settings store must behave like real store (same serialization, same defaults).

## Constraints

- [x] No UI crate imports from `infrastructure/` beyond approved adapters (settings store injection at startup)
- [x] Extend via new trait implementations rather than editing core domain demo logic
- [x] All public APIs require documentation under strict Clippy rules
- [x] Frameless resize on Windows had historical winit bugs; use Slint 1.16's built-in `resize-border-width` rather than manual `set_size` loops (avoids shake artifacts per [slint#6273](https://github.com/slint-ui/slint/discussions/6273))
- [x] Wayland may not support programmatic window position; document limitation, don't rely on position restore on Linux Wayland
- [x] `unstable-winit-030` is an explicit opt-in feature; document in README when enabled

## Open Questions

1. **Milestone 1 scope:** Proceed with P1 (settings persistence + menu bar + About dialog), or add only lightweight polish (min-size constraints, responsive layout)?
2. **P2 OS integration:** Include tray + notifications in the next milestone, or defer until P1 is validated?
3. **Slint license attribution:** Royalty-free license requires Slint attribution in About dialog — include in P1 menu bar work?
4. **Minimum supported window size:** What `min-width`/`min-height` for the demo app (suggest 360×240)?
5. **Custom chrome documentation:** Add an optional reference doc/skill section for frameless apps, or skip entirely?

## Research Artifacts

- Codebase analysis: `docs/planning_docs/research_report.json`
- Dependency tree: `cargo tree --workspace` (Slint 1.16.1 → winit backend with accesskit)
- Key source files reviewed:
  - `ui_application/ui/app-window.slint` — bare Window, no chrome
  - `ui_application/src/main.rs` — single callback, no window API
  - `core_domain/src/storage.rs` — existing DIP pattern to mirror for settings
- External references:
  - [Slint Window reference](https://docs.slint.dev/latest/docs/slint/reference/window/window/)
  - [Slint Rust Window API](https://docs.slint.dev/latest/docs/rust/slint/struct.Window)
  - [Slint desktop-ready roadmap blog](https://slint.dev/blog/making-slint-desktop-ready)
  - [Slint frameless resize discussion #6273](https://github.com/slint-ui/slint/discussions/6273)
  - [Slint system tray discussion #933](https://github.com/slint-ui/slint/discussions/933)
  - [slint-ui-templates settings module](https://docs.rs/slint-ui-templates/latest/slint_ui_templates/settings/index.html)
