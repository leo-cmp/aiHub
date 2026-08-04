# Gin Guideline and Skill Design

## Objetivo

Adicionar ao l-nexus uma opcao opinativa para desenvolvimento de APIs em Go,
equivalente as opcoes existentes para CodeIgniter 4 e Laravel. A stack adotada
sera Gin com acesso explicito a PostgreSQL por sqlc e pgx, e migrations SQL
versionadas por Goose.

O resultado deve orientar tanto implementacao quanto revisao de codigo sem
transformar a skill em um manual generico da linguagem Go.

## Escopo

O trabalho criara uma guideline de stack e uma skill com referencias tematicas.
O limite total e de dez arquivos:

1. `src/.ai/guidelines/stacks/gin.md`
2. `src/.agents/skills/gin-best-practices/SKILL.md`
3. `src/.agents/skills/gin-best-practices/agents/openai.yaml`
4. `src/.agents/skills/gin-best-practices/rules/architecture.md`
5. `src/.agents/skills/gin-best-practices/rules/http.md`
6. `src/.agents/skills/gin-best-practices/rules/database-sqlc.md`
7. `src/.agents/skills/gin-best-practices/rules/security.md`
8. `src/.agents/skills/gin-best-practices/rules/concurrency-reliability.md`
9. `src/.agents/skills/gin-best-practices/rules/testing.md`
10. `src/.agents/skills/gin-best-practices/rules/tooling-observability.md`

Ficam fora do escopo: frontend, templates HTML, WebSockets, mensageria,
orquestracao de containers, deploy em cloud e uma biblioteca interna de
scaffolding. Esses temas poderao ser adicionados depois quando houver um caso de
uso concreto.

## Stack Padrao

- Gin: servidor HTTP, rotas, grupos e middleware.
- sqlc: geracao de codigo Go tipado a partir de SQL versionado.
- pgx/v5: driver e pool PostgreSQL.
- Goose: migrations SQL com secoes `Up` e `Down` reversiveis.
- validator/v10: validacao estrutural de DTOs de entrada.
- `log/slog`: logs estruturados.
- `testing`, `httptest` e doubles pequenos: base de testes.

As versoes concretas devem ser lidas de `go.mod` e dos arquivos de configuracao
do projeto. A guideline nao fixara numeros de versao que envelhecem. Quando o
projeto ja possuir uma ferramenta equivalente, o agente deve preservar a
convencao existente antes de introduzir uma segunda solucao.

## Arquitetura

A referencia adotara esta separacao:

```text
cmd/api/                 composicao, inicializacao e shutdown
internal/transport/http/ handlers, DTOs, middleware e rotas
internal/domain/         entidades, erros e contratos do dominio
internal/service/        casos de uso e regras de negocio
internal/database/       codigo sqlc gerado e adaptadores de persistencia
internal/platform/       config, logs e integracoes de infraestrutura
migrations/              migrations Goose
queries/                 consultas SQL consumidas pelo sqlc
```

Essa arvore e uma referencia, nao uma exigencia de reorganizacao automatica.
Em repositorios existentes, o agente deve primeiro mapear pacotes vizinhos e
seguir limites equivalentes ja estabelecidos.

### Responsabilidades

- Handlers fazem bind, validacao, chamada ao service e serializacao da resposta.
- Services concentram regras de negocio e nao dependem de `*gin.Context`.
- Middleware trata preocupacoes transversais como autenticacao, request ID,
  recovery, CORS e limites de requisicao.
- A camada de banco executa apenas persistencia e mapeamento.
- Interfaces ficam junto ao consumidor que precisa abstrair uma dependencia.
- Dependencias sao recebidas explicitamente; estado global mutavel e proibido.
- Tipos gerados pelo sqlc nao atravessam os limites de HTTP ou dominio quando
  isso acoplar regra de negocio ao schema fisico.

Abstracoes de repositorio nao serao obrigatorias para cada query. Um adapter ou
interface sera criado quando isolar persistencia trouxer valor real para regra de
negocio, testes ou troca de infraestrutura. Wrappers que apenas repetem a API
gerada pelo sqlc devem ser evitados.

## Fluxo de Dados

```text
request HTTP
  -> middleware
  -> handler: bind e validacao
  -> service: regra de negocio
  -> sqlc/pgx: transacao e SQL
  -> service: resultado de dominio
  -> handler: resposta HTTP
```

`context.Context` deve ser propagado desde a requisicao ate banco e integracoes.
Timeouts e cancelamento nao devem ser substituidos por `context.Background()` no
meio do fluxo.

Operacoes que exigem atomicidade devem delimitar a transacao no caso de uso. O
codigo usara `Queries.WithTx` para executar queries geradas na mesma transacao e
garantira rollback em todos os caminhos de erro.

## Contrato HTTP e Erros

- Rotas devem ser declaradas explicitamente e agrupadas por versao ou dominio.
- Verbos e status HTTP devem refletir a semantica da operacao.
- DTOs de entrada e saida devem ser separados de modelos de banco.
- Binding deve limitar tamanho do corpo e rejeitar payload invalido.
- Validacao estrutural ocorre antes do service; regra de negocio ocorre nele.
- Erros de dominio devem ser identificaveis com `errors.Is` ou `errors.As`.
- Um componente central deve mapear erros conhecidos para status e corpo JSON.
- Detalhes internos, SQL e stack traces nunca devem vazar ao cliente.
- Panics devem ser recuperados, registrados e respondidos como erro interno.

O formato exato do envelope JSON deve seguir o projeto existente. Em projeto
novo, a guideline definira um formato minimo e consistente com codigo, mensagem
e detalhes de validacao opcionais.

## Banco de Dados

- SQL de aplicacao vive em arquivos consumidos pelo sqlc.
- Codigo gerado nunca e editado manualmente.
- `SELECT *` e proibido em consultas de producao.
- Toda query recebe `context.Context`.
- Parametros devem permanecer vinculados; concatenacao de input em SQL e
  proibida.
- Colunas usadas com frequencia em `WHERE`, `JOIN` e `ORDER BY` devem ter indices
  coerentes com o plano de consulta.
- Listagens devem ter ordenacao deterministica e paginacao limitada.
- Migrations Goose devem possuir `Up` e `Down`, salvo irreversibilidade explicita
  e justificada.
- Alteracoes de schema exigem migration; `AutoMigrate` e ORMs ficam fora do stack.
- Depois de alterar schema ou queries, executar migration, `sqlc generate` e
  testes antes do aceite.

## Concorrencia e Confiabilidade

- Goroutines precisam de dono, cancelamento, limite e estrategia de erro.
- Nenhuma goroutine deve capturar `*gin.Context` para uso apos o handler.
- Trabalho que precisa sobreviver ao processo deve ir para fila ou worker
  persistente, nao para goroutine solta.
- Recursos compartilhados exigem sincronizacao explicita ou ownership unico.
- Chamadas externas devem configurar timeout e fechar response bodies.
- Servidor deve configurar timeouts HTTP e executar shutdown gracioso.
- Sinais de encerramento devem cancelar trabalho ativo e fechar pool do banco.

## Seguranca

- Validar e normalizar toda entrada na borda correta.
- Aplicar autenticacao e autorizacao por middleware e service, respectivamente.
- Nunca registrar tokens, senhas, cookies, secrets ou payloads sensiveis.
- Secrets devem vir de ambiente ou provedor de secrets, com validacao no startup.
- Configurar CORS por allowlist; wildcard com credenciais e proibido.
- Limitar corpo, upload, taxa e duracao de requisicoes conforme risco da rota.
- Senhas devem usar algoritmo apropriado de hash; nunca criptografia reversivel.
- Respostas de autenticacao devem evitar revelar existencia de conta.

## Testes e Qualidade

- Handlers: `httptest`, tabela de casos e verificacao de status e JSON.
- Services: testes unitarios com doubles de interfaces realmente consumidas.
- Persistencia: testes de integracao contra PostgreSQL real e migrations reais.
- Middleware: testes de ordem, abort, headers e contexto.
- Transacoes: cobrir commit, rollback e conflito.
- Concorrencia: executar `go test -race ./...` quando houver goroutines ou estado
  compartilhado.

Comandos base:

```bash
go fmt ./...
go vet ./...
go test ./...
go test -race ./...
sqlc generate
sqlc vet
goose -dir migrations postgres "$DATABASE_URL" up
```

O projeto pode adicionar `goimports`, `staticcheck` ou `golangci-lint`, mas a
skill nao exigira ferramentas ausentes sem antes verificar configuracao local.

## Organizacao da Skill

`SKILL.md` tera apenas metadata de acionamento, principio de consistencia,
indice das sete regras e fluxo de aplicacao. Detalhes e exemplos ficarao em
`rules/` para carregamento progressivo.

A descricao acionara a skill ao criar, alterar, revisar ou refatorar codigo Gin,
incluindo handlers, middleware, rotas, services, sqlc, pgx, migrations,
concorrencia, seguranca, observabilidade e testes.

`agents/openai.yaml` fornecera nome, descricao curta e prompt inicial coerentes
com a skill. Nao havera scripts ou assets porque nao existe operacao repetitiva
que justifique esses recursos nesta primeira versao.

## Validacao

O trabalho sera aceito quando:

1. A guideline referenciar `gin-best-practices` na secao `Skills`.
2. A skill possuir frontmatter valido e indice para todos os arquivos de regra.
3. Nao houver referencias quebradas entre guideline, skill e rules.
4. `quick_validate.py` aprovar a pasta da skill.
5. `scripts/validate.sh src` continuar aprovando o repositorio.
6. Busca por marcadores de pendencia nao encontrar exemplos nao resolvidos.
7. `git diff --check` nao apontar erros de whitespace.
8. O diff final alterar somente os dez artefatos aprovados.

## Decisoes

- Gin foi escolhido por estabilidade e foco em APIs HTTP.
- sqlc foi escolhido em vez de GORM para manter SQL explicito e gerar acesso
  tipado sem ORM em runtime.
- PostgreSQL com pgx sera o caminho padrao; suporte generico a multiplos bancos
  nao sera prometido nesta versao.
- Goose cuidara de migrations, responsabilidade que nao pertence ao sqlc.
- A skill adotara progressive disclosure para reduzir contexto carregado.
