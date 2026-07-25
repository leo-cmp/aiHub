# Database Guidelines

- Inspecione o schema atual antes de mudancas dependentes do banco (use o MCP da stack quando disponivel).
- Valores monetarios precisam de precisao decimal adequada (nunca `float`); o tipo exato esta em `.ai/guidelines/stacks/<stack>.md`.
- Crie indices para FKs e campos de filtro frequente.
- Migrations devem ter rollback coerente.
- Proteja integridade, imutabilidade e isolamento entre perfis conforme `.ai/guidelines/domain/business-rules/index.md`.
