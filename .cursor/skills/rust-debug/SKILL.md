---
name: rust-debug
description: >-
  Debugs runtime and logic bugs in Rust applications using minimal reproducible
  examples, wolf-fence binary search, and structured logging. Use when tests
  pass but behavior is wrong, when investigating state bugs, or when UI actions
  produce unexpected results.
---

# Rust Debug

## Workflow

1. Create a **Minimal Reproducible Example** (MRE) — see [mre_workflow.md](references/mre_workflow.md).
2. Use wolf-fence: comment out half the code, identify which half contains the bug, repeat.
3. Add `dbg!()` at state transition points (remove before finishing).
4. Run `cargo test --workspace -- --nocapture` for failing test output.
5. Fix root cause; remove all debug instrumentation.

## UI-Specific

- Log callback invocations in Rust handlers before domain logic.
- Verify Slint property bindings with `ui.get_*()` / `ui.set_*()` in tests.
- Check that weak handles (`as_weak()`) are upgraded before use.

## Do Not

- Add `println!` permanently — use structured logging or remove after debugging.
- Patch symptoms (extra clones) without understanding the root cause.
