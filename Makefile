.PHONY: install update branch push-pr pr help

help:
	@echo "=========================================================================="
	@echo "                      aiHub - Comandos do Makefile                        "
	@echo "=========================================================================="
	@echo "Comandos disponíveis:"
	@echo "  make install             - Cria pastas locais e configura links simbólicos no projeto pai."
	@echo "  make update              - Puxa as últimas atualizações globais do repositório aiHub."
	@echo "  make branch name=        - Cria uma nova branch local no aiHub para melhorias/PRs."
	@echo "                             Exemplo: make branch name=minha-melhoria"
	@echo "  make push-pr             - Envia a branch atual e suas alterações para o repositório remoto."
	@echo "  make pr                  - Abre o Pull Request da branch atual contra main (requer GitHub CLI 'gh')."
	@echo "=========================================================================="

install:
	@echo "Criando diretórios locais no projeto principal..."
	mkdir -p ../.ai/guidelines/domain/business-rules
	
	@echo "Criando links simbólicos dos agentes na raiz do projeto..."
	ln -sf aiHub/AGENTS.md ../AGENTS.md
	ln -sf aiHub/ANTIGRAVITY.md ../ANTIGRAVITY.md
	ln -sf aiHub/CLAUDE.md ../CLAUDE.md
	ln -sf aiHub/CODEX.md ../CODEX.md
	ln -sf aiHub/COPILOT.md ../COPILOT.md
	ln -sf aiHub/agents.json ../agents.json
	
	@echo "Criando links simbólicos das diretrizes globais na pasta .ai..."
	ln -sf ../aiHub/.ai/roles ../.ai/roles
	ln -sf ../../aiHub/.ai/guidelines/core ../.ai/guidelines/core
	ln -sf ../../aiHub/.ai/guidelines/stacks ../.ai/guidelines/stacks
	
	@echo "Verificando arquivos locais de configuração..."
	@if [ ! -f ../.ai/project.md ]; then \
		echo "Criando arquivo inicial .ai/project.md..."; \
		printf "# Novo Projeto\n\n## Ambiente e Estrutura\n- **Localização:** Os arquivos rodam diretamente na raiz.\n- **Idioma da UI:** pt-BR\n\n## Stack\n- Backend: \n- Database: \n" > ../.ai/project.md; \
	fi
	@if [ ! -f ../.ai/stack.md ]; then \
		echo "Criando arquivo inicial .ai/stack.md..."; \
		printf "# Stacks do Projeto\n\nConsulte as diretrizes específicas em:\n- [Laravel](file:///.ai/guidelines/stacks/laravel.md)\n" > ../.ai/stack.md; \
	fi
	@echo "Instalação do aiHub concluída com sucesso!"

update:
	@echo "Atualizando o aiHub para a versão mais recente..."
	git checkout main
	git pull origin main
	@echo "aiHub atualizado com sucesso!"

branch:
	@if [ -z "$(name)" ]; then \
		echo "Erro: Você precisa definir o nome da branch usando name=<nome-da-branch>"; \
		echo "Exemplo: make branch name=feature/minha-melhoria"; \
		exit 1; \
	fi
	@echo "Criando nova branch '$(name)' no aiHub..."
	git checkout -b $(name)

push-pr:
	@echo "Enviando alterações locais para o repositório remoto..."
	git push origin HEAD
	@echo "Alterações enviadas com sucesso! Abra o link exibido acima para criar o Pull Request."

pr:
	@echo "Criando Pull Request no GitHub para a branch atual..."
	gh pr create --base main --fill
	@echo "Pull Request criado com sucesso!"
