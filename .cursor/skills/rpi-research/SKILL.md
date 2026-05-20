---
name: rpi-research
description: >-
  Performs codebase research for the RPI workflow without modifying source code.
  Use at the start of a feature request, when analyzing architecture impact, or
  when the user asks to research before implementing.
---

# RPI Research Phase

## Constraints

- **Do NOT modify** any `.rs` or `.slint` files during research.
- Output findings to `docs/planning_docs/implementation_research.md`.

## Workflow

1. Run `./scripts/analyze_codebase.sh` for structural analysis.
2. Read [research_template.md](references/research_template.md) for output format.
3. Identify affected workspace members and trait interfaces.
4. Document cross-crate impacts (UI state → domain logic).
5. List open questions requiring human approval.

## Analysis Commands

```bash
./scripts/analyze_codebase.sh
cargo tree --workspace
```

## Output Location

Write to: `docs/planning_docs/implementation_research.md`

Use the template sections: Feature Summary, Architecture Findings, Cross-Crate Impact, Constraints, Open Questions.
