# Git & PR Guidelines

- **Verificação de Branch Ativa**: Antes de comecar a editar qualquer codigo, o agente deve rodar `git branch --show-current` (ou `git status`) e identificar em qual branch esta. Se a branch atual nao foi criada para a tarefa em questao (ex.: e a `main`, uma branch de uma tarefa anterior, ou uma branch ja com PR aberto/mesclado), o agente **deve parar e perguntar ao humano** se deve continuar nessa mesma branch ou criar uma nova a partir da `main` atualizada — nunca assumir silenciosamente que a branch ativa esta correta para o trabalho atual.
- **Sincronização Obrigatória**: Antes de criar qualquer ramificação (branch) para uma nova tarefa, o agente **nunca** deve assumir que a base local está atualizada — é obrigatorio verificar primeiro. Rode `git fetch origin` e em seguida `git status -uno` (ou `git log origin/main..main`) comparando a branch base local com `origin/main` (ou a branch base correspondente). Se houver qualquer divergencia, execute `git pull origin main` antes de criar a branch. Nunca inicie o desenvolvimento ou crie branches a partir de uma base local desatualizada ou nao verificada.

## Convencao de Commits, Branches e PRs

Este projeto segue [Conventional Commits](https://www.conventionalcommits.org/), com descricao em PT-BR.

- **Tipos permitidos**: `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `style`, `perf`, `build`, `ci`.
  - Use `refactor` (nao `refact`) e `feat` (nao `feature`) para manter consistencia com commits anteriores.
- **Mensagem de commit**: `tipo: descricao curta no infinitivo/imperativo` (ex.: `fix: corrige race condition no idempotente do install`). Nunca adicione trailers como `Co-authored-by` ou assinaturas de agente nos commits ou PRs.
- **Nome de branch**: `tipo/descricao-curta-em-kebab-case`, usando o mesmo `tipo` do commit predominante daquela branch (ex.: `fix/race-condition-install`).
- **Titulo de PR**: segue a mesma convencao do commit (`tipo: descricao`). Para PRs ligados a uma task executavel, mantenha tambem a regra de incluir `Task X.Y` no titulo (ver abaixo).
- **Resolução de Conflitos**: Se forem detectados conflitos no Pull Request remoto, faça a mesclagem local da branch base mais recente (`git fetch origin` seguido de `git merge origin/main`) na sua branch de feature, resolva os conflitos de forma local, execute os testes de validação e envie a atualização.
- **Escopo de Alterações no aiHub**: Quando atuarem no repositório `aiHub` (seja como submódulo ou repositório independente), os agentes de IA não devem modificar arquivos estruturais e de configuração global (como `Makefile`, `README.md`, `INSTALL.md` ou arquivos na raiz) sem instrução humana direta e explícita. O escopo padrão de contribuições de agentes deve se restringir aos arquivos de diretrizes em `.ai/` e às pastas de skills em `.agents/`.
- **Subagentes e Escopo de Commit**: Ao instruir subagentes que podem commitar, informe os paths exatos permitidos no `git add`. Nunca delegue `git add .`, `git add -A` ou "commit your work" sem lista fechada de arquivos. Depois que o subagente reportar conclusao, confira o commit/diff resultante (`git show --stat --name-only HEAD` ou equivalente) e trate qualquer arquivo fora da lista esperada como possivel vazamento de escopo ou credencial antes de seguir.
- Repositorio oficial: conforme `.ai/project.md`.
- Antes de operar issues, milestones, PRs ou releases, confirme o repositorio com `git remote -v` ou `gh repo view`.
- Nunca inferir owner pela conta ativa do GitHub.
- Se aparecer um repositorio divergente do configurado em `.ai/project.md`, pare e corrija.
- Commits devem ser pequenos, semanticos e ligados a uma task quando houver.
- Nao misture tasks independentes no mesmo commit.
- Cada task executavel deve ter branch e PR proprios, salvo autorizacao explicita do humano.
- Titulo de PR de task deve conter `Task X.Y` e uma descricao curta do entregavel.
- **Ciclo de Vida do PR**: Nunca envie novos commits para uma branch cujo Pull Request já tenha sido mesclado ou fechado. Se o PR original foi concluído e você precisa fazer novos ajustes ou correções, atualize sua `main` local (`git pull origin main`), crie uma nova branch a partir dela e abra um novo Pull Request.
- Antes de reportar task executavel como encerrada, valide com `gh pr view` que o PR existe no repo oficial, com base/head corretos, e inclua a URL do PR no relatorio final.
- Antes de PR, relate testes executados e riscos restantes.
- Review deve listar problemas primeiro, com arquivo e linha quando possivel.
- Nao reverta alteracoes de terceiros sem aprovacao explicita.
