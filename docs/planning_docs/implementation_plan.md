# Implementation Plan

> Living specification for the Plan phase of the RPI workflow.
> Implementation must not begin until this plan is approved.

## Approval Gate

- [x] **APPROVED** — Human engineer or supervisory agent sign-off required

## Product Requirements

### Goal

Deliver **desktop developer scaffolding** that adds value beyond what Slint already provides natively. Native OS window decorations (title bar, minimize/maximize/close, edge resize) are **already working** in this repo and require no custom implementation.

**Milestone 1 (this plan):** P1 developer features — settings persistence, menu bar scaffold, About dialog, optional lifecycle hooks, and layout polish.

**Documented roadmap (later milestones):** P2 OS integration (tray, notifications, file dialogs) via infrastructure traits; P3 features tracked against Slint upstream.

### Non-Goals

- Custom frameless title bar or window control buttons (Slint native decorations are sufficient)
- `unstable-winit-030` or `window_controls.rs` module
- Replacing Slint with Tauri or another framework
- Cross-application drag & drop (wait for Slint upstream)
- Modal dialog system (wait for Slint PR #8135 to stabilize)
- Mobile or web targets
- Changing demo domain logic (`User`, `Storage`, registration flow) beyond layout adjustments
- Bundling/packaging/installer creation (document separately later)

## Architecture Decisions

| Decision | Choice | SOLID rationale |
|----------|--------|-----------------|
| Window chrome | **Native OS decorations** (Slint default) | Slint/winit already provides title bar, controls, and resize. No duplication. |
| Custom chrome | Document only as optional pattern | For apps needing branded title bars; not part of foundation default. |
| Settings | `SettingsStore` trait in `core_domain`, JSON adapter in `infrastructure` | **DIP:** UI depends on trait, not filesystem. |
| Lifecycle hooks | `on_close_requested` in `main.rs` when settings flush needed | **SRP:** Close handler owns shutdown sequence; optional confirm dialog later. |
| OS integration (P2, deferred) | Traits in `core_domain`, adapters in `infrastructure` | **ISP:** Small traits (`NotificationSender`, `FileDialog`) not one mega DesktopService. |

## Step Checklist

### Milestone 1 — P1 Desktop Developer Scaffolding

- [x] **Step 1 — Window constraints and layout polish**
  - Add `min-width` / `min-height` on `AppWindow` to prevent unusably small windows
  - Adjust `RegisterView` layout if resize testing shows clipping at small/large sizes
  - **Validation:** Manual resize from all edges; content remains usable; native controls still work unchanged

- [x] **Step 2 — Settings persistence**
  - Add `AppSettings` type and `SettingsStore` trait in `core_domain`
  - Add `JsonSettingsStore` adapter in `infrastructure`
  - Load settings on startup; save window geometry on close (best-effort; document Wayland position limitation)
  - **Validation:** Unit tests for settings round-trip; manual test that window size persists across restarts

- [x] **Step 3 — Close lifecycle hook**
  - Register `on_close_requested` in `main.rs` to flush settings before exit
  - Structure supports future confirm-before-close (return `HideWindow` by default)
  - **Validation:** Close button saves settings; app exits cleanly

- [x] **Step 4 — Menu bar and About dialog**
  - Add Slint `MenuBar` to `AppWindow` (File/Help stubs agents can extend)
  - Add About dialog component with Slint royalty-free license attribution
  - **Validation:** Menu renders; About dialog opens and displays attribution

- [x] **Step 5 — Quality gate and manual acceptance**
  - Run `./scripts/lint_and_fmt.sh` and `./scripts/quality_gate.sh`
  - Manual checklist: native resize/controls unchanged, settings persist, menu/About work
  - **Validation:** Quality gate passes; manual checklist documented in progress log

### Future Milestones (not in scope until Milestone 1 approved and complete)

| Milestone | Features | Primary crate |
|-----------|----------|---------------|
| M2 — P1 UX | Theme toggle (light/dark), keyboard shortcut examples | `ui_application` |
| M3 — P2 OS Integration | `NotificationSender`, system tray adapter, `FileDialog` trait | `core_domain`, `infrastructure` |
| M4 — P3 Upstream | Adopt Slint native tray, modals, tooltips when stable | `ui_application` |
| Optional | Custom frameless chrome reference (document-only or example branch) | `ui_application` |

## Active Skill

`@rpi-implement` with `@slint-ui-component`, `@slint-state-binding`, `@rust-core` as needed per step.

## Testing Strategy

| Layer | Approach |
|-------|----------|
| Compile | `cargo check --workspace` each step |
| Lint | `./scripts/lint_and_fmt.sh` after each step |
| Unit | Settings store round-trip tests in `core_domain` / `infrastructure` |
| Integration | Manual window interaction checklist (Step 5) |
| Quality gate | `./scripts/quality_gate.sh` on Step 5 |
| Critic | `./scripts/orchestrate_review.sh` after Step 5; score ≥ 90 required |

## Rollback Plan

Each step is independently revertible via git. Settings persistence can be disabled by reverting Step 2–3 without affecting native window behavior.

## Progress Log

| Date | Step | Status | Notes |
|------|------|--------|-------|
| 2026-05-23 | Research | Complete | Feature inventory in `implementation_research.md` |
| 2026-05-23 | Plan v1 | Superseded | P0 custom chrome plan rejected — native Slint decorations sufficient |
| 2026-05-23 | Plan v2 | Approved | Milestone 1 scoped to P1 developer scaffolding |
| 2026-05-23 | Step 1 | Complete | min-width/min-height 360×240; RegisterView fills window with centered form and bottom status |
| 2026-05-23 | Step 2 | Complete | AppSettings/SettingsStore in core_domain; JsonSettingsStore in infrastructure; load on startup |
| 2026-05-23 | Step 3 | Complete | `on_close_requested` flushes settings via `handle_close_requested`; returns `HideWindow` for future confirm hook |
| 2026-05-23 | Step 4 | Complete | MenuBar with File/Help stubs; `AboutDialog` PopupWindow with `AboutSlint` widget; Exit via `request-exit` callback |
| 2026-05-23 | Step 5 | Complete | Quality gate passed (clippy, tests, UI build); Critic 92/100 APPROVE; manual checklist below |

### Step 5 Manual Acceptance Checklist

| Item | Verification |
|------|----------------|
| Native resize/controls unchanged | Code: no `no-frame`, no custom chrome; Slint default `Window` with `min-width`/`min-height` only |
| Window min size enforced | Code: `AppWindow` 360×240 min; `RegisterView` responsive layout with centered form |
| Settings load on startup | Code: `JsonSettingsStore::load()` + `apply_window_settings` via event loop |
| Settings save on title-bar close | Code: `on_close_requested` → `persist_window_settings` |
| Settings round-trip | Automated: `infrastructure` unit tests `round_trips_settings`, `load_returns_defaults_when_missing` |
| Menu bar renders | Code: `MenuBar` with File/Help in `app-window.slint` |
| About dialog + Slint attribution | Code: `AboutDialog` uses `AboutSlint` widget; Help → About opens popup |
| File → Exit | Code: `request-exit` → `hide()` (note: does not flush settings — see adversarial review) |
| Lint/format | `./scripts/lint_and_fmt.sh` passed |
| Full quality gate | `./scripts/quality_gate.sh` passed |
