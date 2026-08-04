# Arquitetura

## Limites de Pacote

- Compor a aplicacao em `cmd/api`; manter `main` pequeno e explicito.
- Manter transporte HTTP, dominio, casos de uso e infraestrutura em pacotes
  separados por responsabilidade.
- Preferir pacotes orientados a dominio quando o sistema crescer. Evitar pacotes
  genericos como `utils`, `helpers`, `common` e `misc`.
- Impedir ciclos de importacao pelo desenho das dependencias, nao movendo tipos
  sem criterio para um pacote compartilhado.
- Manter identificadores nao exportados quando nao fazem parte do contrato do
  pacote.

Fluxo de dependencia esperado:

```text
cmd/api -> transport/http -> service -> domain
   |             |             |
   +-------------+-------------+-> database/platform
```

Infraestrutura implementa contratos consumidos pelos casos de uso. O dominio nao
importa Gin, pgx ou codigo gerado pelo sqlc.

## Injecao de Dependencias

Construir dependencias explicitamente:

```go
pool := mustOpenPool(ctx, cfg.DatabaseURL)
queries := database.New(pool)
users := service.NewUserService(queries)
handler := httptransport.NewUserHandler(users)
router := httptransport.NewRouter(handler, logger)
```

- Evitar variaveis globais para pool, config, logger ou services.
- Receber dependencia no construtor e validar requisito obrigatorio cedo.
- Nao criar container de injecao quando composicao manual continuar clara.
- Nao usar interface apenas para possibilitar mock. Definir interface pequena no
  consumidor quando ela expressar o que o caso de uso realmente precisa.

## Handlers e Services

Handler:

- Conhecer Gin, DTOs e semantica HTTP.
- Converter input de transporte em input do caso de uso.
- Delegar regra de negocio.
- Converter resultado ou erro em resposta.

Service:

- Receber `context.Context`, nunca `*gin.Context`.
- Aplicar regra de negocio e coordenar transacoes ou integracoes.
- Retornar tipos e erros independentes de HTTP.
- Nao ler environment variables nem resolver dependencias internamente.

## Tipos e Mapeamento

- Separar DTO de entrada, DTO de saida, entidade de dominio e row gerada quando
  possuirem responsabilidades diferentes.
- Aceitar reutilizacao direta de tipo somente quando nao criar acoplamento e o
  contrato for realmente identico.
- Fazer mapeamento em funcoes pequenas, proximas da fronteira proprietaria.
- Representar dinheiro com unidade inteira menor ou tipo decimal definido pelo
  dominio; nunca `float32` ou `float64`.
- Tratar tempo em UTC internamente e aplicar timezone somente na borda.

## Erros de Dominio

Declarar erros sentinela ou tipos quando o chamador precisa decidir:

```go
var ErrUserNotFound = errors.New("user not found")

type ConflictError struct {
	Field string
}

func (e ConflictError) Error() string {
	return "resource conflict: " + e.Field
}
```

- Encadear causa com `%w`.
- Inspecionar com `errors.Is` e `errors.As`.
- Nao comparar texto de erro para tomar decisao.
- Nao incluir SQL, secret ou detalhe operacional em erro publico.

## Evitar Abstracao Vazia

Nao criar `UserRepository` com dezenas de metodos que apenas encaminham chamadas
identicas para sqlc. Criar adapter quando houver mapeamento, composicao de queries,
politica transacional ou contrato de dominio que justifique o limite.
