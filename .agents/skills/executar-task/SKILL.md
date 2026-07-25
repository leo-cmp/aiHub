---
name: executar-task
description: Localiza, valida e executa a proxima task pendente em .planning/, registrando evidencias de progresso.
disable-model-invocation: false
---

# Executar Task

## Fluxo

1. **Localizar a task:**
   - Leia `.planning/PLAN_VN/plan.md` do plano ativo.
   - Identifique a proxima task com status `backlog` ou `in_progress` na ordem de execucao.
   - Abra apenas o arquivo da task identificada (nao carregue todas as tasks).

2. **Validar a task:**
   - Confirme que a task tem: `id`, `title`, `created_at`, `status`, `criterios de aceite`.
   - Confirme que existe issue vinculada (GitHub ou local).
   - Se o campo `issue:` apontar para caminho local (ex: `.planning/.../issue_X.md`), a task pode prosseguir.
   - Se for task executavel sem issue alguma, pare e crie a issue primeiro.
   - Se faltar informacao, pare e pergunte ao usuario.

3. **Preparar execucao:**
   - > [!IMPORTANT]
     > **BRAINSTORMING E DESIGN PRÉVIO MANDATÓRIO**:
     > Antes de modificar ou criar qualquer arquivo de código operacional do projeto, invoque a skill de `brainstorming` para apresentar sua proposta de design técnico e arquitetura para a tarefa. Faça perguntas uma a uma sobre pontos ambíguos e obtenha aprovação expressa do design pelo usuário. **Não faça suposições nem decida caminhos de implementação de forma silenciosa.**
   - > **Brainstorming para L2:** Para tarefas de complexidade padrao (2-5 arquivos, sem nova regra de negocio), use `brainstorming-lite` em vez de `brainstorming` completo.
   - Atualize `status: in_progress` e `updated_at` com data/hora atual.
   - Confirme que esta em branch propria da task (nao em main/develop).
   - Identifique o cargo (`role`) indicado na task (campo `role` no cabecalho ou no corpo da task).
   - Leia o arquivo de role correspondente em `.ai/roles/<role>.md` e assuma o comportamento daquele cargo.
   - Leia as guidelines e skills indicadas pela role antes de iniciar a execucao.

4. **Executar:**
   - Siga os passos do `Plano de Execucao` da task.
   - Atualize a secao `Estado Atual` a cada passo significativo.
   - Pare para fazer perguntas quando surgirem duvidas.
   - Se `.ai/project.md` § Stack tiver o bullet `**Atomic Design:**` marcando o projeto como obrigatorio, leia `.ai/guidelines/core/atomic-design.md` e siga a secao "Durante a execucao" ao pe da letra.

5. **Registrar evidencias:**
   - Toda acao concluida deve ir para `Log de Evidencias` com: data/hora + comando + saida + exit code.
   - Se nao conseguir provar que algo funciona, registre em `Nao Verificado`.
   - Erros encontrados vao para `Erros e Correcoes` com: erro + causa + correcao + prova.
   - Consulte `.ai/guidelines/core/execution.md` secao "Registro de Evidencias".

6. **Concluir:**
   - Se `.ai/project.md` § Stack tiver o bullet `**Atomic Design:**` marcando o projeto como obrigatorio, siga o "Gate final" de `.ai/guidelines/core/atomic-design.md` antes de marcar a task como `done`.
   - Marque criterios de aceite como `[x]` SOMENTE com prova registrada.
   - Atualize `status: done` e `updated_at`.
   - Atualize `plan.md` com o progresso.
   - Siga o checklist de PR de `.ai/guidelines/core/execution.md`.

## Referencia

- Template de task: `.ai/templates/task.md`
- Regras de execucao: `.ai/guidelines/core/execution.md`
- Regras de planejamento: `.ai/guidelines/core/planning.md`
