# Testing Guidelines

- Toda mudanca deve ter verificacao programatica proporcional ao risco.
- Siga `.ai/guidelines/core/environment.md`; nao use Docker por padrao.
- Rode o menor conjunto de testes que prove a alteracao.
- Comandos e frameworks de teste especificos estao em `.ai/guidelines/stacks/<stack>.md`.
- Nao remova testes sem aprovacao explicita.
- Antes de abrir ferramentas de navegador/MCP para validacao visual ou E2E manual (Chrome DevTools, Playwright MCP, screenshots, cliques automatizados etc.), pergunte ao humano se ele quer que a IA teste no navegador ou se prefere testar manualmente. Aguarde a resposta antes de chamar qualquer ferramenta de navegador, mesmo para uma verificacao pequena.
