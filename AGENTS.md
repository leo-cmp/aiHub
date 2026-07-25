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

**Nao carregue skills antecipadamente.** A unica skill universal e `caveman` (economia de tokens) — carregue-a sempre que for escrever uma resposta longa.

As demais skills so devem ser lidas quando:
- O usuario acionar um atalho `/aihub:*` explicitamente, OU
- O cargo ativo ou a guideline de stack indicar explicitamente a skill, OU
- A demanda atual exigir o uso de uma skill especifica.

Carregar skills desnecessariamente consome contexto e degrada a sessao. Cada role e guideline de stack ja lista as skills relevantes para aquele contexto.

## Atalhos de Prompt (/aihub)

Se o humano iniciar a mensagem com um dos comandos abaixo, a IA deve carregar a skill correspondente de `.agents/skills/` **naquele momento** e seguir o seu fluxo. Todas as etapas de planejamento ou criação de artefatos **devem obrigatoriamente** passar pelo brainstorming e consulta ativa ao usuário:
- `/aihub:iniciar` ou `/aihub:iniciar-projeto`: Ativa a skill `iniciar-projeto` para configurar `.ai/project.md`, `.ai/stack.md` e regras iniciais de negócio.
- `/aihub:criar-plano` ou `/aihub:criar-plano-fase`: Ativa a skill `criar-plano` para desenhar o plano de uma nova fase local (`.planning/PLAN_VN/plan.md`).
- `/aihub:criar-task` ou `/aihub:criar-tarefa`: Ativa a skill `criar-task` para gerar uma nova tarefa em `.planning/PLAN_VN/tasks/task_X_Y.md` usando o template.
- `/aihub:atualizar` ou `/aihub:atualizar-projeto`: Ativa a skill `atualizar-projeto` para sincronizar novas regras de negócio ou alterações de escopo em `.ai/project.md`.

> [!IMPORTANT]
> **DIRETRIZ DE DIÁLOGO E ALINHAMENTO**: Qualquer agente (Claude, Codex, Gemini ou Copilot) que executar esses atalhos ou qualquer skill de planejamento/codificação está **proibido de fazer suposições ou criar arquivos em silêncio**. A IA deve acionar a skill de `brainstorming`, fazer perguntas uma a uma ao usuário e obter aprovação expressa antes de gravar alterações.

## Fast-Track (L1 — Trivial)

Se a demanda atender TODOS os critérios abaixo, pule o fluxo normal e execute diretamente:
- 1 arquivo afetado (ou 1 migration + 1 model do mesmo domínio)
- Operação: add/rename/remove/change type/fix typo
- Sem criação de schema novo (tabela/nova entidade)
- Sem regra de negócio envolvida
- Sem alteração de interface pública (API/rota)

Fluxo fast-track:
1. Confirme o arquivo alvo existe
2. Faça a alteração
3. Rode lint/teste relacionado
4. Registre no Log de Evidencias (comando + saida + exit code)
5. Reporte concluído

Se QUALQUER dúvida surgir durante o fast-track, aborte e siga o fluxo normal.

## Fluxo Obrigatorio


1. Identifique qual agente voce e: Codex, Claude, Antigravity ou Copilot.
2. Identifique a natureza da demanda atual.
3. Leia `.ai/roles/index.md`.
4. Leia apenas o arquivo do cargo aplicavel.
5. Leia somente as guidelines indicadas pelo cargo ou pela demanda.

Nao carregue todos os cargos nem todas as guidelines por padrao.

Tasks de implementacao devem sempre seguir `.ai/guidelines/core/execution.md`.

## Memoria do Projeto

No inicio de cada sessao, se a ferramenta ThreadBridge estiver disponivel, carregue a memoria do projeto para o diretorio atual antes de analisar o repositorio.

Ao final de sessoes relevantes, atualize a memoria com decisoes, estado atual, pendencias e evidencias importantes.

## Flexibilidade de Agentes e Cargos

Qualquer agente de IA (Claude, Codex, Gemini ou Copilot) pode assumir qualquer papel/cargo descrito na tabela abaixo, dependendo da necessidade do usuário. A divisão serve para orientar o foco e o padrão de comportamento (personas) que a IA deve adotar durante aquela demanda específica.

## Roteamento Atual

| Agente | Demanda | Cargo |
|---|---|---|
| Qualquer agente | `.ai/project.md` nao existe, ou humano pede para configurar/revisar o projeto (stack, regras de negocio, ambiente) | `project-planner` |
| Qualquer agente | entrada inicial, roteamento, recomendacao de agente/modelo | `model-router` |
| Qualquer agente | requisitos, fases, planos, tasks, issues, decisao de escopo | `technical-lead` |
| Qualquer agente | descoberta de produto, regra ambigua, criterio de negocio | `product-analyst` |
| Qualquer agente | implementacao backend + frontend | `fullstack-engineer` |
| Qualquer agente | implementacao backend/API/jobs/services | `backend-engineer` |
| Qualquer agente | implementacao UI/frontend | `frontend-engineer` |
| Qualquer agente | review, testes, validacao, PRs, release | `qa-release-engineer` |
| Qualquer agente | schema, migrations, queries, indices, performance SQL | `database-engineer` |

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

As instrucoes do cargo selecionado vencem este arquivo.
Se houver conflito entre modelo e cargo, o roteamento deste arquivo vence.
Se `.ai/project.md` nao existir, a entrada `project-planner` vence qualquer outro roteamento.

## Contexto Base

O contexto do projeto deve ser lido de:
1. `.ai/project.md` (o que e o projeto, repositorio oficial, idioma da UI, ambiente, link para regras de negocio)
2. `.ai/stack.md` (stack(s)/linguagens do projeto e quais arquivos de `.ai/guidelines/stacks/` consultar)
3. `.ai/guidelines/domain/business-rules/index.md` (indice de regras de negocio especificas)
