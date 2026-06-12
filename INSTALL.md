# Guia de Instalação: aiHub

Este guia descreve como integrar as configurações e diretrizes do **aiHub** em qualquer projeto, garantindo que os agentes de IA leiam suas regras e permitindo que você contribua de volta com melhorias globais.

---

## ⚡ Método Rápido (Recomendado: via Makefile)

Se o seu sistema possui o comando `make` instalado (Linux/macOS), você pode automatizar toda a criação de diretórios, arquivos locais iniciais e links simbólicos em segundos.

### 1. Adicione o submódulo no seu projeto:
Na raiz do seu projeto (novo ou existente), execute:
```bash
git submodule add <URL_DO_REPOSITORIO_AIHUB> aiHub
```

### 2. Execute a instalação:
```bash
cd aiHub
make install
```

Pronto! O `Makefile` criará automaticamente a estrutura física local `.ai/` no seu projeto pai, configurará todos os links simbólicos necessários apontando para as regras globais e gerará os arquivos `.ai/project.md` e `.ai/stack.md` iniciais se eles não existirem.

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
3. **Adicione o submódulo:**
   ```bash
   git submodule add <URL_DO_REPOSITORIO_AIHUB> aiHub
   ```
4. **Crie a pasta física para configurações locais:**
   ```bash
   mkdir -p .ai/guidelines/domain/business-rules
   ```
5. **Crie os Links Simbólicos (Symlinks):**
   ```bash
   # Links de agentes na raiz
   ln -s aiHub/AGENTS.md AGENTS.md
   ln -s aiHub/ANTIGRAVITY.md ANTIGRAVITY.md
   ln -s aiHub/CLAUDE.md CLAUDE.md
   ln -s aiHub/CODEX.md CODEX.md
   ln -s aiHub/COPILOT.md COPILOT.md

   # Links das subpastas internas em .ai
   ln -s ../aiHub/.ai/roles .ai/roles
   ln -s ../../aiHub/.ai/guidelines/core .ai/guidelines/core
   ln -s ../../aiHub/.ai/guidelines/stacks .ai/guidelines/stacks
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
   git submodule add <URL_DO_REPOSITORIO_AIHUB> aiHub
   ```
3. **Crie a pasta física para as configurações específicas do projeto:**
   ```bash
   mkdir -p .ai/guidelines/domain/business-rules
   ```
4. **Crie os Links Simbólicos:**
   *(Rode os comandos de `ln -s` ou `mklink` listados no Cenário A).*
5. **Escreva as configurações locais em `.ai/project.md` e `.ai/stack.md` (ajustando a localização da sua stack, caso ela esteja em subpastas como `/app`).**

---

## 🔄 Como Sincronizar e Contribuir com o aiHub

### 1. Puxar atualizações globais (Pull)
Para atualizar as diretrizes globais do `aiHub` no seu projeto:
```bash
git submodule update --remote --merge
```

### 2. Contribuir com melhorias globais (PRs)
Para alterar arquivos globais e abrir um Pull Request para o `aiHub`:
```bash
cd aiHub
make branch name=feature/sua-melhoria
# faça as alterações necessárias
git add .ai/guidelines/stacks/sua-stack.md
git commit -m "docs: atualiza boas práticas"
make push-pr
```
Depois, basta ir no GitHub/GitLab do `aiHub` e abrir o Pull Request!
