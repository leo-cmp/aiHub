# Testes

## Estrategia

- Testar comportamento publico, nao detalhes internos sem valor contratual.
- Usar testes table-driven para variacoes de input, status e erro.
- Manter fixture minima e nomes que descrevem cenario e resultado.
- Evitar sleep para sincronizacao; usar canais, clocks injetados ou condicoes
  observaveis.
- Nao usar banco mockado para afirmar semantica PostgreSQL.

## Handlers

Ativar test mode e exercitar o router com `httptest`:

```go
func TestMain(m *testing.M) {
	gin.SetMode(gin.TestMode)
	os.Exit(m.Run())
}

func TestCreateUserRejectsInvalidEmail(t *testing.T) {
	router := newTestRouter(fakeUserService{})
	request := httptest.NewRequest(
		http.MethodPost,
		"/api/v1/users",
		strings.NewReader(`{"name":"Ana","email":"invalid"}`),
	)
	request.Header.Set("Content-Type", "application/json")
	recorder := httptest.NewRecorder()

	router.ServeHTTP(recorder, request)

	if recorder.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusBadRequest)
	}
}
```

- Verificar status, headers e JSON decodificado.
- Testar body vazio, JSON malformado, campo invalido, limite excedido, sucesso e
  erro do service.
- Testar rota pelo router real para cobrir path, middleware e registro.
- Nao comparar JSON como string quando ordem de campos nao fizer parte do
  contrato.

## Middleware

- Criar router minimo com middleware e handler sentinela.
- Verificar se cadeia foi abortada quando acesso for negado.
- Testar headers, valores de contexto, ordem e comportamento depois de `c.Next`.
- Cobrir credencial ausente, invalida, expirada e valida.
- Confirmar que logs nao incluem dados sensiveis.

## Services

- Definir doubles pequenos para interfaces consumidas.
- Testar regra de negocio sem Gin, router ou banco quando ela nao depender de
  semantica SQL.
- Cobrir erros com `errors.Is` e `errors.As`.
- Verificar chamadas apenas quando sua ocorrencia fizer parte do comportamento.
- Injetar clock, gerador de ID e gateways quando determinismo exigir.

## Persistencia e Migrations

- Executar testes de integracao contra PostgreSQL compativel com producao.
- Aplicar migrations reais em banco limpo.
- Testar constraints, nullability, tipos, ordenacao e concorrencia relevante.
- Validar query gerada por comportamento e resultado, nao por copia do SQL.
- Isolar testes por database, schema ou transacao conforme suporte do fluxo.
- Nao executar testes destrutivos contra `DATABASE_URL` de desenvolvimento sem
  protecao explicita.

## Transacoes

Cobrir:

- Commit quando todas as operacoes passam.
- Rollback quando uma operacao falha.
- Erro de commit.
- Unique violation e conflito de concorrencia.
- Cancelamento e timeout.

## Concorrencia

- Executar `go test -race ./...` em CI quando o ambiente suportar.
- Lembrar que race detector encontra somente caminhos executados.
- Testar shutdown com trabalho em voo e prazo controlado.
- Evitar teste flakey baseado em timing apertado.

## Comandos

```bash
go test ./...
go test -race ./...
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out
```

Usar `-count=1` ao investigar cache e `-run` para foco local. Cobertura informa
lacunas; nao substituir assercoes relevantes por meta numerica isolada.
