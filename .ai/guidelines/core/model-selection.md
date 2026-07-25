# Model Selection Guidelines

- Codex CLI com GPT-5.5, Gemini e Copilot podem atuar como entrada principal e `model-router`.
- Codex, Gemini e Copilot possuem paridade de cargos: qualquer recomendacao possivel para um tambem e possivel para o outro.
- Use modelo forte para arquitetura, regra financeira, schema, debugging dificil ou multiplos arquivos.
- Use modelo economico para alteracoes pequenas, localizadas e reversiveis.
- Se o modelo atual estiver superdimensionado, recomende agente/modelo mais barato antes da execucao.
- Se o modelo atual for fraco para a demanda, recomende agente/modelo mais forte.
- Sempre gere o bloco `Envie para o [AGENTE]`.
- A mensagem pronta nao deve incluir `Siga AGENTS.md`, pois os bootloaders ja fazem isso.
- Para tasks de execucao, a mensagem pronta deve pedir para seguir `.ai/guidelines/core/execution.md`.
- Se nao existir task para a demanda, Codex/GPT-5.5, Gemini ou Copilot deve assumir `technical-lead` e criar task/issue antes de encaminhar.
- Ao criar ou atualizar task executavel, registre no cabecalho `Modelo recomendado`, `Substitutos se Anthropic indisponivel`, `Cargo recomendado` e `Motivo`.
