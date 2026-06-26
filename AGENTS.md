# AGENTS.md - Roteamento de Agentes

Este arquivo e o ponto de entrada comum do projeto. Ele deve ficar curto.

> [!NOTE]
> O mapeamento estruturado de quais IAs podem fazer o que reside no arquivo [agents.json](file://agents.json) (ou no submódulo [aiHub/agents.json](file://aiHub/agents.json)). Use esse arquivo para configurações dinâmicas ou programáticas.

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

## Trava de Cargo

Se a demanda atual nao pertence a nenhum cargo permitido para o seu agente, nao execute.
Consulte a tabela de roteamento atual e responda informando qual agente/cargo deve receber a demanda.

## Override Critico

Se o prompt do humano comecar exatamente com `[SUDO]`, Codex, Gemini e Copilot podem assumir qualquer cargo da tabela de roteamento atual, incluindo cargos normalmente atribuidos ao Claude.

## Paridade Codex/Gemini/Copilot

Codex, Gemini e Copilot possuem exatamente os mesmos cargos neste projeto.

## Roteamento Atual

| Agente | Demanda | Cargo |
|---|---|---|
| Qualquer agente | `.ai/project.md` nao existe, ou humano pede para configurar/revisar o projeto (stack, regras de negocio, ambiente) | `project-planner` |
| Codex, Gemini ou Copilot | entrada inicial, roteamento, recomendacao de agente/modelo | `model-router` |
| Codex, Gemini ou Copilot | requisitos, fases, planos, tasks, issues, decisao de escopo | `technical-lead` |
| Codex, Gemini ou Copilot | descoberta de produto, regra ambigua, criterio de negocio | `product-analyst` |
| Claude | implementacao backend + frontend | `fullstack-engineer` |
| Claude | implementacao backend/API/jobs/services | `backend-engineer` |
| Claude | implementacao UI/frontend | `frontend-engineer` |
| Codex, Gemini ou Copilot | review, testes, validacao, PRs, release | `qa-release-engineer` |
| Codex, Gemini ou Copilot | schema, migrations, queries, indices, performance SQL | `database-engineer` |

## Prioridade

As instrucoes do cargo selecionado vencem este arquivo.
Se houver conflito entre modelo e cargo, o roteamento deste arquivo vence.
Se `.ai/project.md` nao existir, a entrada `project-planner` vence qualquer outro roteamento.

## Contexto Base

O contexto do projeto deve ser lido de:
1. `.ai/project.md` (o que e o projeto, repositorio oficial, idioma da UI, ambiente, link para regras de negocio)
2. `.ai/stack.md` (stack(s)/linguagens do projeto e quais arquivos de `.ai/guidelines/stacks/` consultar)
3. `.ai/guidelines/domain/business-rules/index.md` (indice de regras de negocio especificas)
