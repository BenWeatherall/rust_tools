#!/usr/bin/env bash
# Runs formatting and Clippy checks across the workspace.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> cargo fmt --check"
cargo fmt --all --check

echo "==> cargo clippy --workspace"
cargo clippy --workspace --all-targets -- -D warnings

echo "All lint and format checks passed."
