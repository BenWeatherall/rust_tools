#!/usr/bin/env bash
# Explain a Rust compiler error code using rustc --explain.
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: explain_error.sh E0xxx" >&2
  exit 1
fi

CODE="$1"
rustc --explain "$CODE" 2>/dev/null || {
  echo "Could not explain $CODE. Check https://doc.rust-lang.org/error_codes/$CODE.html"
  exit 1
}
