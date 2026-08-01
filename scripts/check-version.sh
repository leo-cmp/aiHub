#!/usr/bin/env bash
set -euo pipefail

LOCAL_VERSION=$(cat VERSION)
LOCAL_TAG="v$LOCAL_VERSION"

REMOTE_LATEST=$(git ls-remote --tags origin \
	| awk '{print $2}' \
	| sed -e 's#refs/tags/##' -e 's/\^{}$//' \
	| { grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' || true; } \
	| sort -uV \
	| tail -1)

if [ -z "$REMOTE_LATEST" ]; then
	echo "Versao local: $LOCAL_TAG. Nenhuma tag publicada no remoto ainda."
	exit 0
fi

HIGHEST=$(printf '%s\n%s\n' "$LOCAL_TAG" "$REMOTE_LATEST" | sort -V | tail -1)

if [ "$LOCAL_TAG" = "$REMOTE_LATEST" ]; then
	echo "l-nexus esta atualizado ($LOCAL_TAG)."
elif [ "$HIGHEST" = "$REMOTE_LATEST" ]; then
	echo "Nova versao disponivel: $REMOTE_LATEST (atual: $LOCAL_TAG). Rode 'make git-update' para atualizar."
else
	echo "Versao local ($LOCAL_TAG) ainda nao publicada como tag remota."
fi
