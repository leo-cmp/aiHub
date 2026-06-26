---
name: iniciar-projeto
description: Inicializa um projeto configurando as diretrizes locais em .ai/, incluindo o project.md, stack.md e estruturando as regras de negócio.
disable-model-invocation: false
---

# Iniciar Projeto

Esta skill deve ser ativada quando o usuário solicitar a inicialização ou configuração de um novo projeto, ou via comando `/aihub:iniciar`.

## Fluxo

1. **Investigar o ambiente:**
   - Liste o diretório raiz do projeto para identificar a stack, frameworks, gerenciadores de dependência e banco de dados.
   - Execute comandos de diagnóstico se necessário (ex: `composer show`, `npm list`) para entender as versões exatas instaladas.

2. **Gerar ou Atualizar Configurações Locais:**
   - Garanta que a pasta `.ai/` exista na raiz do projeto principal.
   - Escreva ou atualize `.ai/project.md` com a descrição do projeto, idioma da UI (pt-BR por padrão), ambiente, repositório oficial e link para regras de negócio.
   - Escreva ou atualize `.ai/stack.md` listando as linguagens, frameworks e indicando as diretrizes globais daquela stack (ex: `laravel.md`).

3. **Mapear Regras de Negócio Iniciais:**
   - Crie o diretório `.ai/guidelines/domain/business-rules/`.
   - Crie um arquivo inicial em `.ai/guidelines/domain/business-rules/index.md` listando as regras comerciais conhecidas ou pendentes de alinhamento com o usuário.

4. **Verificar Instalação do aiHub:**
   - Execute `make update` (ou `make install`) dentro da pasta `aiHub` para garantir que todos os links simbólicos dos agentes e diretrizes globais estejam criados devidamente na raiz do projeto pai.
