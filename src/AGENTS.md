# AGENTS.md - Roteamento de Agentes

Este arquivo e o ponto de entrada comum do projeto. Ele deve ficar curto.

## Identidade da Sessao (Context Canary)

1. Descubra o nome do usuario via `git config user.name` (fallback: "colega").
2. Use o nome do usuario no inicio da PRIMEIRA resposta da sessao.
3. A cada 5 interacoes, faça uma auto-checagem INTERNA (silenciosa):
   - Ainda sei o nome do usuario?
   - Ainda sei a task atual?
   - Ainda sei a branch atual?
   - Ainda sei o ultimo comando executado?
4. Se 2+ itens falharem, emita no inicio da proxima resposta:
   "[CONTEXT DEGRADED] Sessao atual: <task ou ultimo topico>. Proximo passo: <acao>.
   Considere abrir nova sessao e pedir para continuar de onde parou."
5. Se todos os itens passarem, continue normalmente — sem emitir nada.
6. A cada handoff ou fim de sessao, atualize `.ai/session-memory.md`.

## Carregamento de Skills (Lazy Loading)

**Carregue skills apenas quando explicitamente acionadas** (atalho `/aihub:*`, cargo ativo ou guideline de stack).

As demais skills so devem ser lidas quando:
- O usuario acionar um atalho `/aihub:*` explicitamente, OU
- O cargo ativo ou a guideline de stack indicar explicitamente a skill, OU
- A demanda atual exigir o uso de uma skill especifica.

**Limite de skills por sessao:** Maximo de 5 skills carregadas. Apos atingir o limite:
- Se a demanda exigir mais skills, considere encerrar a sessao atual e abrir nova.
- Skills como `caveman` (carregada no boot) contam no limite.
- Skills de stack (`laravel-best-practices`, `tailwindcss-development`, etc.) contam individualmente.

Carregar skills desnecessariamente consome contexto e degrada a sessao. Cada role e guideline de stack ja lista as skills relevantes para aquele contexto.

## Atalhos de Prompt (/aihub)

Se o humano iniciar a mensagem com um dos comandos abaixo, a IA deve carregar a skill correspondente de `.agents/skills/` **naquele momento** e seguir o seu fluxo. Todas as etapas de planejamento ou criação de artefatos **devem obrigatoriamente** passar pelo brainstorming e consulta ativa ao usuário:
- `/aihub:iniciar` ou `/aihub:iniciar-projeto`: Ativa a skill `iniciar-projeto` para configurar `.ai/project.md`, `.ai/stack.md` e regras iniciais de negócio.
- `/aihub:criar-plano` ou `/aihub:criar-plano-fase`: Ativa a skill `criar-plano` para desenhar o plano de uma nova fase local (`.planning/PLAN_VN/plan.md`).
- `/aihub:criar-task` ou `/aihub:criar-tarefa`: Ativa a skill `criar-task` para gerar uma nova tarefa em `.planning/PLAN_VN/tasks/task_X_Y.md` usando o template.
- `/aihub:atualizar` ou `/aihub:atualizar-projeto`: Ativa a skill `atualizar-projeto` para sincronizar novas regras de negócio ou alterações de escopo em `.ai/project.md`.
- `/aihub:brainstorm-lite`: Ativa a skill `brainstorming-lite` para tarefas L2.
- `/aihub:atualizar-aihub`: Ativa a skill `atualizar-aihub` para atualizar o aiHub para a versao mais recente.
- `/aihub:gerar-prompt`: Ativa a skill `gerar-prompt` para gerar prompt de continuacao para nova sessao.

> [!IMPORTANT]
> **DIRETRIZ DE DIÁLOGO E ALINHAMENTO**: Qualquer agente que executar atalhos de planejamento/codificação está proibido de fazer suposições ou criar arquivos em silêncio.
> - **L2 (Padrão):** Use `brainstorming-lite` — 3 perguntas máx, sem spec document.
> - **L3 (Complexo):** Use `brainstorming` completo — spec document + visual companion opcional.

## Níveis de Complexidade

Antes de executar qualquer fluxo, classifique a demanda:

| Nível | Gatilho | Fluxo |
|-------|---------|-------|
| **L1 — Trivial** | 1 arquivo, add/rename/remove, sem schema novo | Fast-track: vai direto, sem brainstorming |
| **L2 — Padrão** | 2-5 arquivos, com ou sem schema | Fluxo normal + brainstorming-lite |
| **L3 — Complexo** | 5+ arquivos, múltiplos domínios, regra de negócio nova | Fluxo completo + brainstorming completo + spec |

Se houver dúvida entre níveis, suba um nível (ex: duvida L1/L2 → L2).

Se L3: aplique também os circuit breakers (máx 10 arquivos, máx 5 skills, máx 3 tentativas por critério).

## Fast-Track (L1 — Trivial)

Se a demanda atender TODOS os critérios abaixo, pule o fluxo normal e execute diretamente:

**Gatilhos por keyword (dispensa analise):**
- "adiciona campo X na tabela Y"
- "renomeia X para Y"
- "remove X"
- "corrige typo em X"
- "muda tipo de X para Y"

**Critérios de elegibilidade:**
- 1 arquivo afetado (ou 1 migration + 1 model do mesmo domínio)
- Sem criação de schema novo (tabela/nova entidade)
- Sem regra de negócio envolvida
- Sem alteração de interface pública (API/rota)

Fluxo fast-track:
1. Confirme o arquivo alvo existe
2. Faça a alteração
3. Rode lint/teste relacionado
4. Registre no Log de Evidencias (comando + exit code + resumo 1 linha)
5. Reporte concluído

Se QUALQUER dúvida surgir durante o fast-track, aborte e siga o fluxo normal.

## Fluxo Obrigatorio


1. Identifique a natureza da demanda atual.
2. Leia `.ai/roles/index.md`.
3. Leia apenas o arquivo do cargo aplicavel.
4. Leia somente as guidelines indicadas pelo cargo ou pela demanda.
5. Verifique as skills listadas na role: para cada skill, confirme que o diretorio existe em `.agents/skills/<skill>/`.
   - Se existir: carregue quando necessario.
   - Se NAO existir: ignore a skill (nao tente carregar) e mencione no inicio da execucao: "Role referencia skill `<skill>` que nao existe no projeto."
6. Carregue a skill `caveman` (`.agents/skills/caveman/SKILL.md`) — ela está no próprio aiHub.

Nao carregue todos os cargos nem todas as guidelines por padrao.

Tasks de implementacao devem sempre seguir `.ai/guidelines/core/execution.md`.

**Limite de escopo:** Nenhuma task deve modificar mais de 10 arquivos.
Se a implementacao exigir mais:
- Quebre em sub-tasks menores.
- Cada sub-task deve ter seu proprio criterio de aceite e PR.
- Tasks L3 (complexas) naturalmente exigem quebra — nunca implemente L3 como task unica.

## Memória entre Sessões

No início de cada sessão:
1. Leia `.ai/session-memory.md`.
2. Se contiver task ativa e "Próximo Passo", retome de onde parou.
3. Confira se branch e task ainda são válidas (`git branch --show-current`).
4. Se o arquivo estiver vazio ou não existir, siga o fluxo normal de roteamento.

Ao final da sessão (ou quando contexto degradar — ver Context Canary):
1. Atualize `.ai/session-memory.md` com:
   - Task ativa e status
   - Branch atual
   - Último comando executado com exit code
   - Progresso (checklist do que foi feito/falta)
   - Pendências e bloqueios
   - Próximo passo prioritário
2. Se decisões de arquitetura, stack ou regras foram tomadas, registre em `.ai/decisions.md`.
3. Atualize o cabeçalho com data/hora, agente e modelo.

Importante:
- Seja conciso. Máximo 50 linhas no total.
- Use checkboxes `[x]` / `[ ]` para progresso.
- Liste bloqueios com clareza para o próximo agente decidir.

## Flexibilidade de Agentes e Cargos

Qualquer agente de IA pode assumir qualquer cargo. A divisão orienta o foco e comportamento que a IA deve adotar durante aquela demanda.

## Roteamento Atual

| Demanda | Cargo |
|---|---|
| `.ai/project.md` nao existe, ou humano pede para configurar/revisar o projeto (stack, regras de negocio, ambiente) | `project-planner` |
| entrada inicial, roteamento, recomendacao de agente/modelo | `model-router` |
| requisitos, fases, planos, tasks, issues, decisao de escopo | `technical-lead` |
| descoberta de produto, regra ambigua, criterio de negocio | `product-analyst` |
| implementacao backend + frontend | `fullstack-engineer` |
| implementacao backend/API/jobs/services | `backend-engineer` |
| implementacao UI/frontend | `frontend-engineer` |
| review, testes, validacao, PRs, release | `qa-release-engineer` |
| schema, migrations, queries, indices, performance SQL | `database-engineer` |

## Protocolo de Handoff

Quando o contexto degradar (detectado pelo Context Canary ou pelo usuario):

1. Atualize o estado de todas as tasks ativas em `.planning/`.
2. Registre no arquivo da task ativa:
   - O que foi feito (com evidencias: comando + saida + exit code).
   - O que falta.
   - Proximo passo prioritario.
   - Erros conhecidos.
3. Se ThreadBridge estiver disponivel, salve a memoria.
4. Informe o usuario: "Sessao pronta para handoff. Abra nova sessao e peca para continuar de onde parou."

Na nova sessao, o agente deve ler `.planning/` e a task ativa para retomar do ponto exato.

## Prioridade

O sistema tem estados mutuamente exclusivos — apenas um se aplica por vez:

1. `.ai/project.md` NAO existe → única ação: `project-planner` (bootstrap do projeto).
2. `.ai/project.md` existe + task definida em `.planning/` → única ação: executar task conforme cargo indicado.
3. `.ai/project.md` existe + sem task definida → única ação: `model-router` ou `technical-lead` decide.

Não há conflito de prioridade — cada estado tem uma única ação válida.
Se houver ambiguidade sobre qual estado se aplica, pergunte ao usuário.

## Contexto Base

O contexto do projeto deve ser lido de:
1. `.ai/project.md` (o que e o projeto, repositorio oficial, idioma da UI, ambiente, link para regras de negocio)
2. `.ai/stack.md` (stack(s)/linguagens do projeto e quais arquivos de `.ai/guidelines/stacks/` consultar)
3. `.ai/guidelines/domain/business-rules/index.md` (indice de regras de negocio especificas)
4. `.ai/session-memory.md` (estado da última sessão)
5. `.ai/decisions.md` (decisões de arquitetura/stack/regras)
