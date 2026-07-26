#!/usr/bin/env bash
set -euo pipefail

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [ -z "$REPO" ]; then
    echo "ERRO: nao foi possivel determinar o repositorio. Rode 'gh auth login' primeiro."
    exit 1
fi

SYNCED=0
FAILED=0

echo "=== sync-github ==="
echo "Repo: $REPO"

for ms_file in .planning/PLAN_*/milestone.md; do
    [ -f "$ms_file" ] || continue
    TITLE=$(grep -oP 'title:\s*"\K[^"]+' "$ms_file" || echo "")
    if [ -z "$TITLE" ]; then continue; fi

    if grep -q 'github_id:' "$ms_file" 2>/dev/null; then
        echo "  SKIP milestone: $TITLE (ja sincronizado)"
        continue
    fi

    echo "  Criando milestone: $TITLE"
    if gh api "repos/$REPO/milestones" -f title="$TITLE" --jq '.number' > /tmp/gh_ms_id 2>/dev/null; then
        MS_ID=$(cat /tmp/gh_ms_id)
        echo "github_id: $MS_ID" >> "$ms_file"
        echo "  OK milestone #$MS_ID"
        SYNCED=$((SYNCED + 1))
    else
        echo "  FAIL ao criar milestone: $TITLE"
        FAILED=$((FAILED + 1))
    fi
done

for issue_file in .planning/PLAN_*/issues/issue_*.md; do
    [ -f "$issue_file" ] || continue
    TITLE=$(grep -oP 'title:\s*"\K[^"]+' "$issue_file" || echo "")
    if [ -z "$TITLE" ]; then continue; fi

    if grep -q 'github_issue:' "$issue_file" 2>/dev/null && ! grep -q 'github_issue: null' "$issue_file" 2>/dev/null; then
        echo "  SKIP issue: $TITLE (ja sincronizado)"
        continue
    fi

    MILESTONE=$(grep -oP 'milestone:\s*"\K[^"]+' "$issue_file" || echo "")

    BODY=$(sed -n '/^---$/,/^---$/!p' "$issue_file" | tail -n +2)

    echo "  Criando issue: $TITLE"
    if [ -n "$MILESTONE" ]; then
        ISSUE_URL=$(gh issue create --title "$TITLE" --body "$BODY" --milestone "$MILESTONE" --repo "$REPO" 2>/dev/null || echo "")
    else
        ISSUE_URL=$(gh issue create --title "$TITLE" --body "$BODY" --repo "$REPO" 2>/dev/null || echo "")
    fi

    if [ -n "$ISSUE_URL" ]; then
        ISSUE_NUM=$(echo "$ISSUE_URL" | grep -oP '\d+$')
        sed -i "s/github_issue: null/github_issue: $ISSUE_NUM/" "$issue_file"
        echo "  OK issue #$ISSUE_NUM: $ISSUE_URL"

        TASK_FILE=$(echo "$issue_file" | sed 's|issues/issue_|tasks/task_|' | sed 's|\.md$|.md|')
        if [ -f "$TASK_FILE" ]; then
            sed -i "s|issue: .*|issue: $ISSUE_URL|" "$TASK_FILE"
        fi

        SYNCED=$((SYNCED + 1))
    else
        echo "  FAIL ao criar issue: $TITLE"
        FAILED=$((FAILED + 1))
    fi
done

echo "=== $SYNCED sincronizados, $FAILED falhas ==="
exit $FAILED
