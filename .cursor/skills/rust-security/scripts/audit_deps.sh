#!/usr/bin/env bash
# Audit workspace dependencies for known vulnerabilities.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"

if command -v cargo-audit >/dev/null 2>&1; then
  cargo audit
elif command -v cargo >/dev/null 2>&1 && cargo audit --version >/dev/null 2>&1; then
  cargo audit
else
  echo '{"status":"skipped","reason":"cargo-audit not installed. Install: cargo install cargo-audit"}'
  exit 0
fi
