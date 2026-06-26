---
name: criar-task
description: Cria um arquivo de tarefa técnica estruturado em .planning/PLAN_VN/tasks/task_X_Y.md com critérios de aceite e especificações detalhadas.
disable-model-invocation: false
---

# Criar Task

> [!IMPORTANT]
> **OBRIGATORIEDADE DE BRAINSTORMING E DIÁLOGO**:
> Você **NUNCA** deve criar ou detalhar arquivos de tarefas (`task_X_Y.md`) sem alinhar com o usuário. Antes de preencher as especificações técnicas, utilize a skill de `brainstorming` ou faça perguntas objetivas uma a uma para definir a UI, os fluxos, as origens de dados e os cenários de teste específicos que o usuário espera. Não assuma nem infira regras de negócio por conta própria.

Esta skill deve ser ativada quando o usuário solicitar a criação de uma nova tarefa no plano, ou via comando `/aihub:criar-task`.

## Fluxo

1. **Definir Identificadores:**
   - Localize o plano ativo e a pasta da fase correspondente (ex: `.planning/PLAN_VN/tasks/` ou `planning/PLAN_VN/tasks/`).
   - Defina o ID da tarefa com base no padrão da fase (ex: `task_1_1.md`, `task_1_2.md`).

2. **Utilizar o Template:**
   - Use o arquivo de template `.ai/templates/task.md` como base absoluta para a criação da tarefa.

3. **Preencher com Alta Especificidade:**
   - Siga rigorosamente a **Especificidade Mínima de Planejamento** indicada em `.ai/guidelines/core/planning.md`:
     - **Menus e Navegação**: Indicar onde a funcionalidade será acessada na UI e visibilidade de regras de permissão.
     - **Origem de Dados**: Tabelas, endpoints de API e relacionamentos envolvidos.
     - **Regras de Validação**: Campos obrigatórios, limites de dados e comportamento em erros de entrada.
     - **Cenários de Teste**: Descrever cenários de sucesso (happy path) e falha/limites.
     - **Recomendação de Modelo**: Declarar no cabeçalho o modelo sugerido, cargo recomendado (role) e motivo.

4. **Vincular Issue GitHub:**
   - Auxilie o usuário na criação e vinculo da GitHub Issue correspondente, salvando o link no cabeçalho da task.
   - Atualize a lista/tabela de tarefas no `plan.md` com a nova tarefa no status `backlog`.
