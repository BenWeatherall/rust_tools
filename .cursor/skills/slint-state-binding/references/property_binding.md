# Property Binding Reference

## Declaration

```slint
in-out property <string> name: "default";
in-out property <int> count: 0;
in-out property <bool> enabled: true;
```

## One-Way Binding

```slint
Text { text: root.name; }
LineEdit { text <=> root.name; }  // two-way
```

## Rust Access

Generated API (from `AppWindow`):

```rust
let current = ui.get_name();
ui.set_name("new value".into());
```

## Model-View Separation

Keep domain state in Rust structs; mirror to Slint properties at boundaries:

```rust
fn sync_ui(ui: &AppWindow, state: &AppState) {
    ui.set_status_message(state.message.clone().into());
}
```

Do not duplicate business logic in Slint callbacks — delegate to Rust functions.
