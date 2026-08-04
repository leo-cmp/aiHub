# Banco de Dados com sqlc e pgx

## Configuracao

Usar configuracao v2 e gerar pacote isolado:

```yaml
version: "2"
sql:
  - engine: "postgresql"
    schema: "migrations"
    queries: "queries"
    gen:
      go:
        package: "database"
        out: "internal/database/sqlc"
        sql_package: "pgx/v5"
        emit_empty_slices: true
```

- Ajustar caminhos e package ao repositorio.
- Manter config, migrations, queries e codigo gerado no versionamento quando essa
  for a convencao do projeto.
- Nunca editar arquivos gerados; alterar SQL/config e executar `sqlc generate`.
- Executar `sqlc vet` quando configurado.
- Nao usar uma interface ampla gerada como contrato de todos os services. Definir
  interfaces pequenas junto aos consumidores que realmente precisam delas.

## Queries

- Dar nome orientado a operacao e cardinalidade correta: `:one`, `:many`,
  `:exec`, `:execrows` ou outra anotacao suportada pela versao instalada.
- Listar colunas; nao usar `SELECT *` em producao.
- Usar parametros, nunca interpolacao ou concatenacao de input.
- Adicionar `ORDER BY` deterministico em listagens.
- Limitar pagina e preferir keyset pagination em conjuntos grandes e ordenados.
- Evitar query por item dentro de loop. Buscar em lote ou compor SQL adequado.
- Manter query complexa legivel com CTEs e aliases explicitos.

```sql
-- name: GetUserByEmail :one
SELECT id, name, email, created_at, updated_at
FROM users
WHERE email = $1
LIMIT 1;
```

## pgxpool

- Criar um `pgxpool.Pool` para a aplicacao e fecha-lo no shutdown.
- Configurar limites do pool com base no banco e numero de replicas, nao por
  valor arbitrario copiado.
- Executar `Ping` no startup quando a API nao puder funcionar sem banco.
- Propagar context com deadline para adquirir conexao e executar query.
- Nao adquirir conexao manual quando chamada no pool resolver o caso.
- Monitorar acquire duration, conexoes em uso, idle e erros de pool.

## Transacoes

Delimitar transacao no caso de uso que conhece atomicidade:

```go
tx, err := pool.Begin(ctx)
if err != nil {
	return fmt.Errorf("begin transaction: %w", err)
}
defer func() {
	rollbackCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	_ = tx.Rollback(rollbackCtx)
}()

qtx := queries.WithTx(tx)
if err := qtx.CreateOrder(ctx, order); err != nil {
	return fmt.Errorf("create order: %w", err)
}
if err := qtx.ReserveStock(ctx, stock); err != nil {
	return fmt.Errorf("reserve stock: %w", err)
}
if err := tx.Commit(ctx); err != nil {
	return fmt.Errorf("commit order: %w", err)
}
```

- Rollback deve ser chamado mesmo depois de commit; pgx trata transacao fechada.
- Um context de cleanup independente e limitado e excecao intencional: garante
  tentativa de rollback mesmo quando o context da request ja foi cancelado.
- Nao assumir rollback automatico quando context for cancelado.
- Manter transacao curta e sem chamada externa lenta dentro dela.
- Tratar unique violation, foreign key e serialization failure por codigo
  PostgreSQL, nao por texto da mensagem.
- Aplicar retry apenas a falha comprovadamente transitoria e com limite.

## Migrations Goose

```sql
-- +goose Up
CREATE TABLE users (
    id uuid PRIMARY KEY,
    email text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- +goose Down
DROP TABLE users;
```

- Usar nomes ordenaveis com timestamp ou numero de largura fixa; sqlc processa
  migrations em ordem lexicografica.
- Manter `Up` e `Down` no mesmo arquivo conforme formato Goose.
- Criar indices para consultas reais e FKs para integridade.
- Usar `NO TRANSACTION` apenas quando PostgreSQL exigir.
- Nao alterar migration aplicada em ambiente compartilhado; criar migration de
  correcao.
- Rodar migration antes de gerar sqlc quando o schema mudou.

## Performance e Tipos

- Validar query critica com `EXPLAIN (ANALYZE, BUFFERS)` usando dados seguros.
- Usar tipos PostgreSQL coerentes e overrides sqlc quando o tipo Go padrao nao
  expressar o dominio.
- Representar nullable de forma explicita e mapear na fronteira.
- Evitar `float` para dinheiro.
- Selecionar somente colunas necessarias, especialmente blobs e JSON grandes.
