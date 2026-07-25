# Execution Guidelines

- Ao iniciar uma task, marque a task e `plan.md` como `Em execucao` quando aplicavel.
- Siga `.ai/guidelines/core/environment.md` antes de escolher comandos de execucao local.
- Antes de implementar task executavel, confirme que esta em branch propria da task e nao em branch de PR ja mergeado.
- Nao inicie task que depende de outra task cujo PR ainda nao foi mergeado na branch principal (develop/main). Se houver dependencia aberta, pare e avise o usuario.
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
- **NUNCA SUPONHA**: Diante de qualquer ambiguidade, conflito entre especificacao e codigo existente, falta de informacao ou decisao com multiplos caminhos possiveis, PARE imediatamente e pergunte ao usuario. E preferivel interromper o trabalho e aguardar do que supor errado.
- **Sem retrocompatibilidade em dev ativo**: Se o projeto estiver em desenvolvimento ativo (definido no `.ai/project.md` como sem usuarios em producao), nao gaste esforco mantendo rotas, views ou controllers legados/duplicados por compatibilidade. Delete/atualize o antigo em vez de manter ambos em paralelo, a menos que o usuario solicite explicitamente.

## Registro de Evidencias (Anti-Alucinacao)

Toda afirmacao de "fiz", "corrigi", "implementei" ou "funciona" DEVE ter prova.

Prova = comando executado + saida relevante + exit code.
Use os comandos nativos da stack do projeto (consulte `.ai/stack.md`).

Exemplos de provas validas (adapte para a stack do projeto):
- `php spark test → Tests: 42, Failures: 0 (exit 0)`
- `php spark migrate → Migrated: 2026-06-24_CreateUsers (exit 0)`
- `phpstan analyse app/ --level=5 → 0 errors (exit 0)`
- `npm test → 47 passed, 0 failed (exit 0)`
- `python -m pytest → 23 passed (exit 0)`

Regras:
- Se nao ha prova, marque o item como `⚠️ Nao verificado` na task.
- NUNCA marque `[x]` em criterio de aceite sem prova.
- Log narrativo sem evidencia nao conta como conclusao.
- Erros encontrados devem registrar: erro + causa + correcao + prova de que a correcao funcionou.

## Checklist de Encerramento (Obrigatório)

Antes de marcar qualquer task como concluída, confirme TODOS os itens:

- [ ] Testes relacionados passam (`exit 0`)
- [ ] Lint/formatacão passam (`exit 0`)
- [ ] `git diff --stat` mostra apenas arquivos esperados para esta task
- [ ] `git diff` não contém: comentários de debug, `dd()`, `var_dump()`, `console.log()`
- [ ] Nenhum arquivo de outra task foi alterado acidentalmente
- [ ] Log de Evidências registrado na task (comando + saída + exit code)
- [ ] `plan.md` atualizado com progresso da task
- [ ] `.ai/session-memory.md` atualizado

Se qualquer item falhar, NÃO marque a task como concluída. Corrija e reexecute o checklist.
