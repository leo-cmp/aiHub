# Versionamento do aiHub

## Contexto

O aiHub não tem hoje nenhum mecanismo de versionamento: não existem tags git nem arquivo de versão. O Makefile já oferece `git-update` (sincroniza a `main` local com `origin/main` via `reset --hard` e reinstala os links simbólicos no projeto pai) e o trio `git-branch`/`git-push`/`git-pr` para contribuições via PR.

O objetivo desta spec é definir como o aiHub passa a ter uma versão SemVer rastreável, como ela é calculada e publicada, e como dois comandos novos/alterados do Makefile (`make check` e `make git-update`) expõem essa informação ao usuário.

## Convenção de versionamento

- Esquema: **SemVer** (`MAJOR.MINOR.PATCH`, ex.: `1.4.2`).
- Fonte de verdade: arquivo `VERSION` na raiz do repositório, contendo apenas o número (ex.: `1.4.2`, sem prefixo `v`, sem linha em branco extra).
- Cada release é marcada por uma **tag git anotada** `vMAJOR.MINOR.PATCH` (ex.: `v1.4.2`), criada no mesmo commit em que o `VERSION` é atualizado. Arquivo e tag nascem juntos — nunca um sem o outro.
- O bump (patch/minor/major) é calculado automaticamente a partir dos commits feitos desde a última tag, usando a convenção de [Conventional Commits](https://www.conventionalcommits.org/) já adotada no projeto (`.ai/guidelines/core/git-pr.md`):
  - Qualquer commit com `BREAKING CHANGE:` no corpo/rodapé → **major**.
  - Senão, qualquer commit `feat:` → **minor**.
  - Senão, qualquer commit `fix:`, `perf:` ou `refactor:` → **patch**.
  - Se só houver `docs:`, `chore:`, `test:`, `style:`, `build:` ou `ci:` desde a última tag → **nenhum bump** (nada a fazer).
- Se não existir nenhuma tag ainda no repositório, a versão de partida é `0.0.0` (ou seja, o primeiro release calculado parte daí).

### Bootstrap inicial

O arquivo `VERSION` ainda não existe no repositório. Como parte da implementação desta spec (não de uma execução futura do `make release`), cria-se o arquivo `VERSION` com o conteúdo `0.0.0` junto do commit que introduz os comandos novos do Makefile. Isso garante que `make check` e `make git-update` sempre tenham um `VERSION` para ler, mesmo antes da primeira tag real ser publicada.

## `make release`

Comando manual, executado localmente depois que uma ou mais PRs já foram mergeadas na `main`. Não há CI configurado no projeto, então este comando é o ponto único e explícito de corte de versão.

Passos:

1. Sincroniza a base local: `git fetch origin && git checkout main && git pull --ff-only origin main` (mesmo padrão de segurança usado em `git-branch`).
2. Descobre a última tag publicada via `git describe --tags --abbrev=0` (ou assume `0.0.0` se não houver nenhuma tag no histórico).
3. Lista os commits entre a última tag e `HEAD` e classifica conforme a regra de bump acima.
4. Se não houver bump a aplicar, imprime `Nada releasable desde v<X.Y.Z>.` e termina sem alterar nada.
5. Caso contrário, calcula a nova versão, sobrescreve o `VERSION`, cria um commit `chore: bump version to <X.Y.Z>` diretamente na `main` (exceção explícita e única ao fluxo normal de branch+PR — só ocorre dentro deste comando), cria a tag anotada `v<X.Y.Z>` com a lista dos commits incluídos como mensagem, e publica com `git push origin main --tags`.
6. Imprime `Release v<X.Y.Z> criada e publicada (bump: <major|minor|patch>).`

## `make check`

Comando de leitura, seguro para rodar em qualquer branch (não faz fetch destrutivo, checkout, nem altera arquivos):

1. Lê a versão local instalada a partir do `VERSION` em `HEAD`.
2. Roda `git ls-remote --tags origin`, filtra as refs que casam o padrão `vX.Y.Z` (descartando o sufixo `^{}` que `ls-remote` retorna para tags anotadas dereferenciadas), ordena por SemVer e identifica a maior.
3. Compara e imprime um dos três casos:
   - Igual → `aiHub está atualizado (v<X.Y.Z>).`
   - Tag remota maior → `Nova versão disponível: v<X.Y.Z> (atual: v<A.B.C>). Rode 'make git-update' para atualizar.`
   - Versão local maior que qualquer tag remota (ex.: `make release` rodado mas ainda sem push, ou branch de feature com `VERSION` não publicado) → `Versão local (v<X.Y.Z>) ainda não publicada como tag remota.`

## `make git-update`

Mantém o comportamento atual (fetch + checkout `main` + `reset --hard origin/main` + reinstala links simbólicos via `make install`) e adiciona, ao final, a leitura do `VERSION` pós-reset, imprimindo:

```
aiHub atualizado com sucesso! Versão atual: v<X.Y.Z>
```

## Fora de escopo

- Integração com GitHub Releases ou `gh release` — a fonte de "última versão" é a tag git, não uma release do GitHub.
- Automação via CI/GitHub Actions — o corte de release é manual (`make release`), e pode ser promovido a workflow automatizado em uma iteração futura sem mudar a lógica de cálculo do bump.
- Changelog automático (`CHANGELOG.md`) — não foi pedido; pode ser uma extensão futura usando a mesma lista de commits classificados pelo `make release`.
