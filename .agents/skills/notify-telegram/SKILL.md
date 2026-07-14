---
name: notify-telegram
description: >
  Use when the user asks to be notified when a task finishes, says "me avisa quando terminar",
  "send me a message when done", "notify me", "aguarda minha resposta", "wait for my answer",
  or when completing a long-running task where the user requested a notification.
  Sends and receives Telegram messages via the iAgentBot API (bidirectional communication).
---

# Notify via Telegram (iAgentBot)

API REST em CodeIgniter 4 para comunicação bidirecional entre o agente e o usuário via Telegram.
O agente envia uma mensagem e pode aguardar a resposta do usuário antes de continuar.

## Configuração necessária

Defina as variáveis de ambiente (ou peça ao usuário os valores):

```bash
IAGENTBOT_URL=https://seu-dominio.com   # base URL sem trailing slash
IAGENTBOT_KEY=sua-chave-secreta
IAGENTBOT_WEBHOOK_SECRET=seu-secret-gerado-com-openssl  # necessário para receber respostas
```

Opcionalmente: `IAGENTBOT_CHAT_ID` (usa o padrão do servidor se omitido).

## Endpoints disponíveis

### `POST /api/send` — Enviar mensagem

```bash
curl -s -X POST "$IAGENTBOT_URL/api/send" \
  -H "Authorization: Bearer $IAGENTBOT_KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "✅ Tarefa concluída: <resumo aqui>"}'
```

Com chat_id específico:

```bash
curl -s -X POST "$IAGENTBOT_URL/api/send" \
  -H "Authorization: Bearer $IAGENTBOT_KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "Mensagem aqui", "chat_id": "'"$IAGENTBOT_CHAT_ID"'"}'
```

### `GET /api/response` — Polling para resposta do usuário

Retorna a resposta pendente do usuário e **apaga o arquivo** (consumo único). Protegido por API Key.

```bash
curl -s "$IAGENTBOT_URL/api/response" \
  -H "Authorization: Bearer $IAGENTBOT_KEY"
```

**Com resposta disponível (200):**
```json
{ "ok": true, "text": "mensagem do usuário aqui" }
```

**Sem resposta ainda (200):**
```json
{ "ok": false, "message": "No response yet. Keep polling." }
```

### `POST /webhook/{secret}` — Receber resposta do Telegram

Endpoint público chamado automaticamente pelo Telegram quando o usuário responde.
O `{secret}` deve coincidir com `TELEGRAM_WEBHOOK_SECRET` do `.env`.
Só aceita mensagens do `TELEGRAM_DEFAULT_CHAT_ID` — demais remetentes são ignorados.

## Comunicação bidirecional (agente ↔ usuário)

```
Agente → POST /api/send  →  Telegram  →  Usuário recebe
                                Usuário responde no Telegram
                                Telegram → POST /webhook/{secret}
                                               │
                                 writable/pending_response.php
                                               │
Agente ← GET /api/response  ←  retorna texto e apaga o arquivo
```

### Fluxo de uso: enviar e aguardar resposta

```bash
# 1. Enviar pergunta ao usuário
curl -s -X POST "$IAGENTBOT_URL/api/send" \
  -H "Authorization: Bearer $IAGENTBOT_KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "Posso fazer o deploy agora? Responda sim ou não."}'

# 2. Fazer polling até receber resposta (intervalo recomendado: 5s)
while true; do
  RESP=$(curl -s "$IAGENTBOT_URL/api/response" \
    -H "Authorization: Bearer $IAGENTBOT_KEY")
  OK=$(echo "$RESP" | grep -o '"ok":true')
  if [ -n "$OK" ]; then
    echo "Resposta do usuário: $RESP"
    break
  fi
  sleep 5
done
```

### Configuração do webhook (1x só)

```bash
# Gere um secret
openssl rand -hex 32

# Registre o webhook no Telegram
curl "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/setWebhook" \
  -d "url=https://seu-dominio.com/webhook/$IAGENTBOT_WEBHOOK_SECRET"
```

## Quando disparar

- Ao finalizar qualquer tarefa onde o usuário pediu notificação
- Ao submeter resultado de sessão longa
- Ao concluir deploy, build, testes ou processo demorado
- Quando precisar de confirmação do usuário antes de continuar (usar fluxo bidirecional)

## Mensagem recomendada

Inclua no texto:
- ✅ ou ❌ indicando sucesso/falha
- Nome da tarefa ou resumo do que foi feito
- Próximo passo (se houver)

Exemplo: `"✅ Build concluído. Deploy em produção pronto para revisão."`

## Variáveis não configuradas

Se `IAGENTBOT_URL` ou `IAGENTBOT_KEY` não estiverem definidas, pergunte ao usuário antes de tentar enviar. Nunca invente valores.
