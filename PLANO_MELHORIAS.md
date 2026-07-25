# Plano de Melhorias — aiHub v0.3.0 → v0.4.0

Todas as melhorias identificadas nas análises (ANALISE_FREE.md + ANALISE_DEEPSEEK_V4_PRO.md),
consolidadas por categoria e prioridade.

Prioridade: 🔴 Crítica | 🟡 Alta | 🟢 Média | ⚪ Baixa
Esforço: S (pequeno, <30 min) | M (médio, 1-3h) | L (grande, >3h)

---

## 1. Tokenomia e Contexto

| # | Melhoria | Prioridade | Esforço | Fonte |
|---|----------|-----------|---------|-------|
| 1.1 | **Auto-checagem silenciosa**: verificar nome + task + branch a cada 5 interações, emitir alerta só se degradado | 🔴 | S | Ambas |
| 1.2 | **Fast-track**: pular roteamento para add/rename/remove em 1 arquivo, sem schema novo | 🔴 | S | FREE |
| 1.3 | **Brainstorming-lite** (15 linhas, 3 perguntas máx): para tarefas L2; brainstorming completo (164 linhas) só para L3 | 🔴 | M | DEEPSEEK |
| 1.4 | **Brainstorming não obrigatório**: mudar de "MUST" para recomendado; AGENTS.md já tem gate suficiente | 🟡 | S | FREE |
| 1.5 | **Níveis L1/L2/L3**: triagem automática de complexidade da tarefa; L1 pula roteamento, L3 usa fluxo completo | 🟡 | S | DEEPSEEK |
| 1.6 | **Fast-track por keyword**: disparar em `add`/`rename`/`remove`/`fix typo` | 🟢 | S | FREE |
| 1.7 | **task-short.md** (15 linhas): template alternativo para tarefa que toca ≤2 arquivos, sem regra de negócio | 🟢 | S | FREE |
| 1.8 | **Caveman carregado no boot**: remover lazy loading do caveman; carregar junto com a role, sempre. A skill já está em `.agents/skills/caveman/` do próprio aiHub — não depende do projeto ter. 400 tokens de overhead se pagam na 2ª ou 3ª resposta longa | 🔴 | S | Ambas |

---

## 2. Robustez do Sistema de Regras

| # | Melhoria | Prioridade | Esforço | Fonte |
|---|----------|-----------|---------|-------|
| 2.1 | **Eliminar hierarquia de prioridade**: AGENTS.md vira só roteamento; cada estado tem 1 ação mutuamente exclusiva | 🔴 | S | Ambas |
| 2.2 | **Criar `scripts/validate.sh`**: verifica que toda skill referenciada existe, toda guideline existe, sem links quebrados, sem contradições | 🔴 | M | DEEPSEEK |
| 2.3 | **Resolver skills fantasmas**: `systematic-debugging`, `test-driven-development`, `writing-plans`, `requesting-code-review`, `receiving-code-review`, `finishing-a-development-branch`, `verification-before-completion` → criar ou remover das roles | 🔴 | M | DEEPSEEK |
| 2.4 | **Reformular negações como afirmações**: "Não use float" → "Use DECIMAL(15,2)"; "NUNCA SUPONHA" → "Pare e pergunte quando houver ambiguidade" | 🟡 | M | DEEPSEEK |
| 2.5 | **Fallback explícito para `project.md` inexistente**: AGENTS.md declara o que fazer quando arquivo referenciado não existe | 🟡 | S | DEEPSEEK |
| 2.6 | **Skill auto-discovery nas roles**: antes de listar skills, verificar se existem | 🟢 | S | DEEPSEEK |
| 2.7 | **Guard Windows no Makefile**: `ifeq ($(OS),Windows_NT)` com mensagem clara | ⚪ | S | FREE |

---

## 3. Memória e Handoff entre Sessões

| # | Melhoria | Prioridade | Esforço | Fonte |
|---|----------|-----------|---------|-------|
| 3.1 | **`session-memory.md` como fallback**: handoff sem depender de ThreadBridge. AGENTS.md remove referência ao ThreadBridge — aiHub não depende de ferramenta externa não controlada | 🔴 | S | Ambas |
| 3.2 | **`decisions.md`** (índice de decisões): registra cada decisão de arquitetura/stack/regra com data, contexto e rationale. Substitui o que o ThreadBridge fazia com `facts[]` | 🟡 | S | DEEPSEEK |
| 3.3 | **Contador de tentativas na task**: se mesmo critério falhar 3x consecutivas, pausa e pede intervenção | 🟡 | S | DEEPSEEK |

### Especificação Detalhada: Memória entre Sessões

#### 3.1 — `.ai/session-memory.md`

**Localização:** `src/.ai/session-memory.md` → instalado no projeto alvo como `.ai/session-memory.md`.

**Formato:**

```markdown
# Memória de Sessão

> Última sessão: 2026-07-25 14:30 | Agente: Claude | Modelo: deepseek-v4-pro

## Estado Atual
- **Task ativa:** `.planning/PLAN_V1/tasks/task_1_2.md` (status: in_progress)
- **Branch:** `feat/cadastro-fornecedores`
- **Último comando:** `php spark migrate → Migrated: 2026-07-25_CreateSuppliers (exit 0)`

## Progresso
- [x] Migration `CreateSuppliers` criada e executada
- [x] Model `Supplier` com relationships
- [ ] Controller `SupplierController` (em andamento — faltam métodos update/delete)
- [ ] Validação de CNPJ (não iniciado)

## Pendências e Bloqueios
- Issue #47 aguardando definição do humano sobre formato de CNPJ (com máscara ou sem?)
- Testes de integração dependem do item acima

## Próximo Passo
1. Aguardar resposta sobre formato CNPJ
2. Implementar update/delete no Controller
3. Rodar `php spark test --group suppliers`
4. Criar PR
```

**Ciclo de vida:**

| Momento | Ação | Quem |
|---------|------|------|
| **Início da sessão** | Ler `.ai/session-memory.md`. Se existir, retomar do `Próximo Passo`. Se não existir, começar fluxo normal | LLM (via AGENTS.md) |
| **Handoff (contexto degradado)** | Atualizar `Estado Atual`, `Progresso`, `Pendências` e `Próximo Passo`. Comitar | LLM (via AGENTS.md) |
| **Fim de sessão normal** | Atualizar campos com estado final | LLM (via AGENTS.md) |
| **Ao concluir task** | Atualizar progresso, mover para próxima task | LLM (via AGENTS.md) |
| **Ao encontrar bloqueio** | Registrar em `Pendências e Bloqueios` imediatamente | LLM (via AGENTS.md) |

**Integração no AGENTS.md:** Adicionar nova seção `## Memória entre Sessões`:

```
## Memória entre Sessões

No início de cada sessão, leia `.ai/session-memory.md`.
Se existir:
  - Retome do "Próximo Passo" listado.
  - Confira se a branch e task ativa ainda são válidas (`git branch --show-current`).
Se não existir:
  - Siga o fluxo normal de roteamento.
  - Crie o arquivo após a primeira interação relevante.

Ao final da sessão (ou quando o contexto degradar):
  - Atualize `.ai/session-memory.md` com estado atual, progresso e próximo passo.
  - Se `.ai/decisions.md` foi alterado, confirme que está atualizado.
```

Remover o bloco atual `## Memoria do Projeto` que menciona ThreadBridge.

---

#### 3.2 — `.ai/decisions.md`

**Localização:** `src/.ai/decisions.md` → instalado no projeto alvo como `.ai/decisions.md`.

**Formato:**

```markdown
# Índice de Decisões

> Registro cronológico de decisões de arquitetura, stack e regras de negócio.

---

## 2026-07-25 10:15 — Usar DECIMAL(15,2) para valores monetários

**Contexto:** Model `Invoice` e `Payment` precisam armazenar valores em reais.

**Decisão:** Usar `DECIMAL(15,2)` em vez de `FLOAT` ou `INTEGER` (centavos).

**Rationale:** `FLOAT` perde precisão em somas; `INTEGER` (centavos) funciona mas dificulta queries com divisão e relatórios. `DECIMAL(15,2)` é o padrão do MySQL/PostgreSQL para moeda.

**Alternativas consideradas:** INTEGER para centavos (descartado — complexidade em relatórios). FLOAT (descartado — proibido por guideline).

**Impacto:** Todas as migrations de tabelas financeiras devem usar este tipo. Ver `.ai/guidelines/core/database.md`.

---

## 2026-07-24 16:00 — Não usar Filament para área pública

**Contexto:** Área de checkout e catálogo público.

**Decisão:** Manter área pública com Blade + Tailwind + Livewire. Filament só no painel admin.

**Rationale:** Filament é pesado para páginas públicas de alta taxa de acesso. SEO e performance são prioridade no catálogo.

**Alternativas consideradas:** Filament full-stack (descartado — bundle size e SEO ruins). React SPA (descartado — complexidade desnecessária para o time).

**Impacto:** Tasks de frontend público devem referenciar `.ai/guidelines/stacks/tailwind.md`.
```

**Ciclo de vida:**

| Momento | Ação | Quem |
|---------|------|------|
| **Decisão tomada** | Adicionar entrada com data, contexto, decisão, rationale, alternativas, impacto | LLM |
| **Início da sessão** | Ler `.ai/decisions.md` junto com `session-memory.md` | LLM (via AGENTS.md) |
| **Ao iniciar nova task** | Percorrer decisões relevantes ao domínio da task | LLM (via AGENTS.md) |
| **Decisão revogada** | Marcar como `~~revogada em YYYY-MM-DD — ver [link para nova decisão]~~` (nunca remover) | LLM |

**Regras:**
- Nunca remover entradas. Se revogar, riscar e linkar a nova.
- Máximo 10 linhas por entrada (contexto + decisão + rationale + impacto).
- Se uma decisão é longa (>10 linhas), criar arquivo separado `.ai/decisions/<tema>.md` e linkar do índice.
- AGENTS.md referencia `decisions.md` no bloco `## Contexto Base` (junto com `project.md` e `stack.md`).

---

#### Mudanças no AGENTS.md

Remover:
```
## Memoria do Projeto
No inicio de cada sessao, se a ferramenta ThreadBridge estiver disponivel...
```

Adicionar:
```
## Memória entre Sessões
1. Leia `.ai/session-memory.md` e `.ai/decisions.md` no início da sessão.
2. Se `.ai/session-memory.md` existir, retome do "Próximo Passo".
3. Ao final da sessão ou em handoff, atualize `.ai/session-memory.md`.
4. A cada decisão significativa, registre em `.ai/decisions.md`.
```

E no `## Contexto Base`, adicionar `4. .ai/decisions.md` na lista.

---

## 4. Verificação e Anti-Alucinação

| # | Melhoria | Prioridade | Esforço | Fonte |
|---|----------|-----------|---------|-------|
| 4.1 | **Checklist de encerramento obrigatório** (teste + git diff) no `execution.md` | 🔴 | S | FREE |
| 4.2 | **Skill `revisar`** leve (15 linhas, 3 perguntas sobre o próprio diff) | 🟡 | S | FREE |
| 4.3 | **Sanity check pré-execução**: verificar que tabelas/models/rotas da task existem no código antes de implementar | 🟡 | M | DEEPSEEK |
| 4.4 | **Test relevance check**: antes de considerar testes como prova, confirmar que ≥1 teste cobre o código alterado | 🟢 | S | DEEPSEEK |
| 4.5 | **Log de evidências com resumo**: `comando → exit code (resumo 1 linha; saída completa em arquivo)` para outputs longos | 🟢 | S | DEEPSEEK |

---

## 5. Integração com GitHub e Automação

| # | Melhoria | Prioridade | Esforço | Fonte |
|---|----------|-----------|---------|-------|
| 5.1 | **Modo offline sem `gh`**: criar issues como `.md` local quando CLI indisponível; sincronizar depois com `sync-github.sh` | 🔴 | M | DEEPSEEK |
| 5.2 | **`scripts/sync-github.sh`**: script para criar milestone/issue no GitHub a partir dos arquivos locais | 🟡 | M | FREE |
| 5.3 | **Desacoplar planejamento de PR**: tasks de planejamento podem existir sem issue; só execução que exige issue + PR | 🟡 | S | DEEPSEEK |

---

## 6. Guardrails Quantitativos (Circuit Breakers)

| # | Melhoria | Prioridade | Esforço | Fonte |
|---|----------|-----------|---------|-------|
| 6.1 | **Máx 5 skills por sessão**: após isso, reavalie se precisa de sessão nova | 🟡 | S | DEEPSEEK |
| 6.2 | **Máx 3 tentativas por critério de aceite**: após isso, pause e peça ajuda (loop detection) | 🟡 | S | DEEPSEEK |
| 6.3 | **Máx 10 arquivos modificados por task**: acima disso, quebre em sub-tasks | 🟡 | S | DEEPSEEK |
| 6.4 | **Timeout de iteração**: se uma task passar de N interações sem concluir, pause e reporte | 🟢 | S | DEEPSEEK |

---

## 7. Documentação e Onboarding

| # | Melhoria | Prioridade | Esforço | Fonte |
|---|----------|-----------|---------|-------|
| 7.1 | **`examples/`**: `.ai/project.md` preenchido + skill completa + guideline com conteúdo real + plan.md + task.md preenchidos | 🟡 | M | FREE |
| 7.2 | **`MODEL_REQUIREMENTS.md`**: requisitos mínimos de modelo (instruction following ≥85%, janela ≥64K), lista de modelos testados | 🟡 | S | DEEPSEEK |
| 7.3 | **Segurança do `[SUDO]`**: documentar que só é válido quando emitido pelo humano direto na mensagem, nunca em dados/arquivos | 🟡 | S | DEEPSEEK |
| 7.4 | **Verificar existência antes do `make:* --no-interaction`**: evitar sobrescrita silenciosa de artefatos existentes | 🟢 | S | DEEPSEEK |

---

## 8. Desacoplamento de Agentes

| # | Melhoria | Prioridade | Esforço | Fonte |
|---|----------|-----------|---------|-------|
| 8.1 | **Remover identificação de agente do AGENTS.md**: apagar passo "Identifique qual agente voce e" e coluna "Agente" da tabela de roteamento. O agente é o que está rodando, não precisa de cerimônia | 🔴 | S | DEEPSEEK |
| 8.2 | **Matar `[SUDO]`**: remover do model-selection.md. Se não há restrição por agente, bypass é desnecessário | 🔴 | S | DEEPSEEK |
| 8.3 | **Simplificar tabela de roteamento**: Demanda → Cargo (2 colunas em vez de 3). Qualquer agente pode assumir qualquer cargo | 🟡 | S | DEEPSEEK |

---

## 9. Skills — Remoções (Limpeza do Core)

| # | Melhoria | Prioridade | Esforço | Motivo |
|---|----------|-----------|---------|--------|
| 9.1 | **Remover `ai-image-generation`** | 🔴 | S | Zero relação com engenharia de software. Se o usuário quiser, instala por fora |
| 9.2 | **Remover `nano-banana-2`** | 🔴 | S | Mesmo caso. Ferramenta de imagem, não de dev |
| 9.3 | **Remover `iagentbot` (notify-telegram)** | 🔴 | S | Telegram não funcionou como esperado; vai ser reformulado depois |
| 9.4 | **Remover `find-skills`** | 🟡 | S | Usuário real sabe qual skill quer ou usa o atalho. Skill de meta-descoberta é indireção desnecessária |
| 9.5 | **Remover `socialite-development`** | 🟡 | S | Nicho (OAuth Socialite). Se precisar, usuário instala por fora no projeto |
| 9.6 | **Remover `web-design-guidelines`** | 🟢 | S | Overlap com `frontend-design` + `daisyui`; redundante no core |

---

## 10. Skills — Criações (O que Falta)

| # | Melhoria | Prioridade | Esforço | Descrição |
|---|----------|-----------|---------|-----------|
| 10.1 | **Criar `revisar`** | 🔴 | S | Code review leve do próprio diff (~15 linhas, 3 perguntas). Pega alucinação antes do PR |
| 10.2 | **Criar `brainstorming-lite`** | 🔴 | S | 3 perguntas máx, sem visual companion, sem spec document. Para L2 |
| 10.3 | **Criar `atualizar-aihub`** | 🟡 | S | `/aihub:atualizar` — fluxo de fetch + reset + instalar + reportar versão. Substitui `make git-update` |
| 10.4 | **Criar `ci4-best-practices`** | 🟡 | M | CodeIgniter 4 best practices (equivalente ao `laravel-best-practices`). Usuário usa mais CI4 que Laravel |
| 10.5 | **Skills fantasmas → decidir destino**: `systematic-debugging`, `test-driven-development`, `writing-plans`, `requesting-code-review`, `receiving-code-review`, `finishing-a-development-branch`, `verification-before-completion` — criar ou remover referências das roles | 🟡 | M | DEEPSEEK |

---

## 11. Distribuição e Instalação

| # | Melhoria | Prioridade | Esforço | Descrição |
|---|----------|-----------|---------|-----------|
| 11.1 | **Substituir Makefile por `scripts/install.sh`**: bootstrap (symlinks, pastas, .mcp.json, project.md inicial). Makefile sai | 🔴 | M | Makefile é sobre-engenharia; script bash simples é mais portátil e manutenível |
| 11.2 | **`npx aihub install` (v0.5+)**: empacotar como pacote npm. Instala tudo (skills são minúsculas, lazy loading ignora o que não usa). Docs/exemplos não vão junto. Sem wizard interativo — complexidade desnecessária | 🟡 | L | Fase separada. Resolve "não clonar tudo" e permite distribuição limpa |
| 11.3 | **Migrar assets para `src/`**: `AGENTS.md`, `.agents/`, `.ai/`, `.mcp.json` → `src/`. Raiz do repo fica só com `scripts/`, `docs/`, README, INSTALL, VERSION. `install.sh` lê de `src/` e instala no projeto alvo. aiHub nunca se instala em si mesmo — é só fonte | 🟡 | M | Separação clara entre "o que é o repo" e "o que vai pro projeto". Agente abrindo o repo não carrega nada automaticamente |

| Categoria | Ações | 🔴 Críticas | 🟡 Altas | 🟢 Médias | ⚪ Baixas |
|-----------|-------|------------|---------|----------|---------|
| 1. Tokenomia e Contexto | 8 | 4 | 2 | 2 | 0 |
| 2. Robustez de Regras | 7 | 3 | 2 | 1 | 1 |
| 3. Memória e Handoff | 3 | 1 | 2 | 0 | 0 |
| 4. Verificação e Anti-Alucinação | 5 | 1 | 2 | 2 | 0 |
| 5. Integração GitHub | 3 | 1 | 2 | 0 | 0 |
| 6. Guardrails Quantitativos | 4 | 0 | 3 | 1 | 0 |
| 7. Documentação e Onboarding | 4 | 0 | 3 | 1 | 0 |
| 8. Desacoplamento de Agentes | 3 | 2 | 1 | 0 | 0 |
| 9. Skills — Remoções | 6 | 3 | 2 | 1 | 0 |
| 10. Skills — Criações | 5 | 2 | 3 | 0 | 0 |
| 11. Distribuição e Instalação | 3 | 1 | 2 | 0 | 0 |
| **Total** | **51** | **18** | **24** | **8** | **1** |

### Ordem de Ataque Sugerida (Quick Wins Primeiro)

```
PHASE 1 (1-2h): 🔴 críticas de esforço S
├── 1.1 Auto-checagem silenciosa
├── 1.2 Fast-track L1
├── 1.8 Caveman carregado no boot
├── 2.1 Eliminar hierarquia de prioridade
├── 2.5 Fallback project.md
├── 3.1 session-memory.md
├── 4.1 Checklist de encerramento
├── 5.3 Desacoplar planejamento de PR
├── 8.1 Remover identificação de agente do AGENTS.md
├── 8.2 Matar [SUDO]
├── 9.1 Remover ai-image-generation
├── 9.2 Remover nano-banana-2
├── 9.3 Remover iagentbot
├── 10.1 Criar skill revisar
└── 10.2 Criar brainstorming-lite

PHASE 2 (2-3h): 🔴 críticas de esforço M + 🟡 mais impactantes
├── 1.3 Brainstorming-lite
├── 2.2 scripts/validate.sh
├── 2.3 Resolver skills fantasmas
├── 5.1 Modo offline sem gh
├── 6.1-6.3 Circuit breakers
├── 8.3 Simplificar tabela de roteamento
├── 9.4 Remover find-skills
├── 9.5 Remover socialite-development
├── 10.3 Criar atualizar-aihub
├── 10.5 Destino das skills fantasmas
└── 11.1 Substituir Makefile por install.sh

PHASE 3 (2-3h): 🟡 restantes + 🟢
├── 1.5 Níveis L1/L2/L3
├── 2.4 Reformular negações
├── 3.2 decisions.md
├── 3.3 Contador de tentativas
├── 4.2 Skill revisar
├── 4.3 Sanity check
├── 5.2 sync-github.sh
├── 7.1 examples/
├── 7.2 MODEL_REQUIREMENTS.md
├── 7.3 Segurança [SUDO] → já removido, substituir por documentação de segurança geral
├── 9.6 Remover web-design-guidelines
├── 10.4 Criar ci4-best-practices
├── 11.2 Planejar npx aihub install (v0.5+)
└── 11.3 Migrar assets para src/

PHASE 4 (<1h): ⚪ baixas + 🟢 restantes
├── 1.6 Fast-track keyword
├── 1.7 task-short.md
├── 2.6 Skill auto-discovery
├── 2.7 Guard Windows
├── 4.4 Test relevance check
├── 4.5 Log com resumo
├── 6.4 Timeout de iteração
└── 7.4 Verificação pré make:*
```

**Tempo total estimado: 8-10 horas.** Após Phase 1, o sistema já elimina os 3 maiores pontos de atrito (token waste, hierarquia confusa, falta de fallback). Após Phase 2, o sistema é robusto perante modelos mais fracos e ambientes sem GitHub CLI.
