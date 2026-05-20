# Critic Review Checklist

## Correctness

- [ ] Logic matches PRD requirements
- [ ] Edge cases handled (empty input, not-found, duplicates)
- [ ] Error paths propagate correctly with context

## Architecture (SOLID)

- [ ] Single Responsibility: each struct/module has one reason to change
- [ ] Open/Closed: extended via new files, not modified core logic
- [ ] Liskov: trait implementations honor contracts
- [ ] Interface Segregation: traits are focused, not bloated
- [ ] Dependency Inversion: UI depends on traits, not concrete infra

## Security

- [ ] No `unsafe` blocks
- [ ] No hardcoded secrets
- [ ] No `.unwrap()` / `.expect()` in library code

## Slint UI

- [ ] Layout in `.slint`, logic in `.rs`
- [ ] No infrastructure imports in UI crate
- [ ] Callbacks use weak handles appropriately

## Testing

- [ ] New behavior has tests
- [ ] Tests use `Result` return, not `expect()`

## Documentation

- [ ] Public APIs documented in library crates
- [ ] Plan progress log updated
