---
name: rust-security
description: >-
  Audits Rust code for unsafe blocks, hardcoded secrets, and vulnerable
  dependencies. Use when reviewing security, before commits, or when the user
  mentions unsafe, credentials, or cargo audit.
---

# Rust Security

## Workflow

1. Search for `unsafe`, `password`, `secret`, `api_key`, `token` in the codebase.
2. Review [unsafe_checklist.md](references/unsafe_checklist.md) for any unsafe blocks.
3. Run `./scripts/audit_deps.sh` for dependency vulnerabilities.
4. Verify no secrets are committed (check `.env`, config files).

## Hard Rules

- `unsafe_code` is denied at workspace level — no exceptions without human approval.
- Never log secrets or include them in error messages.
- Use environment variables for credentials, never hardcode.

## Scripts

```bash
./scripts/audit_deps.sh
```
