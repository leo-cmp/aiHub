# Nudge Guidelines

Sempre que o agente concluir uma etapa significativa, precisar de intervencao do usuario ou encerrar uma sessao, deve notificar o usuario via Telegram usando o MCP `nudge` (ferramenta `create_reminder` com tipo `instant`).

## Quando Notificar

O agente DEVE enviar um nudge instantaneo nas seguintes situacoes:

### Conclusao de Task
- Quando uma task executavel for concluida com sucesso (checklist de encerramento passou). Inclua: nome da task, resumo do entregavel e link do PR.
- Quando uma task falhar (erro critico, bloqueio). Inclua: nome da task, erro encontrado e acao pendente.

### Bloqueio / Precisa de Ajuda
- Quando o agente parar por ambiguidade, falta de informacao ou decisao com multiplos caminhos. Inclua: contexto da duvida e o que o usuario precisa responder.
- Quando um criterio de aceite falhar 3 vezes consecutivas (circuit breaker). Inclua: criterio, tentativas e erro.

### Marcos e Fases
- Quando uma fase (PLAN_VN) for concluida. Inclua: nome da fase, resumo de tasks e link do milestone/PR.
- Quando iniciar uma nova fase. Inclua: nome da fase e escopo planejado.

### Handoff de Sessao
- Quando a sessao estiver degradada (Context Canary detectou) e o agente for encerrar. Inclua: task atual, progresso e proximo passo.
- Quando a task atingir 20 interacoes sem conclusao. Inclua: progresso, bloqueios e opcoes para o usuario decidir.

## Formato da Mensagem

A mensagem deve ser concisa e acionavel. Use o template:

```
[l-nexus] <contexto>: <acao/status>

Task: <nome ou ID>
Projeto: <nome do projeto>
<detalhes relevantes>

<acao pendente ou proximo passo>
```

Exemplo de conclusao de task:
```
create_reminder(type="instant", message="[l-nexus] Task concluida: Task 1.2 - Autenticacao JWT

Projeto: dizit
PR: https://github.com/leo-cmp/dizit/pull/42
Checklist de encerramento: todos os itens passaram.
Evidencias registradas em .planning/PLAN_V1/evidencias/")
```

Exemplo de bloqueio:
```
create_reminder(type="instant", message="[l-nexus] Bloqueio: Task 1.3 - Painel Admin

Projeto: dizit
Duvida: Qual mecanismo de autorizacao usar? RBAC com policies ou Gates simples?
Aguardando sua resposta para continuar.")
```

## Regras

- Use SEMPRE `type: "instant"` para notificacoes de fluxo de trabalho (nao use scheduled/recurring a menos que o usuario peca explicitamente).
- Se o MCP `nudge` nao estiver configurado (erro de conexao, token ausente), registre a tentativa no Log de Evidencias e continue normalmente — nao bloqueie o fluxo por falta de nudge.
- Nao envie nudge para tarefas L1 (triviais) — apenas L2 e L3.
- Nao envie nudge para cada commit individual — apenas em marcos do fluxo (inicio, conclusao, bloqueio, handoff).
