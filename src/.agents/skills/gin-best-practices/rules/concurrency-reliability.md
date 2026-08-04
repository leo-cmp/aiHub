# Concorrencia e Confiabilidade

## Context

- Receber `context.Context` como primeiro parametro em operacao bloqueante.
- Propagar `c.Request.Context()` para services, banco e clientes externos.
- Nao armazenar context em struct de longa duracao.
- Nao substituir context recebido por `context.Background()` no meio da request.
- Criar timeout menor quando a dependencia exigir budget proprio e sempre chamar
  a funcao cancel retornada.

## Goroutines

Antes de iniciar uma goroutine, definir:

1. Quem aguarda ou encerra o trabalho.
2. Qual context cancela o trabalho.
3. Qual limite impede crescimento sem controle.
4. Onde erro e panic serao tratados.
5. Se o trabalho pode ser perdido quando o processo encerrar.

- Nao capturar `*gin.Context` em goroutine.
- Copiar somente valores imutaveis necessarios.
- Usar `errgroup` quando tarefas relacionadas precisam propagar erro e
  cancelamento.
- Usar worker pool ou semaforo para fan-out limitado.
- Usar fila persistente quando o trabalho precisa de retry ou durabilidade.
- Evitar channel sem consumidor garantido e goroutine bloqueada no envio.

## Estado Compartilhado

- Preferir ownership por uma goroutine ou dados imutaveis.
- Proteger mapa e campo mutavel compartilhado com mutex ou tipo atomico adequado.
- Documentar invariantes protegidas pelo lock.
- Nao copiar struct que contem `sync.Mutex` depois do primeiro uso.
- Executar race detector em testes que exercitam concorrencia.

## Servidor HTTP

Usar `http.Server` configurado em vez de depender apenas de `router.Run`:

```go
server := &http.Server{
	Addr:              cfg.HTTPAddress,
	Handler:           router,
	ReadHeaderTimeout: 5 * time.Second,
	ReadTimeout:       15 * time.Second,
	WriteTimeout:      30 * time.Second,
	IdleTimeout:       60 * time.Second,
}
```

Valores sao ponto de partida; ajustar para uploads, streaming e perfil real.
Timeout de escrita pode encerrar resposta longa, entao testar endpoints especiais.

## Shutdown

- Escutar `SIGINT` e `SIGTERM` com `signal.NotifyContext`.
- Parar de aceitar trabalho novo.
- Chamar `server.Shutdown` com timeout finito.
- Aguardar workers cooperativos dentro do mesmo prazo ou de prazo documentado.
- Fechar pool e exporters depois de drenar requisicoes.
- Tratar `http.ErrServerClosed` como encerramento normal.
- Forcar encerramento somente depois do prazo e registrar a causa.

## Clientes Externos

- Reutilizar `http.Client` e transport; nao criar cliente por request.
- Configurar timeout global e, quando necessario, timeouts no transport.
- Fechar response body em todo caminho apos resposta valida.
- Limitar tamanho de resposta antes de ler tudo em memoria.
- Fazer retry somente em operacao idempotente ou protegida por idempotency key.
- Usar backoff com jitter, limite e respeito a cancelamento.
- Nao fazer retry cego de 4xx, erro de validacao ou context cancelado.

## Resiliencia

- Definir health para vida do processo e readiness para dependencias essenciais.
- Evitar health check que gera carga alta no banco.
- Propagar request ID e trace context para dependencias.
- Medir timeout, cancelamento, saturacao de pool e fila, nao somente status 5xx.
