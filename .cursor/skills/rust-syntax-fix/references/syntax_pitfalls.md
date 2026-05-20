# Syntax Pitfalls

## Missing Semicolons

```rust
// BAD — last expression in block without semicolon when statement expected
let x = {
    do_something()
    another_thing()  // missing ;
};

// GOOD
let x = {
    do_something();
    another_thing()
};
```

## Turbofish

```rust
let v = Vec::<String>::new();
let parsed = "42".parse::<i32>()?;
```

## Lifetime Annotations

```rust
// When compiler asks for lifetime on struct fields:
struct Holder<'a> {
    data: &'a str,
}
```

## Macro Delimiters

Ensure `{}`, `()`, `[]` are balanced. Common failure in nested `quote!` or `slint!` macros.

## Import Paths

```rust
use core_domain::{Storage, User, UserId};
use crate::module::Type;  // within same crate
```
