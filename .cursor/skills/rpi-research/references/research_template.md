# Research Output Template

Copy this structure into `docs/planning_docs/implementation_research.md`:

## Feature Summary

One paragraph describing the requested change.

## Current Architecture Findings

### Workspace Members

List each member and its role in this feature.

### Relevant Traits and Types

List trait interfaces, newtypes, and error types involved.

## Cross-Crate Impact Analysis

How UI state changes might affect core domain logic.

## Constraints

- [ ] No UI crate imports from infrastructure beyond approved adapters
- [ ] Extend via new trait implementations
- [ ] Public APIs require documentation

## Open Questions

Items requiring human approval before planning.

## Research Artifacts

Links to script output, grep results, dependency tree.
