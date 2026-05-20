# Idiomatic Rust Patterns

## Newtype Pattern

```rust
pub struct UserId(String);

impl UserId {
    pub fn new(value: String) -> Result<Self, DomainError> { /* validate */ }
    pub fn as_str(&self) -> &str { &self.0 }
}
```

## Trait Extension (OCP)

Create a new file implementing an existing trait rather than modifying core logic:

```rust
// infrastructure/src/postgres_storage.rs
impl Storage for PostgresStorage { /* ... */ }
```

## Collections

- `Vec<T>` for ordered sequences; pre-allocate with `Vec::with_capacity(n)`.
- `HashMap<K, V>` for key-value lookups.

## Async (when needed)

- Prefer `tokio` runtime; use `tokio::sync::Mutex` for async contexts, not `std::sync::Mutex`.
- Never hold locks across `.await` points.
