---
name: rust-syntax-fix
description: >-
  Fixes pre-typecheck Rust syntax errors including missing semicolons, mismatched
  braces, turbofish syntax, and lifetime annotation issues. Use when the compiler
  reports parse errors before type checking begins.
---

# Rust Syntax Fix

## Workflow

1. Run `./.cursor/skills/rust-syntax-fix/scripts/check_syntax.sh [crate]` for JSON parse errors.
2. Read the parse error line number and message.
3. Check [syntax_pitfalls.md](references/syntax_pitfalls.md) for the pattern.
4. Fix syntax only — do not refactor logic during syntax fixes.
5. Re-run `check_syntax.sh` to confirm parse succeeds.

## Common Fixes

| Error | Fix |
|-------|-----|
| `expected ;` | Add semicolon after expression statement |
| `unexpected closing delimiter` | Match braces/parens; check macro invocations |
| `expected lifetime parameter` | Add `'a` annotation or use owned types |
| `cannot find type X in this scope` | Add import or fix typo |

## Slint-Specific

- `.slint` files use different syntax — do not apply Rust fixes to Slint markup.
- Slint parse errors reference `.slint` line numbers; edit the UI file, not generated Rust.
