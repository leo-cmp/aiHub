# Análise: aiHub vs GSD (Get Shit Done)

> Analise comparativa independente — sem viés, sem puxação de saco.
> Data: 2026-07-25 | Versão analisada: aiHub v0.3.0

---

## Sumário

1. [O que é cada um](#1-o-que-e-cada-um)
2. [Comparativo Token: GSD vs aiHub](#2-comparativo-token-gsd-vs-aihub)
3. [Onde aiHub ganha](#3-onde-aihub-ganha)
4. [Onde aiHub perde](#4-onde-aihub-perde)
5. [Análise de Críticas Externas](#5-analise-de-criticas-externas)
6. [Plano de Ação: 7 Melhorias de Baixo Custo](#6-plano-de-acao-7-melhorias-de-baixo-custo)
7. [Veredito Final](#7-veredito-final)

---

## 1. O que é cada um

### GSD (Get Shit Done)

Framework de desenvolvimento **plan-driven** para agentes de IA (Claude Code, principalmente). Pipeline obrigatório: discussão → especificação → planejamento → revisão → execução → verificação → ship. Usa subagentes para cada etapa, estado rastreável em `.planning/`, ~47 skills interligadas.

**Filosofia:** "Nada é tão simples que dispense processo."

### aiHub

Central portátil de **configuração e diretrizes** para agentes de IA (Claude, Codex, Gemini, Copilot). Entregue como submódulo git. Foco em padronização de regras sem pipeline obrigatório. ~17 skills específicas, carregamento lazy, roteamento por cargo.

**Filosofia:** "Voce sabe o que quer; a IA só precisa das regras certas."

---

## 2. Comparativo Token: GSD vs aiHub

| Aspecto | GSD | aiHub |
|---|---|---|
| Skills instaladas | ~47 | ~17 |
| Leitura obrigatória inicial | Workflows + referencias + templates (~2-5k tokens) | AGENTS.md + 1 role (~200-400 tokens) |
| Pipeline por tarefa | discuss → spec → plan → review → execute → verify → ship (vários subagentes) | Atalho direto `/aihub:criar-plano`, `/aihub:criar-task` ou execução direta |
| Subagentes | Múltiplos por fase (cada um leva 1-3k tokens de instrução) | Zero. Tudo na mesma sessão |
| Comunicação | Verbosa (relatórios de fase, checkpoints, logs estruturados) | Caveman mode disponível (corta 65% tokens em respostas longas) |
| Custo por sessão típica | Alto (orquestração pesada) | Baixo (sob demanda) |
| Estado rastreável | `.planning/` completo (planos, tasks, manifestos) | `.ai/templates/` + `.planning/` (minimalista, opcional) |

### 2.1 Simulação de Carga

Cenário: "Adicione campo `is_active` na tabela `users` + migration + checkbox no form."

| Etapa | GSD | aiHub |
|---|---|---|
| Setup de contexto | 2-5k tokens (lê workflows, estado, planos) | 200-400 tokens (AGENTS.md + role + guidelines) |
| Planejamento | Subagente planner: 3-5k tokens | Nada. Vai direto |
| Execução | 5-10k tokens (subagente executor + logs) | 3-5k tokens (execução inline) |
| Verificação | Subagente verifier: 2-4k tokens | `npm test` + `git diff` (1-2k tokens) |
| **Total estimado** | **12-24k tokens** | **5-8k tokens** |

**Fator de economia: 2x a 3x menos tokens para tarefas simples.**

---

## 3. Onde aiHub ganha

### 3.1 Sem subagentes

GSD spawna agente pra pesquisar, planejar, revisar, executar, verificar. Cada spawn = contexto novo + instrução completa + re-leitura de arquivos. aiHub mantém tudo na mesma conversa. Voce decide quando trocar de cargo.

### 3.2 Lazy loading real

GSD carrega workflows, referencias, templates, modos de help, manuais de comando. aiHub só carrega skill quando chamada explicitamente via `/aihub:`. AGENTS.md reforça isso com regra explícita.

### 3.3 Caveman nativo

Skill de compressão de tokens embutida, medida em 65% de redução. Recomendada no proprio AGENTS.md. GSD não tem equivalente.

### 3.4 Context Canary (detector de saturação)

Detector de degradação embutido. Se IA esquecer o nome do usuário, avisa. GSD não tem nada parecido.

### 3.5 Templates minimalistas

`plan.md` = 35 linhas, `task.md` = 52 linhas. GSD tem templates pesados com múltiplos campos obrigatórios.

### 3.6 Portabilidade via submódulo

`git submodule add` + `make install` = pronto. Todas as regras centralizadas e versionadas. GSD é configurado localmente, sem versionamento entre projetos.

### 3.7 Multi-agente

Desenhado pra Claude, Codex, Gemini e Copilot usarem o mesmo conjunto de regras. GSD é fortemente acoplado ao ecossistema Claude/Anthropic.

---

## 4. Onde aiHub perde

### 4.1 Sem automação de pipeline

GSD orquestra fases inteiras sem voce pensar. O `/gsd-execute-phase` lê o plano, executa cada task, verifica, commita, avança. aiHub exige que voce saiba o que quer e chame o atalho certo. Menos tokens, mais responsabilidade sua.

### 4.2 Sem verificação pós-execução

GSD tem `/gsd-verify-work` que faz UAT conversacional, perguntando se o comportamento atende aos critérios. aiHub confia que voce vai testar — sem gate, sem checklist.

### 4.3 Sem code review automático

GSD tem `/gsd-code-review` que revisa diff e acha bugs, security issues, code quality. aiHub tem guidelines de execução mas nenhuma skill de revisão.

### 4.4 Memória entre sessões frágil

Depende de ThreadBridge (ferramenta externa) pra carregar memória no início da sessão. Se não estiver disponível, começa do zero. GSD tem estado rastreável em `.planning/` + arquivos de checkpoint + manifestos.

### 4.5 Rastreabilidade de fase incompleta

GSD mantém planos, tasks, milestones e issues GitHub sincronizados automaticamente via `gh`. aiHub cria os arquivos locais mas não automatiza a sincronização com GitHub.

### 4.6 Skill caveman desligada por padrão

Só ativa se voce pedir ou se o conteúdo for longo o bastante pra AGENTS.md mandar carregar. GSD pelo menos tenta ser conciso nas saídas de help sem precisar de skill extra.

---

## 5. Análise de Críticas Externas

### 5.1 "Burocratização — fluxo pesado pra tarefa simples"

**Veredito: Procedente.**

AGENTS.md impõe: identificar agente → ler índice de roles → ler role → ler guidelines → brainstorming. Pra tarefa tipo "adiciona campo is_active", isso é ~400 tokens de preparação pra 200 tokens de execução.

**Raiz do problema:** O fluxo foi desenhado pra proteger contra IA que faz suposição — e pagou o preço de tratar todo pedido como complexo.

**Solução sugerida:** Fast-track. Se o pedido for `add`/`rename`/`remove` em arquivo existente e não tocar schema novo nem regra de negócio, pula roteamento e vai direto.

### 5.2 "Context Canary gasta tokens à toa"

**Veredito: Parcialmente procedente.**

`"Leo"` é 1 token. O problema é a **reação em cadeia**: IA não solta "Leo" seco — solta "Entendido, Leo! Vou analisar e fazer a alteração..." (~20 tokens). Em 100 interações, são ~1.500-2.000 tokens de fluff.

**Efeito colateral:** O canary acelera a degradação que deveria prevenir. Cada "Entendido, Leo!" enche o contexto com repetição — o que satura a sessão mais rápido. É um loop.

**Solução sugerida:** Substituir por auto-checagem silenciosa. A cada 5 interações, IA verifica internamente: "Ainda lembro o nome do usuário e a task atual?" Se sim, continua sem avisar. Se não, dispara `[CONTEXT DEGRADED] Resumo + próximo passo.` Zero tokens em 80% das interações.

### 5.3 "Dependência de ambiente Unix/GitHub CLI"

**Veredito: Verdade, mas nicho.**

Makefile e scripts (`gh`, `git`) assumem bash/Linux/macOS com GitHub CLI. Windows puro (sem WSL) quebra.

**Por que não é prioridade:** Público alvo do aiHub é dev PHP/Laravel/JS que trabalha em Unix. Windows sem WSL é exceção nesse nicho.

**Solução sugerida:** Guard no Makefile:

```makefile
ifeq ($(OS),Windows_NT)
$(error aiHub Makefile requer ambiente Unix. Use WSL ou instale manualmente.)
endif
```

Uma linha. Informa com educação em vez de quebrar silenciosamente.

### 5.4 "Cadeia de prioridade confusa"

**Veredito: Procedente. Perigoso.**

Regra: "As instruções do cargo selecionado vencem este arquivo. Se conflito entre modelo e cargo, o roteamento deste arquivo vence."

IA com instruções contraditórias não resolve hierarquicamente — alucina uma fusão criativa das duas, geralmente errada.

**Solução sugerida:** Remover hierarquia de regras. AGENTS.md vira só roteamento. Cada role tem escopo claro e mutuamente exclusivo. Se duas roles podem se aplicar, o model-router escolhe uma — nunca as duas.

### 5.5 "Falta de exemplos no repositório"

**Veredito: Procedente. Crítico.**

Estrutura existe (esqueleto) mas sem exemplos reais. Quem clona não vê padrão esperado. Consequência: cada usuário inventa o próprio formato, e o padrão morre.

**Solução sugerida:** Adicionar `examples/` com:
- `.ai/project.md` preenchido
- `.agents/skills/<skill>/SKILL.md` completo
- `.ai/guidelines/stacks/<stack>.md` com conteúdo real
- `plan.md` e `task.md` preenchidos

### 5.6 "Template de task longo demais pra tarefa pequena"

**Veredito: Observação precisa.**

`task.md` tem 52 linhas com Estado Atual, Log de Evidencias, Erros e Correções, Não Verificado. Pra task de 5 minutos, é mais burocracia que código.

**Solução sugerida:** Criar `task-short.md` (15 linhas): objetivo + critérios + plano. Template cheio obrigatório só pra tasks que cruzam +3 arquivos ou envolvem regra de negócio.

### 5.7 "Brainstorming obrigatório contradiz eficiência"

**Veredito: Verdade.**

Skill `brainstorming` tem 164 linhas. Toda vez que é obrigatória, o LLM leu 164 linhas + perguntou + esperou resposta. Pra task trivial, gasta 200+ tokens e tempo real sem necessidade.

**Solução sugerida:** Brainstorming vira **recomendado**, não obrigatório. A AGENTS.md já diz "proibido fazer suposição ou criar arquivo em silêncio" — isso já é gate suficiente.

---

## 6. Plano de Ação: 7 Melhorias de Baixo Custo

| # | Mudança | Onde | Custo | Impacto |
|---|---|---|---|---|
| 1 | **Fast-track:** pular roteamento pra add/rename/remove | `AGENTS.md` | +10 linhas | Elimina 70% do atrito em tarefas simples |
| 2 | **Auto-checagem silenciosa** em vez de nome a cada resposta | `AGENTS.md` | +5 linhas | Economiza ~1.500-2.000 tokens por sessão |
| 3 | **`examples/`** com 4 arquivos preenchidos | `examples/` | +4 arquivos | Usuário entende padrão em 2 minutos |
| 4 | **`task-short.md`** pra tarefa trivial | `.ai/templates/task-short.md` | +1 arquivo (15 linhas) | Menos burocracia no dia a dia |
| 5 | **Guard Windows** no Makefile | `Makefile` | +3 linhas | Zero surpresa pra usuário de Windows |
| 6 | **Remover hierarquia de regras** | `AGENTS.md` | -2 linhas | Zero alucinação por contradição |
| 7 | **Brainstorming não obrigatório** | `AGENTS.md` + skill | +1 linha | Economiza 164 linhas de leitura em tarefas óbvias |

**Total: ~20 linhas alteradas + 5 arquivos criados. Zero subagentes. Zero pipeline novo. Zero custo de tokens.**

### 6.1 Mudanças adicionais (reforço)

| # | Mudança | Onde | Custo | Impacto |
|---|---|---|---|---|
| 8 | Checklist de encerramento obrigatório (teste + git diff) | `execution.md` | +5 linhas | Fim de "implementei mas nao testei" |
| 9 | Skill `revisar` leve (3 perguntas sobre o proprio diff) | `.agents/skills/revisar/SKILL.md` | +1 skill (~15 linhas) | Pega alucinação antes de PR |
| 10 | `session-memory.md` como fallback (se ThreadBridge ausente) | `.ai/session-memory.md` | +1 arquivo (~20 linhas) | Handoff sem ferramenta externa |
| 11 | `scripts/sync-github.sh` para criar milestone/issue | `scripts/` | +1 script (~30 linhas bash) | Issue vinculada sempre, 0 token |
| 12 | Fast-track por keyword (add/rename/remove/schema) | `AGENTS.md` | +5 linhas | Mais preciso que "3 passos" |

---

## 7. Veredito Final

| Dimensão | GSD | aiHub | Vencedor |
|---|---|---|---|
| Custo de tokens | Alto (orquestração pesada) | Baixo (sob demanda) | **aiHub** |
| Automação | Forte (pipeline completo) | Fraca (voce dirige) | **GSD** |
| Segurança contra alucinação | Checklists pós-execução | Context Canary + brainstorming gate | **Empate** |
| Curva de aprendizado | Alta (47 skills, fluxo rigido) | Baixa (atalhos simples) | **aiHub** |
| Handoff entre sessões | State files + checkpoints | ThreadBridge (quando disponivel) | **GSD** |
| Portabilidade | Local | Submódulo git + instalador | **aiHub** |
| Multi-agente | Claude-only | Claude + Codex + Gemini + Copilot | **aiHub** |
| Rigor de processo | Alto (burocrático) | Médio (configurável) | **aiHub** (mais flexivel) |
| Coleta de evidências | Logs estruturados | Log de evidencias na task | **GSD** (mais completo) |

### aiHub é alternativa viável ao GSD? **Sim, com ressalvas.**

**Pra quem é:** Projetos pequenos-médios, devs experientes que sabem o que querem, times multi-agente, ambientes onde token budget é real.

**Pra quem NÃO é:** Projetos complexos com 10+ fases, devs que querem "liga e esquece", ambientes que exigem rastreabilidade forense (auditoria).

**O pulo do gato:** As 7 melhorias sugeridas custam ~20 linhas de mudança e eliminam os pontos fracos sem perder a vantagem de economia de tokens. Depois delas, a diferença entre GSD e aiHub se reduz a:

> GSD = voce contrata um gerente de projetos que gasta 3x mais mas nao deixa escapar nada.
> aiHub = voce contrata um dev sênior que segue as regras e nao enche o saco.

Escolha seu estilo.
