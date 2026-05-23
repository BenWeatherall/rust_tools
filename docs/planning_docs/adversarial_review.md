# Adversarial Review

## Confidence Score: 92/100

## Critical Issues

None. All Milestone 1 PRD items are implemented; quality gate passes (clippy, tests, UI build).

## Architectural Concerns

1. **File → Exit bypasses settings flush** (`ui_application/src/main.rs:34–40`): The menu Exit path calls `ui.window().hide()` directly and does not invoke `handle_close_requested` or `persist_window_settings`. The title-bar close button saves geometry; menu Exit does not. Users who exit via the menu will lose window-size persistence until they use the close button at least once in a session.

2. **Composition root couples UI to concrete store** (`ui_application/src/main.rs:18`): `JsonSettingsStore` is constructed directly in `main.rs`. This matches the approved research constraint (“settings store injection at startup”) but means swapping adapters requires editing the binary entry point. Acceptable for a foundation scaffold; consider a small bootstrap/factory module if multiple adapters are added later.

3. **Silent error suppression** (`ui_application/src/main.rs:38, 79`): `.ok()` on `hide()` and `invoke_from_event_loop` swallows failures. For a desktop shell this is tolerable (best-effort restore/save) but logging on schedule failure would aid debugging.

## Suggestions

1. Unify exit paths: have `request-exit` call the same persistence logic as `on_close_requested`, then `hide()` or `quit_event_loop()`.
2. Add a unit test for `capture_window_settings` / `persist_window_settings` using a mock `SettingsStore` if those helpers grow beyond the entry point.
3. Document in README that settings live at `~/.config/rust-agent-foundation/settings.json` and that Wayland may not restore window position (already noted in code comment at `main.rs:93–94`).

## Checklist Summary

| Area | Result |
|------|--------|
| PRD scope (P1 scaffolding, no custom chrome) | Pass |
| SOLID / DIP (`SettingsStore` trait, infra adapter) | Pass |
| Security (no `unsafe`, no secrets) | Pass |
| Tests (settings round-trip, missing file defaults) | Pass |
| Slint layout in `.slint`, callbacks use weak handles | Pass |
| Non-goals respected | Pass |

## Verdict: APPROVE

Milestone 1 deliverables match the approved plan. The menu Exit / settings divergence is a minor UX gap suitable for a follow-up fix, not a merge blocker.
