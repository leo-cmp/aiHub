---
name: notify-telegram
description: >
  Use when the user asks to be notified when a task finishes, says "me avisa quando terminar",
  "send me a message when done", "notify me", or when completing a long-running task where
  the user requested a notification. Sends a Telegram message via the iAgentBot API.
---

# Notify via Telegram (iAgentBot)

Ao finalizar uma tarefa longa ou quando o usuário pedir para ser avisado, envie uma mensagem via API do iAgentBot.

## Configuração necessária

Defina as variáveis de ambiente (ou peça ao usuário os valores):

```bash
IAGENTBOT_URL=https://seu-dominio.com/api/send
IAGENTBOT_KEY=sua-chave-secreta
```

Opcionalmente: `IAGENTBOT_CHAT_ID` (usa o padrão do servidor se omitido).

## Como enviar

```bash
curl -s -X POST "$IAGENTBOT_URL" \
  -H "Authorization: Bearer $IAGENTBOT_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"text\": \"✅ Tarefa concluída: <resumo aqui>\"}"
```

Com chat_id específico:

```bash
curl -s -X POST "$IAGENTBOT_URL" \
  -H "Authorization: Bearer $IAGENTBOT_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"text\": \"✅ Tarefa concluída: <resumo>\", \"chat_id\": \"$IAGENTBOT_CHAT_ID\"}"
```

## Quando disparar

- Ao finalizar qualquer tarefa onde o usuário pediu notificação
- Ao submeter resultado de sessão longa
- Ao concluir deploy, build, testes ou processo demorado

## Mensagem recomendada

Inclua no texto:
- ✅ ou ❌ indicando sucesso/falha
- Nome da tarefa ou resumo do que foi feito
- Próximo passo (se houver)

Exemplo: `"✅ Build concluído. Deploy em produção pronto para revisão."`

## Variáveis não configuradas

Se `IAGENTBOT_URL` ou `IAGENTBOT_KEY` não estiverem definidas, pergunte ao usuário antes de tentar enviar. Nunca invente valores.
