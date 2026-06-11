# Git & PR Guidelines

- Repositorio oficial: conforme `.ai/project.md`.
- Antes de operar issues, milestones, PRs ou releases, confirme o repositorio com `git remote -v` ou `gh repo view`.
- Nunca inferir owner pela conta ativa do GitHub.
- Se aparecer um repositorio divergente do configurado em `.ai/project.md`, pare e corrija.
- Commits devem ser pequenos, semanticos e ligados a uma task quando houver.
- Nao misture tasks independentes no mesmo commit.
- Cada task executavel deve ter branch e PR proprios, salvo autorizacao explicita do humano.
- Titulo de PR de task deve conter `Task X.Y` e uma descricao curta do entregavel.
- Nao reutilize branch de PR ja mergeado para nova task; crie branch nova.
- Antes de reportar task executavel como encerrada, valide com `gh pr view` que o PR existe no repo oficial, com base/head corretos, e inclua a URL do PR no relatorio final.
- Antes de PR, relate testes executados e riscos restantes.
- Review deve listar problemas primeiro, com arquivo e linha quando possivel.
- Nao reverta alteracoes de terceiros sem aprovacao explicita.
