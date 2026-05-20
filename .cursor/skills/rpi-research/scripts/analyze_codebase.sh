#!/usr/bin/env bash
# Structural codebase analysis for RPI research phase.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"

echo "=== Workspace Members ==="
grep -E '^members' Cargo.toml || true

echo ""
echo "=== Dependency Tree ==="
cargo tree --workspace 2>/dev/null || echo "(cargo tree unavailable)"

echo ""
echo "=== Rust Source Files ==="
find . -name "*.rs" -not -path "./target/*" | sort

echo ""
echo "=== Slint UI Files ==="
find . -name "*.slint" -not -path "./target/*" | sort

echo ""
echo "=== Public Traits ==="
rg "pub trait " --type rust -g '!target/**' || true

echo ""
echo "=== Agent Skills ==="
ls -1 .cursor/skills/ 2>/dev/null || true

if command -v codedna >/dev/null 2>&1; then
  echo ""
  echo "=== CodeDna Analysis ==="
  codedna . 2>/dev/null || true
fi
