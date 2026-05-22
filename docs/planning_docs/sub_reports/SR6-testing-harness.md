# SR6: Testing Harness

## Scope

Machine-readable test and UI validation with JSON output.

## Delivered

| Script | Output |
|--------|--------|
| `scripts/test_json.sh` | `{"phase":"test","passed":bool,"failures":[]}` |
| `scripts/run_ui_tests.sh` | `{"phase":"ui","passed":bool,...}` |
| `scripts/quality_gate.sh` | Aggregated JSON report |

## Notes

- Nightly Rust enables libtest JSON via `-Z unstable-options --format json`
- Stable fallback parses `cargo test` output
- `agent-browser` optional when `AGENT_BROWSER_URL` is set (wasm/web targets)

## Validation

```bash
./scripts/quality_gate.sh
```
