# Gin Guidelines

- Verifique `go.mod`, `go.work`, `sqlc.yaml`, `Makefile` e pacotes vizinhos antes
  de decidir versoes, layout ou comandos.
- Use Gin para HTTP, sqlc para gerar acesso tipado, `pgx/v5` para PostgreSQL e
  Goose para migrations SQL em projetos novos.
- Preserve ferramenta equivalente ja adotada pelo projeto. Nao mantenha duas
  bibliotecas para a mesma responsabilidade sem necessidade comprovada.
- Use `go get` ou o comando ja documentado no repositorio para dependencias.
  Nunca edite `go.mod` manualmente para simular instalacao.

## Arquitetura

Layout de referencia para projetos novos:

```text
cmd/api/                 composicao, servidor e shutdown
internal/transport/http/ handlers, DTOs, middleware e rotas
internal/domain/         entidades, erros e contratos
internal/service/        casos de uso e regras de negocio
internal/database/       sqlc gerado e adapters de persistencia
internal/platform/       config, logs e integracoes
migrations/              migrations Goose
queries/                 SQL de aplicacao
```

- Em repositorio existente, siga limites equivalentes em vez de reorganizar
  pacotes sem solicitacao.
- Monte dependencias explicitamente em `cmd/api`; evite service locator e estado
  global mutavel.
- Mantenha handlers focados em bind, validacao, chamada ao service e resposta.
- Services nao recebem `*gin.Context` e nao conhecem status HTTP.
- Coloque interfaces junto ao pacote consumidor. Crie interface somente quando
  houver limite real de teste, dominio ou infraestrutura.
- Evite repository que apenas repete, sem adaptacao, cada metodo gerado pelo
  sqlc.
- Nao exponha DTOs HTTP ou structs geradas pelo sqlc como entidades de dominio
  quando isso acoplar regra de negocio ao transporte ou schema.

## HTTP e Rotas

- Declare rotas explicitamente e agrupe por versao, dominio e politica de
  middleware.
- Prefira `gin.New()` e registre logger e recovery explicitamente para manter
  configuracao e ordem visiveis.
- Use DTOs tipados com tags `json`, `form` e `binding` adequadas.
- Para endpoints JSON, prefira `ShouldBindJSON` a metodos `Bind*`, pois o handler
  mantem controle da resposta de erro.
- Limite o corpo antes do binding e imponha limites proprios para uploads.
- Valide formato no handler e regra de negocio no service.
- Use `c.Request.Context()` ao chamar services e integracoes.
- Use verbos e status HTTP semanticos. Rotas de criacao usam `POST`, atualizacao
  idempotente usa `PUT`, atualizacao parcial usa `PATCH` e exclusao usa `DELETE`.
- Retorne JSON consistente. Nao use `gin.H` como contrato publico quando um DTO
  nomeado tornar o formato mais claro e testavel.
- Centralize traducao de erros com `errors.Is` e `errors.As`; nunca retorne
  `err.Error()` indiscriminadamente ao cliente.
- Middleware encerra fluxo negado com `Abort*` e `return`. Registre middleware
  antes das rotas que ele protege.

## Banco de Dados

- Configure sqlc v2 com `engine: postgresql` e `sql_package: pgx/v5` para projetos
  novos.
- Mantenha migrations e queries SQL versionadas. Codigo gerado fica em pacote
  identificado e nunca recebe edicao manual.
- Nunca use `SELECT *` em query de producao. Liste colunas para manter contrato e
  geracao previsiveis.
- Use parametros do sqlc; concatenacao de input em SQL e proibida.
- Propague `context.Context` em toda query.
- Ordene listagens de modo deterministico e imponha limite de pagina.
- Crie indices para padroes reais de `WHERE`, `JOIN` e `ORDER BY`; valide queries
  criticas com `EXPLAIN (ANALYZE, BUFFERS)` em ambiente seguro.
- Delimite transacao no caso de uso que exige atomicidade. Use `Queries.WithTx`
  e garanta rollback em todo caminho de erro.
- Configure e feche `pgxpool.Pool`; valide conectividade no startup quando o
  banco for dependencia obrigatoria.

## Migrations

- Crie migrations SQL com Goose. Cada arquivo deve conter uma secao
  `-- +goose Up` e, por padrao, `-- +goose Down` capaz de desfazer a mudanca.
- Use prefixos de timestamp ou numeros com largura fixa. sqlc le migrations em
  ordem lexicografica.
- Uma migration trata uma mudanca coesa. Nao misture DDL amplo com carga de
  dados sem necessidade.
- Use `-- +goose NO TRANSACTION` somente para operacao PostgreSQL que nao pode
  executar em transacao, com justificativa no arquivo.
- Depois de alterar schema, execute migration, `sqlc generate`, `sqlc vet` e os
  testes de aceite. Valide rollback quando ele for suportado.

## Concorrencia e Confiabilidade

- Toda goroutine precisa de owner, cancelamento, limite e estrategia de erro.
- Nunca use `*gin.Context` fora do ciclo sincrono do handler. Copiar o contexto
  nao transforma trabalho em job duravel.
- Trabalho que precisa sobreviver ao processo pertence a fila ou worker
  persistente.
- Configure `ReadHeaderTimeout`, `ReadTimeout`, `WriteTimeout` e `IdleTimeout` no
  `http.Server` conforme o perfil da aplicacao.
- Propague cancelamento para banco e clientes externos.
- Configure timeout em todo cliente HTTP e sempre feche response body.
- Implemente shutdown gracioso com sinal, prazo finito, `Server.Shutdown` e
  fechamento do pool depois de parar novas requisicoes.

## Seguranca

- Autentique em middleware; autorize a acao e o recurso no service.
- Configure CORS por allowlist. Nao combine origem wildcard com credenciais.
- Leia secrets de ambiente ou provedor dedicado e valide-os no startup.
- Nunca registre senha, token, cookie, secret, cabecalho de autorizacao ou corpo
  sensivel.
- Aplique limite de corpo, upload, taxa e duracao conforme risco do endpoint.
- Use hash de senha adequado e comparacao segura. Nunca armazene senha reversivel.
- Nao exponha detalhes internos em respostas de autenticacao ou erros 5xx.

## Testes e Comandos

- Use `testing` e `httptest` para handlers e middleware. Ative `gin.TestMode`.
- Teste services com doubles pequenos das interfaces que eles consomem.
- Teste queries, constraints e migrations contra PostgreSQL real.
- Cubra commit, rollback, conflito e cancelamento em fluxos transacionais.
- Execute race detector para codigo com goroutines ou estado compartilhado.

Comandos base, respeitando wrappers existentes no projeto:

```bash
go fmt ./...
go vet ./...
go test ./...
go test -race ./...
sqlc generate
sqlc vet
goose -dir migrations postgres "$DATABASE_URL" up
goose -dir migrations postgres "$DATABASE_URL" down
```

Nao execute `down` em ambiente com dados persistentes sem confirmacao explicita.

## Skills

- `gin-best-practices`: use como referencia ao escrever, revisar ou refatorar
  codigo Gin, sqlc, pgx, migrations, concorrencia, seguranca e testes.
