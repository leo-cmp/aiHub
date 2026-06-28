.PHONY: install install-force update update-force git-update git-branch git-push git-pr help

help:
	@echo "=========================================================================="
	@echo "                      aiHub - Comandos do Makefile                        "
	@echo "=========================================================================="
	@echo "Comandos disponíveis:"
	@echo "  make install             - Cria pastas locais e configura links simbólicos no projeto pai (instalação)."
	@echo "  make install-force       - Força a cópia de .agents e .mcp.json (sobrescreve arquivos locais)."
	@echo "  make update              - Recria/atualiza links simbólicos no projeto pai (seguro para rodar)."
	@echo "  make update-force        - Atalho para o install-force (atualização forçada local)."
	@echo "  make git-update          - Puxa as atualizações do Git remoto e atualiza os links simbólicos."
	@echo "  make git-branch name=    - Cria uma nova branch local no aiHub para melhorias/PRs."
	@echo "                             Exemplo: make git-branch name=minha-melhoria"
	@echo "  make git-push            - Envia a branch atual e suas alterações para o repositório remoto."
	@echo "  make git-pr              - Abre o Pull Request da branch atual contra main (requer GitHub CLI 'gh')."
	@echo "=========================================================================="

install:
	@echo "Criando diretórios locais no projeto principal..."
	mkdir -p ../.ai/guidelines/domain/business-rules
	@if [ ! -d ../.agents ]; then \
		echo "Copiando pasta .agents inicial para o projeto principal..."; \
		cp -r .agents ../.agents; \
	fi
	
	@echo "Criando links simbólicos dos agentes na raiz do projeto..."
	ln -sfn .aihub/AGENTS.md ../AGENTS.md
	ln -sfn .aihub/ANTIGRAVITY.md ../ANTIGRAVITY.md
	ln -sfn .aihub/CLAUDE.md ../CLAUDE.md
	ln -sfn .aihub/CODEX.md ../CODEX.md
	ln -sfn .aihub/COPILOT.md ../COPILOT.md
	
	@echo "Criando links simbólicos das diretrizes globais na pasta .ai..."
	ln -sfn ../.aihub/.ai/roles ../.ai/roles
	ln -sfn ../../.aihub/.ai/guidelines/core ../.ai/guidelines/core
	ln -sfn ../../.aihub/.ai/guidelines/stacks ../.ai/guidelines/stacks
	
	@echo "Criando diretório .claude e linkando skills..."
	mkdir -p ../.claude
	ln -sfn ../.agents/skills ../.claude/skills
	
	@echo "Verificando arquivos locais de configuração..."
	@if [ ! -f ../.ai/project.md ]; then \
		echo "Criando arquivo inicial .ai/project.md..."; \
		printf "# Novo Projeto\n\n## Ambiente e Estrutura\n- **Localização:** Os arquivos rodam diretamente na raiz.\n- **Idioma da UI:** pt-BR\n\n## Stack\n- Backend: \n- Database: \n" > ../.ai/project.md; \
	fi
	@if [ ! -f ../.ai/stack.md ]; then \
		echo "Criando arquivo inicial .ai/stack.md..."; \
		printf "# Stacks do Projeto\n\nConsulte as diretrizes específicas em:\n- [Laravel](file:///.ai/guidelines/stacks/laravel.md)\n" > ../.ai/stack.md; \
	fi
	@if [ ! -f ../.mcp.json ]; then \
		echo "Copiando arquivo .mcp.json inicial..."; \
		cp .mcp.json ../.mcp.json; \
	fi
	@if [ -f ../.gitignore ]; then \
		if ! grep -q "^\.aihub" ../.gitignore; then \
			echo "Adicionando .aihub/ ao .gitignore do projeto principal..."; \
			printf "\n# aiHub\n.aihub/\n" >> ../.gitignore; \
		fi \
	fi
	@echo "Instalação do aiHub concluída com sucesso!"

install-force:
	@echo "Forçando a cópia de .agents e .mcp.json (sobrescrevendo arquivos locais)..."
	rm -rf ../.agents ../.mcp.json
	@$(MAKE) install

update:
	@echo "Atualizando links simbólicos do aiHub no projeto pai..."
	@$(MAKE) install

update-force:
	@echo "Forçando atualização local completa dos arquivos..."
	@$(MAKE) install-force

git-update:
	@echo "Buscando atualizações remotas do aiHub..."
	git fetch origin
	git checkout main
	git reset --hard origin/main
	@echo "Aplicando as novas diretrizes e links simbólicos..."
	@$(MAKE) install
	@echo "aiHub atualizado com sucesso!"


git-branch:
	@if [ -z "$(name)" ]; then \
		echo "Erro: Você precisa definir o nome da branch usando name=<nome-da-branch>"; \
		echo "Exemplo: make git-branch name=feature/minha-melhoria"; \
		exit 1; \
	fi
	@echo "Criando nova branch '$(name)' no aiHub..."
	git checkout -b $(name)

git-push:
	@echo "Enviando alterações locais para o repositório remoto..."
	git push origin HEAD
	@echo "Alterações enviadas com sucesso! Abra o link exibido acima para criar o Pull Request."

git-pr:
	@echo "Criando Pull Request no GitHub para a branch atual..."
	gh pr create --base main --fill
	@echo "Pull Request criado com sucesso!"

