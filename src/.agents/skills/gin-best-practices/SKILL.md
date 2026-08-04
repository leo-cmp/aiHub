---
name: gin-best-practices
description: >
  Aplicar ao escrever, revisar ou refatorar APIs Go com Gin. Usar em handlers,
  DTOs, rotas, middleware, services, tratamento de erros, sqlc, pgx,
  PostgreSQL, migrations Goose, concorrencia, seguranca, observabilidade,
  graceful shutdown e testes de codigo Gin.
---

# Gin Best Practices

Aplicar boas praticas de APIs Gin com SQL explicito, dependencias claras e
comportamento verificavel. Confirmar versoes em `go.mod` e configuracoes locais
antes de usar uma API especifica.

## Consistencia Primeiro

Examinar `go.mod`, `sqlc.yaml`, comandos em `Makefile` ou `Taskfile`, pacotes
vizinhos e testes existentes. Preservar convencoes equivalentes do repositorio.
Nao adicionar outro router, driver, migrator, logger ou validador quando o
projeto ja resolver a mesma responsabilidade de forma coerente.

Tratar estas regras como padroes para projetos novos e como criterios de revisao
em projetos existentes, nao como ordem para reorganizar todo o repositorio.

## Regras por Tema

| Tema | Arquivo | Carregar para |
|---|---|---|
| Arquitetura | `rules/architecture.md` | Pacotes, dependencias, services, interfaces e erros de dominio |
| HTTP | `rules/http.md` | Handlers, DTOs, binding, rotas, middleware e respostas |
| Banco e sqlc | `rules/database-sqlc.md` | Queries, pgx, transacoes, migrations e performance |
| Seguranca | `rules/security.md` | Auth, CORS, secrets, limites, uploads e dados sensiveis |
| Concorrencia | `rules/concurrency-reliability.md` | Goroutines, context, timeouts, shutdown e chamadas externas |
| Testes | `rules/testing.md` | `httptest`, services, integracao, race detector e cobertura |
| Tooling | `rules/tooling-observability.md` | Comandos, logs, metricas, tracing, health e readiness |

## Fluxo de Aplicacao

1. Identificar os tipos de arquivo e carregar somente as regras relacionadas.
2. Verificar padroes existentes antes de propor estrutura ou dependencia nova.
3. Manter `*gin.Context` na camada HTTP e propagar `context.Context` para baixo.
4. Manter regra de negocio em services e SQL em arquivos consumidos pelo sqlc.
5. Preservar erros com `%w` e traduzi-los para HTTP em ponto central.
6. Alterar schema somente por migration e regenerar sqlc apos schema ou query.
7. Formatar, analisar e testar conforme ferramentas presentes no repositorio.

## Regras Invariantes

- Nao editar codigo gerado pelo sqlc.
- Nao executar SQL em handlers ou middleware.
- Nao passar `*gin.Context` para services ou persistencia.
- Nao iniciar goroutine sem owner, cancelamento, limite e destino de erro.
- Nao concatenar input em SQL, logs ou headers.
- Nao retornar erro interno, SQL, secret ou stack trace ao cliente.
- Nao usar `context.Background()` para romper cancelamento no meio da request.
- Nao declarar uma alteracao pronta sem `go test ./...` e verificacoes locais.

## Fontes Oficiais

- Gin: <https://gin-gonic.com/en/docs/>
- sqlc: <https://docs.sqlc.dev/en/stable/>
- pgx: <https://pkg.go.dev/github.com/jackc/pgx/v5>
- Goose: <https://pressly.github.io/goose/>
- Go: <https://go.dev/doc/>
