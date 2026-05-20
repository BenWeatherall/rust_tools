# Minimal Reproducible Example (MRE) Workflow

## Steps

1. **Isolate**: Reproduce the bug in the smallest possible test or binary.
2. **Remove**: Strip unrelated code until the bug still reproduces.
3. **Pin**: Write a failing test that captures the bug.
4. **Fix**: Solve the root cause.
5. **Verify**: Confirm the test passes and no regressions.

## Wolf-Fence Binary Search

When the bug location is unknown:

1. Disable half the suspect code path.
2. If bug persists, the cause is in the active half.
3. Repeat until the exact line is identified.

## Slint MRE Template

```rust
#[test]
fn callback_updates_state() {
    let ui = AppWindow::new().unwrap();
    ui.invoke_register_user("test".into());
    assert_eq!(ui.get_status_message().as_str(), "expected");
}
```

Extract failing logic into `core_domain` unit tests when possible to avoid UI dependencies.
