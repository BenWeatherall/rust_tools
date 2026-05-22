# Slint Layout Rules

## File Organization

```
ui_application/
├── ui/
│   ├── app-window.slint      # Root window
│   ├── components/           # Reusable components
│   └── views/                # Screen-level views
├── src/
│   └── main.rs               # Entry point, callbacks
└── build.rs                  # Slint compile step
```

## Layout Containers

- `VerticalBox` / `HorizontalBox` — standard layout (from std-widgets)
- Set `padding` and `spacing` on containers, not individual items
- Use `alignment` for centering content

## Properties

```slint
in-out property <string> title: "Default";
in property <int> count: 0;        // read-only from Rust
out property <bool> confirmed;      // write-only to Rust
```

## Callbacks

```slint
callback submit(string);
callback item-selected(int) -> bool;
```

Register in Rust:

```rust
ui.on_submit({ move |value| { /* handle */ } });
```

## Styling

- Use hex colors: `#666666`
- Font sizes as `font-size: 24px;`
- Prefer Slint properties over inline styles for themeable values
