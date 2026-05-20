# Unsafe Code Checklist

`unsafe_code` is **denied** in this workspace. If human approval is granted:

- [ ] Document why safe Rust cannot achieve the goal
- [ ] Minimize the unsafe block scope
- [ ] Document all invariants the caller must uphold
- [ ] Add safety comments for every unsafe operation
- [ ] Add tests covering the unsafe path
- [ ] Get Critic review via `@adversarial-review`

## Secret Scan Targets

Search patterns:
- `password`, `secret`, `api_key`, `token`, `credential`
- Hardcoded URLs with auth parameters
- `.env` files tracked in git

## Dependency Audit

Run `cargo audit` before every PR. Address advisories or document accepted risk.
