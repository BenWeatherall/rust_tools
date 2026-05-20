#!/usr/bin/env bash
# Scaffold a new workspace member crate.
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: init_project.sh <crate_name>" >&2
  exit 1
fi

CRATE="$1"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
CRATE_DIR="$ROOT/$CRATE"

if [ -d "$CRATE_DIR" ]; then
  echo "Crate directory already exists: $CRATE_DIR" >&2
  exit 1
fi

mkdir -p "$CRATE_DIR/src"
cat > "$CRATE_DIR/Cargo.toml" <<EOF
[package]
name = "$CRATE"
version.workspace = true
edition.workspace = true
license.workspace = true
description = "TODO: describe this crate"

[lints]
workspace = true

[dependencies]
EOF

cat > "$CRATE_DIR/src/lib.rs" <<EOF
//! $CRATE crate.

/// Placeholder for crate initialization.
pub fn placeholder() {}
EOF

echo "Created $CRATE_DIR"
echo "Add \"$CRATE\" to workspace members in root Cargo.toml"
