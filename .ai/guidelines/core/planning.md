# Planning Guidelines

- Repositorio oficial para issues, milestones e PRs: conforme `.ai/project.md`.
- Confirme o repositorio com `git remote -v` ou `gh repo view` antes de criar, consultar, comentar ou fechar issues.
- Se o repositorio local nao bater com o de `.ai/project.md`, pare e alerte o humano.
- Cada `.planning/PLAN_VN` representa uma fase local e um milestone no GitHub.
- O nome publico do milestone deve ser humano: `VN - Nome da fase`, nao `PLAN_VN`.
- O ponto de entrada da fase deve ser `.planning/PLAN_VN/plan.md`.
- Cada task em `.planning/PLAN_VN/tasks/*.md` deve ter uma GitHub Issue correspondente.
- Cada task executavel deve resultar em um PR proprio; agrupamento de tasks exige autorizacao explicita do humano.
- Cada issue deve apontar para o arquivo local da task, e cada task deve guardar a issue.
- Agentes devem ler `plan.md` e apenas a task atual, nao todas as tasks por padrao.
- `index.md` e `roadmap.md` nao devem coexistir com `plan.md` para evitar duplicidade.
- Toda demanda que virar trabalho deve ter task local antes de ir para execucao.
- Toda task local deve ter issue GitHub antes de ir para execucao, salvo bloqueio explicito.
- Ao criar task, atualize `plan.md` com status, issue, progresso/listas e ordem de execucao.
- Toda task executavel deve declarar no cabecalho: `Modelo recomendado`, `Substitutos se Anthropic indisponivel`, `Cargo recomendado` e `Motivo`.
- O bloco de recomendacao deve ficar antes de `Prioridade` ou do primeiro contexto da task, para que o roteamento de execucao seja visivel sem ler a task inteira.
- Use modelo forte para tasks que cruzam backend, frontend, regras financeiras, schema, integracoes ou muitos testes; use modelo economico para alteracoes pequenas, localizadas e reversiveis.
- Ao criar nova task, use o template de `.ai/templates/task.md` como base.
- Toda task deve ter `created_at` preenchido na criacao e `updated_at` atualizado a cada mudanca de status ou progresso significativo.
- A secao `Estado Atual` da task deve refletir o ultimo ponto de parada para facilitar handoff entre sessoes.

## Especificidade Minima de Planejamento

Para evitar retrabalho e ambiguidade, todo plano ou especificacao de task deve respeitar os seguintes criterios minimos:

1. **Menus e Navegacao**: Especifique exatamente onde o novo recurso/tela sera acessado no painel, incluindo links de menu, botoes de atalho, Breadcrumbs e regras de visibilidade (roles/permissoes).
2. **Origem de Dados**: Indique claramente de qual tabela, endpoint API ou Service vem cada dado que sera exibido na tela, alem de listar dependencias de relacionamentos de banco de dados.
3. **Regras de Validacao**: Liste explicitamente os campos obrigatorios, tipos de dados, limites de caracteres e comportamentos esperados do backend em caso de falha de validacao (ex: redirects, flash messages).
4. **Cenarios de Teste**: Descreva pelo menos 2 cenarios de teste basicos na task: um de sucesso (happy path) e um de erro/excecao (ex: tenant diferente, dados duplicados, input vazio).
5. **Analise de Requisitos**: Antes de propor o plano de uma fase, revise as diretrizes de regras de negocio do projeto (`.ai/guidelines/domain/business-rules/`) e identifique potenciais conflitos ou restricoes tecnicas da stack.


