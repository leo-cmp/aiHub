#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

setup_repo() {
  local repo_dir="$1"
  local origin_dir="$2"

  git init -b main "$repo_dir" >/dev/null
  git -C "$repo_dir" config user.name "aiHub Test"
  git -C "$repo_dir" config user.email "aihub-test@example.com"

  mkdir -p "$repo_dir/.ai/guidelines/stacks"
  printf "# CodeIgniter 4\n" > "$repo_dir/.ai/guidelines/stacks/codeigniter4.md"
  git -C "$repo_dir" add .ai/guidelines/stacks/codeigniter4.md
  git -C "$repo_dir" commit -m "docs: estado inicial" >/dev/null

  git init --bare --initial-branch=main "$origin_dir" >/dev/null
  git -C "$repo_dir" remote add origin "$origin_dir"
  git -C "$repo_dir" push -u origin main >/dev/null
}

install_fake_gh() {
  local bin_dir="$1"
  local log_file="$2"

  mkdir -p "$bin_dir"
  cat > "$bin_dir/gh" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "$log_file"
exit 0
EOF
  chmod +x "$bin_dir/gh"
}

test_submit_prompts_branch_uses_default_message_and_limits_commit_scope() {
  local repo_dir="$TMP_DIR/repo"
  local origin_dir="$TMP_DIR/origin.git"
  local bin_dir="$TMP_DIR/bin"
  local gh_log="$TMP_DIR/gh.log"

  setup_repo "$repo_dir" "$origin_dir"
  install_fake_gh "$bin_dir" "$gh_log"

  git -C "$repo_dir" checkout -b wip/local-edits >/dev/null
  printf "\n- Usa verbos HTTP reais.\n" >> "$repo_dir/.ai/guidelines/stacks/codeigniter4.md"
  mkdir -p "$repo_dir/.ai/guidelines/core"
  printf "# Nova guideline\n" > "$repo_dir/.ai/guidelines/core/nova.md"

  (
    cd "$repo_dir"
    printf 'docs/atualizar-codeigniter4\n\n' | PATH="$bin_dir:$PATH" "$ROOT_DIR/scripts/git-submit.sh" >/dev/null
  )

  local current_branch
  current_branch="$(git -C "$repo_dir" branch --show-current)"
  [ "$current_branch" = "docs/atualizar-codeigniter4" ] || fail "branch atual inesperada: $current_branch"

  local subject
  subject="$(git -C "$repo_dir" log -1 --pretty=%s)"
  [ "$subject" = "docs: atualizar diretrizes do aiHub" ] || fail "mensagem default inesperada: $subject"

  local changed_files
  changed_files="$(git -C "$repo_dir" diff-tree --no-commit-id --name-only -r HEAD | sort)"
  [ "$changed_files" = $'.ai/guidelines/core/nova.md\n.ai/guidelines/stacks/codeigniter4.md' ] || fail "arquivos commitados fora do esperado: $changed_files"

  git -C "$repo_dir" rev-parse --verify origin/docs/atualizar-codeigniter4 >/dev/null ||
    fail "branch nao foi enviada para origin"

  grep -qx 'pr create --base main --fill' "$gh_log" ||
    fail "gh pr create nao foi chamado com base main"
}

test_submit_aborts_without_guidelines_changes() {
  local repo_dir="$TMP_DIR/repo-empty"
  local origin_dir="$TMP_DIR/origin-empty.git"
  local bin_dir="$TMP_DIR/bin-empty"
  local gh_log="$TMP_DIR/gh-empty.log"

  setup_repo "$repo_dir" "$origin_dir"
  install_fake_gh "$bin_dir" "$gh_log"

  (
    cd "$repo_dir"
    if AIHUB_BRANCH_NAME="docs/sem-mudancas" AIHUB_COMMIT_MSG="docs: sem mudancas" PATH="$bin_dir:$PATH" "$ROOT_DIR/scripts/git-submit.sh" >/dev/null 2>&1; then
      fail "comando deveria falhar sem mudancas em .ai/guidelines"
    fi
  )
}

test_submit_aborts_with_changes_outside_guidelines() {
  local repo_dir="$TMP_DIR/repo-outside"
  local origin_dir="$TMP_DIR/origin-outside.git"
  local bin_dir="$TMP_DIR/bin-outside"
  local gh_log="$TMP_DIR/gh-outside.log"

  setup_repo "$repo_dir" "$origin_dir"
  install_fake_gh "$bin_dir" "$gh_log"

  printf "mudanca fora do escopo\n" > "$repo_dir/README.md"

  (
    cd "$repo_dir"
    if AIHUB_BRANCH_NAME="docs/com-mudanca-fora" AIHUB_COMMIT_MSG="docs: fora" PATH="$bin_dir:$PATH" "$ROOT_DIR/scripts/git-submit.sh" >/dev/null 2>&1; then
      fail "comando deveria falhar com mudancas fora de .ai/guidelines"
    fi
  )
}

test_submit_prompts_branch_uses_default_message_and_limits_commit_scope
test_submit_aborts_without_guidelines_changes
test_submit_aborts_with_changes_outside_guidelines

echo "scripts/test-git-submit.sh: ok"
