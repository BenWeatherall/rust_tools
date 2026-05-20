# Callback Patterns

## Define in Slint

```slint
callback register-user(string);
callback validate-input(string) -> bool;
```

## Register in Rust (before ui.run())

```rust
ui.on_register_user({
    let ui_weak = ui.as_weak();
    move |name| {
        let ui_weak = ui_weak.clone();
        if let Some(ui) = ui_weak.upgrade() {
            handle_register(&ui, name.as_str());
        }
    }
});
```

## Returning Values

For callbacks with return types, use Slint's generated `invoke_*` in tests:

```rust
ui.invoke_validate_input("test".into());
```

## Thread Safety

Slint UI runs on the main thread. Do not update UI from background threads directly.
Use `slint::invoke_from_event_loop` for cross-thread UI updates.

## Error Display Pattern

```rust
match operation() {
    Ok(val) => ui.set_status_message(format!("Success: {val}").into()),
    Err(e) => ui.set_status_message(format!("Error: {e}").into()),
}
```
