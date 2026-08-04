# Seguranca

## Entrada e Saida

- Limitar corpo antes do binding e definir limites separados para multipart.
- Validar comprimento, formato, enum e intervalo em DTOs.
- Normalizar somente quando a regra for clara; nao transformar secret ou senha.
- Escapar conforme o contexto ao renderizar HTML. Para API JSON, usar encoder do
  framework e nunca montar JSON por concatenacao.
- Validar URL externa antes de requisicao para reduzir risco de SSRF.
- Validar nome, tamanho, MIME real e destino de upload; gerar nome interno.

## Autenticacao e Autorizacao

- Autenticar credencial em middleware e guardar apenas identidade minima para o
  restante da requisicao.
- Autorizar acao e recurso no service, especialmente quando depende de tenant,
  ownership ou estado carregado do banco.
- Diferenciar 401 de 403 sem revelar detalhe sensivel.
- Verificar assinatura, issuer, audience, expiracao e algoritmo permitido em JWT.
- Implementar rotacao e revogacao conforme risco; nao usar JWT como sessao
  irrevogavel por conveniencia.
- Usar cookie `Secure`, `HttpOnly` e `SameSite` adequado quando autenticacao usar
  cookie. Aplicar protecao CSRF a requisicoes autenticadas por cookie.

## Senhas e Secrets

- Usar Argon2id ou bcrypt com parametros revisados para o ambiente.
- Comparar hash por funcao propria da biblioteca.
- Nunca criptografar senha de modo reversivel.
- Ler secrets de ambiente ou provedor dedicado e validar no startup.
- Nao incluir valor de secret em erro de configuracao.
- Nao commitar `.env`, credenciais, chaves privadas ou dumps de producao.

## SQL e Multi-Tenant

- Usar parametros gerados pelo sqlc; nunca concatenar input.
- Aplicar tenant em toda query relevante e testar tentativa de acesso cruzado.
- Nao confiar apenas em ID opaco para autorizacao.
- Usar constraints e FKs como segunda linha de integridade.
- Tratar erros de constraint sem expor nomes internos de tabela ou indice.

## CORS, Proxy e Headers

- Configurar allowlist de origens, metodos e headers.
- Nao combinar credenciais com origem `*`.
- Confiar em proxy headers apenas de proxies conhecidos e configurados.
- Aplicar headers como `X-Content-Type-Options`, politica de frame e HSTS de
  acordo com o ambiente TLS.
- Nao refletir header recebido sem validacao.

## Limites e Abuso

- Aplicar rate limit por identidade adequada, nao apenas IP quando houver proxy
  ou usuarios autenticados.
- Definir timeout, limite de corpo e limite de upload.
- Proteger login, recuperacao de conta e endpoints caros com limites mais
  restritos.
- Evitar resposta que permita enumerar conta.
- Registrar evento de seguranca sem registrar credencial ou payload sensivel.

## Logs

Nunca registrar:

- `Authorization`, cookies e refresh tokens.
- Senhas, hashes de senha ou codigos de recuperacao.
- Chaves API, DSN com senha ou secrets de webhook.
- Dados pessoais completos sem necessidade operacional aprovada.

Redigir ou fazer allowlist de campos antes de logar. Preferir atributos
estruturados controlados a dump de request.
