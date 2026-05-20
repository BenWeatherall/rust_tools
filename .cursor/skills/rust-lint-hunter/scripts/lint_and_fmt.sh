#!/usr/bin/env bash
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)/scripts/lint_and_fmt.sh"
