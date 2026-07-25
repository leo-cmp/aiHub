# Guia de Instalação: aiHub

Este guia descreve como integrar as configurações e diretrizes do **aiHub** em qualquer projeto, garantindo que os agentes de IA leiam suas regras e permitindo que você contribua de volta com melhorias globais.

---

## Método Rápido (Recomendado: via install.sh)

### 1. Adicione o submódulo no seu projeto:
Na raiz do seu projeto (novo ou existente), execute:
```bash
git submodule add https://github.com/leo-cmp/aiHub.git .aihub
```

### 2. Execute a instalação:
```bash
cd .aihub
./scripts/install.sh
```

Pronto! O script criará automaticamente a estrutura física local `.ai/` no seu projeto pai, configurará todos os links simbólicos necessários apontando para as regras globais e copiará as configurações e pasta `.agents/` iniciais se elas não existirem. Além disso, adicionará `.aihub/` no `.gitignore` local de forma automática.

### Forçar reinstalação:
Se você deseja sobrescrever `.agents/` e `.mcp.json` com as versões mais recentes do aiHub:
```bash
./scripts/install-force.sh
```

---

## Método Manual (Sem install.sh ou no Windows)

### Cenário A: Em um Projeto Novo (Do Zero)

1. **Inicialize a pasta do projeto e o Git:**
   ```bash
   mkdir <nome-do-seu-projeto>
   cd <nome-do-seu-projeto>
   git init
   ```
2. **Crie ou instale os arquivos do seu aplicativo na raiz.**
3. **Adicione o submódulo na pasta oculta `.aihub`:**
   ```bash
   git submodule add https://github.com/leo-cmp/aiHub.git .aihub
   ```
4. **Crie as pastas físicas locais (caso não existam):**
   ```bash
   mkdir -p .ai/guidelines/domain/business-rules
   mkdir -p .agents
   mkdir -p .claude
   ```
5. **Crie os Links Simbólicos e Copie os Arquivos Locais:**
   ```bash
   ln -s .aihub/AGENTS.md AGENTS.md
   ln -s .aihub/AGENTS.md CLAUDE.md

   ln -s ../.aihub/.ai/roles .ai/roles
   ln -s ../../.aihub/.ai/guidelines/core .ai/guidelines/core
   ln -s ../../.aihub/.ai/guidelines/stacks .ai/guidelines/stacks
   ln -s ../.agents/skills .claude/skills
   
   cp -r .aihub/.agents/* .agents/
   cp .aihub/.mcp.json .mcp.json
   ```
6. **Escreva as configurações locais em `.ai/project.md` e `.ai/stack.md`.**

---

### Cenário B: Em um Repositório Git Existente

1. **Abra o terminal na raiz do seu projeto existente.**
2. **Adicione o submódulo:**
   ```bash
   git submodule add https://github.com/leo-cmp/aiHub.git .aihub
   ```
3. **Execute:**
   ```bash
   cd .aihub && ./scripts/install.sh
   ```
4. **Escreva as configurações locais em `.ai/project.md` e `.ai/stack.md`.**

---

## Como Sincronizar e Contribuir com o aiHub

### 1. Atualizar o aiHub
Para atualizar o aiHub para a versão mais recente, use o atalho `/aihub:atualizar-aihub` em uma sessão com um agente ou execute manualmente:
```bash
cd .aihub
git fetch origin --tags
git checkout $(git tag --sort=-version:refname | head -1)
./scripts/install.sh
```

### 2. Reinstalar após mudanças locais
Se você fez alterações locais em `.agents/skills` ou no `.mcp.json` e deseja resetá-los para a versão mais recente do `aiHub`:
```bash
cd .aihub
./scripts/install-force.sh
```

### 3. Contribuir com melhorias globais (PRs)
Para alterar arquivos globais e abrir um Pull Request para o `aiHub`:
```bash
cd .aihub
git checkout -b feat/sua-melhoria
# faça as alterações necessárias
git add .ai/guidelines/stacks/sua-stack.md
git commit -m "docs: atualiza boas práticas"
git push origin HEAD
gh pr create --base main --fill
```

---

## Comandos Disponíveis

| Comando | Descrição |
|---------|-----------|
| `./scripts/install.sh` | Instala aiHub no projeto alvo (cria diretórios, symlinks, arquivos iniciais) |
| `./scripts/install-force.sh` | Força reinstalação (sobrescreve `.agents/` e `.mcp.json`) |
| `./scripts/validate.sh` | Valida consistência interna do sistema de regras |
| `./scripts/release.sh` | Publica nova versão (bump semver + tag) |
| `./scripts/check-version.sh` | Compara versão local com última tag remota |
