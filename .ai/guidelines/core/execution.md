# Execution Guidelines

- Ao iniciar uma task, marque a task e `plan.md` como `Em execucao` quando aplicavel.
- Siga `.ai/guidelines/core/environment.md` antes de escolher comandos de execucao local.
- Antes de implementar task executavel, confirme que esta em branch propria da task e nao em branch de PR ja mergeado.
- Nao execute pedido generico como "conforme planejado"; exija caminho de task em `.planning/PLAN_VN/tasks/*.md`.
- Se criar ou alterar migrations/seeders, rode-os conforme `.ai/guidelines/stacks/<stack>.md` antes dos testes de aceite.
- Antes de concluir, rode formatacao e o criterio de aceite da task.
- Antes de encerrar task executavel, confirme o checklist de PR:
  - branch propria da task existe e nao e branch de PR ja mergeado;
  - branch foi enviada para `origin`;
  - PR foi criado no repositorio oficial (conforme `.ai/project.md`);
  - `gh pr view` confirma numero, base, head e estado do PR;
  - relatorio final traz URL do PR.
- Marque entregaveis concluidos com `[x]` apenas depois de implementar e verificar.
- Ao concluir, atualize status da task, progresso/listas em `plan.md` e issue GitHub vinculada.
- Ao concluir task executavel, encaminhe para PR proprio com `Task X.Y` no titulo.
- Se houver falha ou bloqueio, registre na task e comente na issue em vez de marcar concluida.
- O relatorio final deve citar comandos rodados, incluindo migrate/seed quando aplicavel, resultado, arquivos de plano atualizados e issue.
