# SR8: Context Hooks

## Scope

Context survival across compaction via Cursor hooks.

## Delivered

- `.cursor/hooks.json`:
  - `preCompact` → `pre_compact.sh` — saves to `session_state.json`
  - `sessionStart` → `session_start.sh` — injects restored context
  - `afterFileEdit` → `remind_lint.sh` — lint reminder for `.rs`/`.slint`

## State Schema

```json
{
  "saved_at": "ISO8601",
  "current_prd_step": "string",
  "pending_checklist": ["string"],
  "recent_decisions": [],
  "active_skill": "string"
}
```

## Validation

Hooks are executable. Test via Cursor Hooks output channel on session events.
