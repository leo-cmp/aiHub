#!/usr/bin/env bash
set -euo pipefail
SRC="${1:-.}"
ERRORS=0
TMP=$(mktemp)

cleanup() { rm -f "$TMP"; }
trap cleanup EXIT

echo "=== aiHub validate ==="

extract_skills_from_section() {
    sed -n '/^## Skills/,/^##/p' "$1" | grep -oP '(?<=\`)[a-z0-9-]+(?=\`)' || true
}

echo "--- Checking skill references in roles ---"
if [ -d "$SRC/.ai/roles" ]; then
    for role in "$SRC/.ai/roles/"*.md; do
        [ -f "$role" ] || continue
        extract_skills_from_section "$role" | while read -r skill; do
            if [ -d "$SRC/.agents/skills/$skill" ]; then
                echo "  OK: $skill (referenced in $(basename "$role"))"
            else
                echo "  MISSING: $skill referenced in $(basename "$role")"
                echo "1" >> "$TMP"
            fi
        done
    done
else
    echo "  WARNING: $SRC/.ai/roles directory not found"
fi

echo "--- Checking guideline references ---"
if [ -d "$SRC/.ai" ]; then
    find "$SRC/.ai" -name "*.md" -print0 2>/dev/null | while IFS= read -r -d '' file; do
        (grep -oP '\.ai/guidelines/[^)\s]+\.md' "$file" 2>/dev/null || true) | while read -r ref; do
            if [ ! -f "$SRC/$ref" ]; then
                echo "  BROKEN LINK: $ref referenced in $(basename "$file")"
                echo "1" >> "$TMP"
            fi
        done
    done
else
    echo "  WARNING: $SRC/.ai directory not found"
fi

echo "--- Checking for contradictions in AGENTS.md ---"
if [ -f "$SRC/AGENTS.md" ]; then
    if grep -q "NUNCA SUPONHA" "$SRC/AGENTS.md" 2>/dev/null; then
        echo "  WARNING: 'NUNCA SUPONHA' found — consider replacing with affirmative instruction"
    fi
else
    echo "  WARNING: $SRC/AGENTS.md not found"
fi

echo "--- Checking template references ---"
if [ -f "$SRC/.ai/guidelines/core/planning.md" ]; then
    (grep -oP '\.ai/templates/[^)\s]+\.md' "$SRC/.ai/guidelines/core/planning.md" 2>/dev/null || true) | while read -r ref; do
        if [ -f "$SRC/$ref" ]; then
            echo "  OK: $ref"
        else
            echo "  MISSING: $ref referenced in planning.md"
            echo "1" >> "$TMP"
        fi
    done
fi

ERRORS=$(wc -l < "$TMP")
echo "=== $ERRORS errors found ==="
exit "$ERRORS"
