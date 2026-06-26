# Git & PR Guidelines

- **Sincronização Obrigatória**: Antes de criar qualquer ramificação (branch) para uma nova tarefa, atualize sua branch principal local (normalmente `main`) executando `git pull origin main` (ou a respectiva branch base). Nunca inicie o desenvolvimento ou crie branches a partir de uma base local desatualizada.
- **Resolução de Conflitos**: Se forem detectados conflitos no Pull Request remoto, faça a mesclagem local da branch base mais recente (`git fetch origin` seguido de `git merge origin/main`) na sua branch de feature, resolva os conflitos de forma local, execute os testes de validação e envie a atualização.
- **Escopo de Alterações no aiHub**: Quando atuarem no repositório `aiHub` (seja como submódulo ou repositório independente), os agentes de IA não devem modificar arquivos estruturais e de configuração global (como `Makefile`, `README.md`, `INSTALL.md`, `agents.json` ou arquivos na raiz) sem instrução humana direta e explícita. O escopo padrão de contribuições de agentes deve se restringir aos arquivos de diretrizes em `.ai/` e às pastas de skills em `.agents/`.
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
