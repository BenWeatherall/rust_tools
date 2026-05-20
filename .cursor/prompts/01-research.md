# Research Phase Prompt

Use with `@rpi-research` skill.

## Task

Research the following feature request **without modifying any source code**:

> [DESCRIBE FEATURE HERE]

## Instructions

1. Run `./.cursor/skills/rpi-research/scripts/analyze_codebase.sh`
2. Identify affected workspace members: `core_domain`, `infrastructure`, `ui_application`
3. Document trait interfaces and cross-crate impacts
4. Write findings to `docs/planning_docs/implementation_research.md`

## Constraints

- Do NOT edit `.rs` or `.slint` files
- List open questions requiring human approval
- Reference existing traits before proposing new ones

## Output

A completed `docs/planning_docs/implementation_research.md` ready for the Plan phase.
