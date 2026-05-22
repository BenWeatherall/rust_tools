# SR8: Context Hooks

## Scope

Context survival across compaction via Cursor hooks.

## Delivered

- `.cursor/hooks.json`:
  - `preCompact` → `pre_compact.sh` — saves feature request, pipeline phase, plan steps, progress notes, and active skill to `session_state.json`
  - `sessionStart` → `session_start.sh` — injects restored context
  - `afterFileEdit` → `remind_lint.sh` — lint reminder for `.rs`/`.slint`

## State Schema

```json
{
  "saved_at": "ISO8601",
  "feature_request": "string",
  "pipeline_phase": "research | plan | awaiting_approval | implement | review | complete",
  "current_prd_step": "string",
  "pending_checklist": ["string"],
  "recent_decisions": [],
  "active_skill": "string"
}
```

`pipeline_phase` is derived on compaction from plan progress unless explicitly set (e.g. by `/develop-feature` or `pipeline_init.sh`).

## Validation

Hooks are executable. Test via Cursor Hooks output channel on session events.
