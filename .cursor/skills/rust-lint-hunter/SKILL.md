---
name: rust-lint-hunter
description: >-
  Diagnoses and fixes Rust compiler errors (E0xxx), borrow checker failures,
  and Clippy violations. Use when cargo build or clippy fails, when the user
  reports lifetime errors, or when fixing lint denials like unwrap_used.
---

# Rust Lint Hunter

The Lint Hunter does not guess — it traces compiler output to root causes.

## Workflow

1. Run the failing command and capture full error output.
2. Extract the error code (e.g., `E0502`) from the output.
3. Run `./scripts/explain_error.sh E0502` for rustc explanation.
4. Check [dictionary_of_pain.md](references/dictionary_of_pain.md) for curated fixes.
5. Check [clippy_ai_guardrails.md](references/clippy_ai_guardrails.md) for denied lints.
6. Apply the fix; re-run `./scripts/lint_and_fmt.sh`.

## Scripts

```bash
./scripts/explain_error.sh E0382
./scripts/lint_and_fmt.sh
```

## Common Patterns

| Error | Typical Fix |
|-------|-------------|
| E0502 | Split borrows; clone data; restructure loops |
| E0382 | Use references or clone before move |
| E0597 | Extend lifetime with owned data or restructure scope |
| unwrap_used | Replace with `?` and proper error type |
