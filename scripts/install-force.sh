#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-.}"
rm -rf "$TARGET/.agents" "$TARGET/.mcp.json"
exec "$(dirname "$0")/install.sh" "$TARGET"
