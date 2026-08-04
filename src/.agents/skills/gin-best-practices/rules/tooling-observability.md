# Tooling e Observabilidade

## Descoberta do Projeto

Antes de executar comandos, verificar:

- Versao Go em `go.mod` e `toolchain` quando presente.
- Workspace em `go.work`.
- Targets em `Makefile`, `Taskfile.yml` ou scripts.
- Configuracoes de sqlc, linter e geracao.
- Ambiente descrito pelo projeto.

Preferir wrapper versionado pelo repositorio a comando paralelo inventado.

## Dependencias e Geracao

- Adicionar dependencia com `go get` na raiz correta do modulo.
- Executar `go mod tidy` depois de mudanca real de imports.
- Nao rodar upgrade amplo para adicionar uma unica dependencia.
- Manter `//go:generate` pequeno e deterministico quando adotado.
- Executar `sqlc generate` depois de alterar query, schema ou config.
- Revisar diff de codigo gerado; mudanca inesperada sinaliza schema, ordem ou
  versao incorreta.

## Formatacao e Analise

Base obrigatoria:

```bash
go fmt ./...
go vet ./...
go test ./...
```

Quando configurados no projeto:

```bash
goimports -w .
staticcheck ./...
golangci-lint run
```

- Usar a configuracao versionada do linter.
- Nao instalar linter global ou alterar versao sem verificar convenção.
- Nao ignorar diagnostico com comentario sem justificar a excecao especifica.

## Logs Estruturados

- Usar `log/slog` ou logger estruturado ja adotado.
- Injetar logger; evitar logger global mutavel.
- Incluir request ID, metodo, rota normalizada, status e duracao no access log.
- Registrar erro interno uma vez no limite que possui contexto para agir.
- Usar nivel coerente: erro esperado de cliente nao deve poluir logs como falha
  interna.
- Evitar path bruto com IDs como label de metrica; usar rota normalizada.
- Redigir secrets e dados pessoais antes do log.

## Metricas

Medir pelo menos:

- Requests por rota, metodo e status.
- Latencia por rota.
- Panics e erros internos.
- Latencia e erro de queries ou pool.
- Uso e espera do pgxpool.
- Timeout e erro de dependencia externa.
- Saturacao de workers ou filas quando existirem.

Manter cardinalidade limitada. Nunca usar user ID, email, token, URL completa ou
mensagem de erro livre como label.

## Tracing

- Propagar context da request.
- Preservar trace headers ao chamar dependencia.
- Criar spans em limites relevantes, sem instrumentar cada funcao pequena.
- Nao adicionar payload sensivel a atributos.
- Evitar registrar o mesmo erro em cada camada.

## Health e Readiness

- Liveness indica se processo responde; nao precisa consultar todas as
  dependencias.
- Readiness indica se instancia pode receber trafego.
- Usar prazo curto em checks de dependencia.
- Retornar resposta minima e nao expor DSN, versao interna ou detalhes de erro.
- Testar transicao para not ready durante startup e shutdown.

## Build e CI

Pipeline minimo:

```bash
go build ./...
go vet ./...
go test ./...
sqlc generate
git diff --exit-code
```

Se o projeto nao versionar codigo gerado, adaptar a verificacao sem exigir
worktree limpo. Adicionar `go test -race ./...` em job com toolchain compativel.
