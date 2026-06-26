---
name: criar-plano
description: Cria uma nova fase local de desenvolvimento em .planning/PLAN_VN/plan.md, estruturando marcos e o roadmap inicial da fase.
disable-model-invocation: false
---

# Criar Plano de Fase

Esta skill deve ser ativada quando o usuário solicitar o planejamento de uma nova fase, ou via comando `/aihub:criar-plano`.

## Fluxo

1. **Definir a Fase:**
   - Identifique a próxima versão/fase incremental (`PLAN_V1`, `PLAN_V2`, etc.) analisando as pastas existentes em `.planning/` ou `planning/`.
   - Crie o diretório correspondente da fase: `.planning/PLAN_VN/` (ou `planning/PLAN_VN/` dependendo da convenção do projeto).

2. **Consultar Requisitos e Regras:**
   - Revise minuciosamente o `.ai/project.md` e as diretrizes de regras de negócio em `.ai/guidelines/domain/business-rules/` para garantir o alinhamento comercial e técnico.

3. **Gerar o `plan.md`:**
   - Crie o arquivo de ponto de entrada da fase em `.planning/PLAN_VN/plan.md` (ou `planning/PLAN_VN/plan.md`).
   - Adicione descrição clara da fase, objetivos de negócio, dependências técnicas, requisitos técnicos e a lista de tarefas planejadas (tasks) com status iniciais como `backlog`.

4. **Alinhamento com Issues do GitHub:**
   - Apoie o usuário no alinhamento das tarefas com o repositório remoto. Sugira e oriente a criação de um Milestone público no repositório oficial no formato `VN - Nome da fase` (onde N é a versão da fase).
