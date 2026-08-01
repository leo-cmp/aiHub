#!/usr/bin/env bash
set -euo pipefail

GUIDELINES_PATH=".ai/guidelines"
DEFAULT_COMMIT_MESSAGE="docs: atualizar diretrizes do l-nexus"

die() {
  echo "Erro: $*" >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" ||
  die "este comando precisa ser executado dentro de um repositorio Git."

cd "$repo_root"

[ -d "$GUIDELINES_PATH" ] ||
  die "diretorio '$GUIDELINES_PATH' nao encontrado."

git show-ref --verify --quiet refs/heads/main ||
  die "branch local 'main' nao encontrada. Crie ou atualize a main local antes de continuar."

git remote get-url origin >/dev/null ||
  die "remote 'origin' nao configurado."

command -v gh >/dev/null ||
  die "GitHub CLI 'gh' nao encontrado."

guidelines_changes="$(git status --porcelain --untracked-files=all -- "$GUIDELINES_PATH"/)"
[ -n "$guidelines_changes" ] ||
  die "nenhuma alteracao encontrada em '$GUIDELINES_PATH/'."

outside_changes="$(
  git status --porcelain --untracked-files=all |
    awk '
      {
        path = $0
        sub(/^.../, "", path)
        if (path !~ /^\.ai\/guidelines(\/|$)/) {
          print $0
        }
      }
    '
)"

if [ -n "$outside_changes" ]; then
  echo "Foram encontradas alteracoes fora de '$GUIDELINES_PATH/':" >&2
  echo "$outside_changes" >&2
  die "limpe ou guarde essas alteracoes antes de enviar apenas guidelines."
fi

branch_name="${AIHUB_BRANCH_NAME:-}"
if [ -z "$branch_name" ]; then
  printf "Nome da branch (ex: docs/atualizar-codeigniter4): "
  read -r branch_name || true
fi

[ -n "$branch_name" ] ||
  die "nome da branch nao pode ficar vazio."

commit_message="${AIHUB_COMMIT_MSG:-}"
if [ -z "$commit_message" ]; then
  printf "Mensagem de commit [%s]: " "$DEFAULT_COMMIT_MESSAGE"
  read -r commit_message || true
fi

if [ -z "$commit_message" ]; then
  commit_message="$DEFAULT_COMMIT_MESSAGE"
fi

start_branch="$(git branch --show-current)"
[ -n "$start_branch" ] ||
  die "HEAD destacado nao suportado por este fluxo."

stash_created=0
stash_ref="stash@{0}"

restore_stash_on_error() {
  local code=$?

  if [ "$stash_created" -eq 1 ]; then
    echo "Falha antes de aplicar as alteracoes. Restaurando '$GUIDELINES_PATH/' na branch original..." >&2
    git checkout "$start_branch" >/dev/null 2>&1 || true
    git stash pop --index "$stash_ref" >/dev/null 2>&1 || git stash apply --index "$stash_ref" >/dev/null 2>&1 || true
  fi

  exit "$code"
}

trap restore_stash_on_error ERR

echo "Guardando alteracoes de '$GUIDELINES_PATH/'..."
git stash push -u -m "l-nexus git-submit guidelines" -- "$GUIDELINES_PATH" >/dev/null
stash_created=1

echo "Trocando para a branch local 'main' sem atualizar do remoto..."
git checkout main >/dev/null

echo "Criando branch '$branch_name' a partir da main local..."
git checkout -b "$branch_name" >/dev/null

trap - ERR

echo "Aplicando alteracoes em '$branch_name'..."
if ! git stash pop --index "$stash_ref" >/dev/null; then
  echo "Erro: houve conflito ao aplicar as alteracoes em '$branch_name'." >&2
  echo "Resolva o conflito manualmente e continue com git add/commit/push/PR." >&2
  exit 1
fi
stash_created=0

git add "$GUIDELINES_PATH"

if git diff --cached --quiet -- "$GUIDELINES_PATH"; then
  die "nenhuma alteracao em '$GUIDELINES_PATH/' ficou preparada para commit."
fi

echo "Criando commit..."
git commit -m "$commit_message"

echo "Enviando branch para origin..."
git push -u origin HEAD

echo "Criando Pull Request contra main..."
gh pr create --base main --fill

echo "Fluxo concluido."
