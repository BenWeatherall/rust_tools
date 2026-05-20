# Slint Component Patterns

## Reusable Component

```slint
// ui/components/status-badge.slint
export component StatusBadge {
    in property <string> message: "";
    in property <color> color: #333333;

    Rectangle {
        background: color;
        border-radius: 4px;
        padding: 8px;

        Text {
            text: message;
            color: white;
        }
    }
}
```

Import in parent:

```slint
import { StatusBadge } from "components/status-badge.slint";
```

## Root Window Pattern

```slint
import { Button, VerticalBox } from "std-widgets.slint";

export component AppWindow inherits Window {
    title: "App Title";
    preferred-width: 480px;
    preferred-height: 320px;

    callback action-triggered(string);
    in-out property <string> status-message: "";

    VerticalBox { /* content */ }
}
```

## Rust Handler Pattern

```rust
ui.on_action_triggered({
    let ui_handle = ui.as_weak();
    move |value| {
        if let Some(ui) = ui_handle.upgrade() {
            match do_action(value.as_str()) {
                Ok(msg) => ui.set_status_message(msg.into()),
                Err(e) => ui.set_status_message(format!("Error: {e}").into()),
            }
        }
    }
});
```
