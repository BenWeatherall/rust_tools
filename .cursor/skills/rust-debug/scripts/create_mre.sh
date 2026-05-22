#!/usr/bin/env bash
# Scaffold a minimal reproducible example test module for debugging.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
CRATE="${1:-core_domain}"
TEST_NAME="${2:-reproduces_bug}"

MRE_DIR="$ROOT/$CRATE/tests"
MRE_FILE="$MRE_DIR/mre_${TEST_NAME}.rs"

mkdir -p "$MRE_DIR"

cat > "$MRE_FILE" <<EOF
//! Minimal Reproducible Example — delete or rename when bug is fixed.

#[test]
fn ${TEST_NAME}() {
    // TODO: minimal setup that reproduces the bug
    todo!("Replace with minimal failing case");
}
EOF

echo "Created MRE test: $MRE_FILE"
echo "Run: cargo test -p $CRATE --test mre_${TEST_NAME} -- --nocapture"
