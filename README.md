# aiHub

O **aiHub** é uma central portátil de configuração e diretrizes de desenvolvimento otimizada para agentes de inteligência artificial (como Gemini, Claude, Codex e Copilot). 

Ele foi desenhado para ser acoplado em qualquer repositório de software através de submódulos Git, garantindo que as diretrizes globais de código permaneçam padronizadas, sem poluir os repositórios locais do seu projeto com regras genéricas.

---

## 🛠️ Comandos do Makefile

Para facilitar o gerenciamento, o projeto conta com tarefas no `Makefile`. Sempre que for rodar os comandos abaixo, certifique-se de estar dentro da pasta do submódulo:

```bash
cd aiHub
```

### 1. Ajuda e Visualização de Comandos
Mostra a lista de comandos disponíveis e sua sintaxe.
```bash
make help
```

### 2. Instalação e Vinculação (`install`)
Cria a pasta `.ai/` física no projeto principal (pai) para regras de negócio específicas daquele projeto e configura todos os links simbólicos necessários.
```bash
make install
```

### 3. Sincronizar com a Versão Global (`update`)
Muda para a branch `main` e puxa as diretrizes atualizadas do repositório remoto do `aiHub`.
```bash
make update
```

### 4. Contribuir com Novas Diretrizes (`branch` e `push-pr`)
Se você quer adicionar uma nova stack ou melhorar diretrizes existentes, crie uma branch e envie suas alterações de volta:

1. **Crie a branch** (defina o nome com `name=`):
   ```bash
   make branch name=feature/minha-melhoria
   ```
2. Faça as alterações desejadas nos arquivos do `aiHub`.
3. **Envie as alterações para o repositório remoto:**
   ```bash
   make push-pr
   ```
4. O terminal exibirá o link para você abrir o Pull Request!

---

## 📖 Instruções Completas de Integração

Para ver o passo a passo completo de como configurar e integrar o `aiHub` do zero em novos projetos ou em projetos que já existem no Git, leia o nosso guia detalhado:

* Ver: [INSTALL.md](file:///home/leo/Dev/ia-worker/INSTALL.md)
