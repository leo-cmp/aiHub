# HTTP com Gin

## Router

- Criar router em funcao testavel que recebe handlers e middleware.
- Preferir `gin.New()` para tornar logger, recovery e ordem explicitos.
- Registrar middleware global antes de grupos e rotas.
- Agrupar por versao e politica, sem esconder registro em `init()`.
- Usar rotas estaticas e parametros claros; evitar endpoints definidos por
  comportamento implicito.

```go
func NewRouter(users UserHandler, auth gin.HandlerFunc) *gin.Engine {
	router := gin.New()
	router.Use(RequestID(), AccessLog(), Recovery(), ErrorHandler())

	v1 := router.Group("/api/v1")
	v1.POST("/users", users.Create)
	v1.GET("/users/:id", auth, users.Show)

	return router
}
```

## DTOs, Binding e Validacao

- Usar struct dedicada para cada contrato relevante.
- Usar `ShouldBindJSON` para endpoint JSON e binding especifico para query, path,
  header ou form. Nao aceitar varias fontes sem intencao explicita.
- Limitar corpo antes do binding com `http.MaxBytesReader`.
- Usar tags `binding` para forma e validador customizado apenas para regra
  estrutural reutilizavel.
- Tratar regra que depende de estado, permissao ou banco no service.
- Nao fazer bind direto em row sqlc ou entidade persistida.

```go
type CreateUserRequest struct {
	Name  string `json:"name" binding:"required,max=120"`
	Email string `json:"email" binding:"required,email,max=254"`
}

func (h UserHandler) Create(c *gin.Context) {
	c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, 1<<20)

	var request CreateUserRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		h.errors.Validation(c, err)
		return
	}

	user, err := h.users.Create(c.Request.Context(), service.CreateUserInput{
		Name: request.Name, Email: request.Email,
	})
	if err != nil {
		_ = c.Error(err)
		return
	}

	c.JSON(http.StatusCreated, newUserResponse(user))
}
```

## Respostas e Erros

- Usar `net/http` para constantes de status.
- Responder uma vez e retornar depois de erro.
- Usar DTO nomeado em contratos publicos; reservar `gin.H` para respostas
  pequenas e internas.
- Centralizar envelope e mapeamento de erros para evitar divergencia.
- Mapear not found, conflict, validation, unauthorized e forbidden de forma
  explicita; tratar restante como 500 sem detalhe interno.
- Registrar causa interna com request ID antes de retornar resposta sanitizada.
- Nao retornar `err.Error()` diretamente em resposta generica.

## Middleware

- Usar middleware para preocupacao transversal, nao regra especifica do caso de
  uso.
- Chamar `c.AbortWithStatusJSON(...)` e depois `return` ao negar requisicao.
- Usar chaves tipadas ou helpers de acesso para valores colocados no contexto
  Gin; validar type assertion.
- Nao executar query redundante em varios middleware.
- Autenticar no middleware e autorizar recurso no service quando a decisao
  depender do objeto carregado.

## Listagens

- Definir limite maximo e default de pagina.
- Validar cursor ou offset; rejeitar valores negativos e limites excessivos.
- Ordenar por coluna deterministica e incluir desempate unico.
- Nao retornar contagem total cara por padrao se o contrato nao exigir.

## Headers e Cache

- Declarar `Content-Type` por meio dos renderers Gin.
- Definir cache de forma explicita para respostas cacheaveis.
- Usar `Location` em criacao quando o recurso possuir URL canonica.
- Aplicar headers de seguranca em middleware unico e testado.
