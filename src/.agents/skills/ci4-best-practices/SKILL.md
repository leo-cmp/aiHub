---
name: ci4-best-practices
description: >
  Boas praticas para CodeIgniter 4. Use ao escrever, revisar ou refatorar codigo CI4.
  Cobre controllers, models, entities, validation, routes, migrations, services,
  filters, security, testing, database e views.
---

# CodeIgniter 4 Best Practices

## Quando usar
- Criando ou modificando controllers, models, entities, migrations, seeders, filters, services
- Escrevendo queries, validacoes, rotas ou testes
- Revisando codigo CI4
- Duvidas sobre padroes e convencoes do framework

## Regras por Tema

| Tema | Arquivo | Topicos |
|------|---------|---------|
| Controllers | `rules/controllers.md` | Convencoes, injecao de dependencia, respostas, filters |
| Models | `rules/models.md` | Finders, query builder, entidades, timestamps |
| Entities | `rules/entities.md` | Getters/setters, casting, hydratation |
| Validation | `rules/validation.md` | Rules, custom rules, mensagens, grupos |
| Routes | `rules/routes.md` | Route groups, filters, placeholders, RESTful |
| Migrations | `rules/migrations.md` | Forge, indices, FKs, rollback |
| Services | `rules/services.md` | Service layer, injecao, shared instances |
| Filters | `rules/filters.md` | Auth, CSRF, rate limit, CORS |
| Security | `rules/security.md` | XSS, CSRF, SQL injection, validacao de input |
| Testing | `rules/testing.md` | HTTP tests, database tests, mocks |
| Database | `rules/database.md` | Queries, joins, indices, performance, migrations |
| Views | `rules/views.md` | View cells (atomic design, cache, form cells), HTMX + cells (lazy load, inline edit, infinite scroll, swaps, triggers, CSRF), layouts, partials, dados |
