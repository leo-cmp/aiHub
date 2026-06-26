# Guia de Instalação: aiHub

Este guia descreve como integrar as configurações e diretrizes do **aiHub** em qualquer projeto, garantindo que os agentes de IA leiam suas regras e permitindo que você contribua de volta com melhorias globais.

---

## ⚡ Método Rápido (Recomendado: via Makefile)

Se o seu sistema possui o comando `make` instalado (Linux/macOS), você pode automatizar toda a criação de diretórios, arquivos locais iniciais e links simbólicos em segundos.

### 1. Adicione o submódulo no seu projeto:
Na raiz do seu projeto (novo ou existente), execute:
```bash
git submodule add https://github.com/leo-cmp/aiHub.git .aihub
```

### 2. Execute a instalação:
```bash
cd .aihub
make install
```

Pronto! O `Makefile` criará automaticamente a estrutura física local `.ai/` no seu projeto pai, configurará todos os links simbólicos necessários apontando para as regras globais e copiará as configurações e pasta `.agents/` iniciais se elas não existirem. Além disso, adicionará `.aihub/` no `.gitignore` local de forma automática.

---

## 🛠️ Método Manual (Sem Makefile ou no Windows)

Caso prefira fazer a instalação manualmente ou esteja no Windows (sem `make`), siga os passos abaixo de acordo com o cenário:

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
   # Links de agentes na raiz apontando para .aihub
   ln -s .aihub/AGENTS.md AGENTS.md
   ln -s .aihub/ANTIGRAVITY.md ANTIGRAVITY.md
   ln -s .aihub/CLAUDE.md CLAUDE.md
   ln -s .aihub/CODEX.md CODEX.md
   ln -s .aihub/COPILOT.md COPILOT.md
   ln -s .aihub/agents.json agents.json

   # Links das subpastas internas em .ai e .claude
   ln -s ../.aihub/.ai/roles .ai/roles
   ln -s ../../.aihub/.ai/guidelines/core .ai/guidelines/core
   ln -s ../../.aihub/.ai/guidelines/stacks .ai/guidelines/stacks
   ln -s ../.agents/skills .claude/skills
   
   # Cópia física de arquivos de configuração e skills iniciais (se não existirem)
   cp -r .aihub/.agents/* .agents/
   cp .aihub/.mcp.json .mcp.json
   ```
   > 💡 **Nota para Windows:** Se estiver usando Windows (fora do Git Bash/WSL), crie os links usando o Prompt de Comando (CMD) como Administrador:
   > * Para diretórios: `mklink /D <nome-do-link> <alvo>`
   > * Para arquivos: `mklink <nome-do-link> <alvo>`
6. **Escreva as configurações locais em `.ai/project.md` e `.ai/stack.md`.**


---

### Cenário B: Em um Repositório Git Existente

1. **Abra o terminal na raiz do seu projeto existente.**
2. **Adicione o submódulo:**
   ```bash
   git submodule add https://github.com/leo-cmp/aiHub.git .aihub
   ```
3. **Crie as pastas físicas para as configurações e agentes locais:**
   ```bash
   mkdir -p .ai/guidelines/domain/business-rules
   mkdir -p .agents
   ```
4. **Crie os Links Simbólicos e Cópias:**
   *(Rode os comandos de `ln -s`, `cp` ou `mklink` listados no Cenário A).*
5. **Escreva as configurações locais em `.ai/project.md` e `.ai/stack.md` (ajustando a localização da sua stack, caso ela esteja em subpastas como `/app`).**

---

## 🔄 Como Sincronizar e Contribuir com o aiHub

### 1. Puxar atualizações globais (Upgrade)
Se você estiver usando o instalador automatizado via `Makefile`, basta rodar o comando abaixo para puxar as últimas atualizações do `aiHub` e aplicar/atualizar todos os links simbólicos de uma só vez:
```bash
cd .aihub
make git-update
```

Se preferir fazer a sincronização e atualização manualmente via Git:
```bash
git submodule update --remote --merge
# E caso haja novos arquivos de agentes ou diretrizes, recrie os symlinks necessários
```

### 2. Forçar atualização dos arquivos locais copiados (`.agents` e `.mcp.json`)
Se você fez alterações locais em `.agents/skills` ou no `.mcp.json` e deseja resetá-los para a versão mais recente do `aiHub` (sobrescrevendo os arquivos locais), execute:
```bash
cd .aihub
make update-force
```

### 3. Contribuir com melhorias globais (PRs)
Para alterar arquivos globais e abrir um Pull Request para o `aiHub`:
```bash
cd .aihub
make git-branch name=feature/sua-melhoria
# faça as alterações necessárias
git add .ai/guidelines/stacks/sua-stack.md
git commit -m "docs: atualiza boas práticas"
make git-push
make git-pr
```
Depois disso, seu Pull Request será criado automaticamente no GitHub!
