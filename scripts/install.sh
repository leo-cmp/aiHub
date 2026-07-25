#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TARGET="${1:-..}"

echo "=== aiHub install ==="
echo "Target: $TARGET"

mkdir -p "$TARGET/.ai/guidelines/domain/business-rules"
mkdir -p "$TARGET/.ai/decisions"
mkdir -p "$TARGET/.claude"

ln -sfn .aihub/src/AGENTS.md "$TARGET/AGENTS.md"
ln -sfn .aihub/src/AGENTS.md "$TARGET/CLAUDE.md"

for f in CODEX.md COPILOT.md ANTIGRAVITY.md; do
    if [ -L "$TARGET/$f" ]; then rm -f "$TARGET/$f"; fi
done

ln -sfn ../.aihub/src/.ai/roles "$TARGET/.ai/roles"
ln -sfn ../../.aihub/src/.ai/guidelines/core "$TARGET/.ai/guidelines/core"
ln -sfn ../../.aihub/src/.ai/guidelines/stacks "$TARGET/.ai/guidelines/stacks"
ln -sfn ../../.aihub/src/.ai/guidelines/domain "$TARGET/.ai/guidelines/domain"
ln -sfn ../../.aihub/src/.ai/templates "$TARGET/.ai/templates"

if [ ! -d "$TARGET/.agents" ]; then
    cp -r "$ROOT_DIR/src/.agents" "$TARGET/.agents"
fi

ln -sfn ../.agents/skills "$TARGET/.claude/skills"

if [ ! -f "$TARGET/.mcp.json" ]; then
    cp "$ROOT_DIR/src/.mcp.json" "$TARGET/.mcp.json"
fi

if [ ! -f "$TARGET/.ai/project.md" ]; then
    cat > "$TARGET/.ai/project.md" << 'EOF'
# Novo Projeto

## Ambiente e Estrutura
- **Localização:** Os arquivos rodam diretamente na raiz.
- **Idioma da UI:** pt-BR

## Stack
- Backend: 
- Database: 
EOF
fi

if [ ! -f "$TARGET/.ai/stack.md" ]; then
    cat > "$TARGET/.ai/stack.md" << 'EOF'
# Stacks do Projeto

Consulte as diretrizes específicas em:
- [Laravel](file:///.ai/guidelines/stacks/laravel.md)
EOF
fi

if [ -f "$TARGET/.gitignore" ]; then
    if ! grep -q "^\.aihub" "$TARGET/.gitignore"; then
        printf "\n# aiHub\n.aihub/\n" >> "$TARGET/.gitignore"
    fi
fi

echo "=== aiHub instalado com sucesso ==="
echo "Versão: $(cat "$ROOT_DIR/VERSION")"
