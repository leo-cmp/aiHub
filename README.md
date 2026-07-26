# l-nexus

**l-nexus** é um kit de contexto portátil para agentes de IA (Claude, Gemini, Codex, Copilot).  
Skills, roles, guidelines e templates versionados — instaláveis em qualquer projeto com um comando.

```bash
npx @leo-cmp/l-nexus install
```

---

## O que vem no pacote

| Componente | Descrição |
|-----------|-----------|
| **Roles** (9 personas) | Backend, frontend, fullstack, database, QA, tech-lead, product-analyst, project-planner, model-router |
| **Skills** (18 skills) | Brainstorming, brainstorming-lite, caveman, criar-plano, criar-task, executar-task, revisar, gerar-prompt, iniciar-projeto, atualizar-projeto, atualizar-aihub + stacks |
| **Guidelines** (core + stacks) | Execution, planning, testing, git/PR, database, frontend, atomic-design, model-selection + Laravel, CI4, Tailwind, daisyUI, Astro |
| **Templates** | plan.md, task.md, task-short.md, issue-local.md |
| **MCP** | context7, github, sequential-thinking, chrome-devtools, daisyui-github |
| **Circuit breakers** | Max 5 skills/sessão, max 3 tentativas/critério, max 10 arquivos/task, loop detection |
| **Memória entre sessões** | session-memory.md + decisions.md (zero dependência externa) |

---

## Instalação

```bash
npx @leo-cmp/l-nexus install
```

Para forçar reinstalação (sobrescreve `.agents/` e `.mcp.json`):

```bash
npx @leo-cmp/l-nexus install-force
```

---

## Atualizar

```bash
npx @leo-cmp/l-nexus install-force
```

---

## Estrutura instalada no projeto

```
projeto/
├── AGENTS.md              ← ponto de entrada do agente (symlink ou cópia)
├── CLAUDE.md              ← idêntico ao AGENTS.md
├── .ai/
│   ├── roles/             ← 9 personas
│   ├── guidelines/
│   │   ├── core/          ← execution, planning, git-pr, testing, etc.
│   │   ├── stacks/        ← Laravel, CI4, Tailwind, daisyUI, Astro
│   │   └── domain/        ← regras de negócio do projeto
│   ├── templates/         ← plan, task, task-short, issue-local
│   ├── project.md         ← config do projeto (preenchido por você)
│   ├── stack.md           ← stacks ativas (preenchido por você)
│   ├── session-memory.md  ← handoff entre sessões
│   └── decisions.md       ← índice de decisões do projeto
├── .agents/
│   └── skills/            ← 18 skills
├── .claude/
│   └── skills -> ../.agents/skills
└── .mcp.json              ← servidores MCP
```

---

## Atalhos do Agente

| Atalho | Ação |
|--------|------|
| `/l-nexus:iniciar` | Bootstrap do projeto (project.md, stack.md, regras) |
| `/l-nexus:criar-plano` | Criar plano de fase |
| `/l-nexus:criar-task` | Criar task detalhada |
| `/l-nexus:atualizar` | Atualizar regras de negócio |
| `/l-nexus:atualizar-aihub` | Atualizar l-nexus para versão mais recente |
| `/l-nexus:brainstorm-lite` | Brainstorming rápido (3 perguntas máx) |
| `/l-nexus:gerar-prompt` | Gerar prompt limpo para nova sessão |

---

## Requisitos

- LLM com instruction following ≥ 85%, janela de contexto ≥ 64K tokens
- Unix (Linux/macOS/WSL)
- Git + GitHub CLI (`gh`) opcional para integração com issues/PRs

Ver [MODEL_REQUIREMENTS.md](MODEL_REQUIREMENTS.md) para detalhes de compatibilidade.

---

## Versão

v0.4.0 — 52 melhorias sobre v0.3.0. Ver `.planning/melhorias/` para histórico completo.
