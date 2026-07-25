---
name: htmx-best-practices
description: >
  Boas praticas para HTMX em qualquer stack backend (CodeIgniter 4, Laravel, etc).
  Use ao escrever templates com atributos HTMX, criar componentes server-side interativos
  com View Cells/Blade Components, ou configurar CSRF, triggers, swaps e animacoes.
  Cobre core HTMX, integracao com View Cells, CSRF/seguranca, forms/validacao, e CSS transitions.
---

# HTMX Best Practices

HTMX permite interfaces interativas renderizando HTML no servidor — sem escrever JavaScript para cada interacao. Combinado com componentes server-side (View Cells no CI4, Blade Components no Laravel), substitui grande parte do que se faria com Vue/React/Alpine para CRUDs e dashboards.

## Quando usar
- Adicionando atributos `hx-*` em templates
- Criando rotas que retornam fragmentos HTML para swap
- Integrando HTMX com View Cells ou Blade Components
- Configurando CSRF para requests HTMX
- Implementando lazy load, infinite scroll, inline edit, search-as-you-type
- Adicionando animacoes CSS com estados HTMX
- Configurando polling, SSE ou WebSockets via HTMX

## Quick Reference

| Tema | Arquivo | Topicos |
|------|---------|---------|
| Core | `rules/core.md` | Atributos (hx-get/post/put/delete), swap strategies, triggers, targeting, indicators, headers |
| View Cells + HTMX | `rules/viewcells-htmx.md` | Padrao rota→cell→html, lazy load, inline edit, infinite scroll, polling, SSE |
| CSRF & Seguranca | `rules/csrf-security.md` | X-CSRF-TOKEN, CSP headers, csrf_hash() refresh, hx-headers |
| Forms & Validacao | `rules/forms-validation.md` | hx-post em forms, validacao server-side, re-render do form com erros, hx-target em fields |
| CSS & Animacao | `rules/css-animation.md` | htmx-indicator, htmx-request, htmx-swapping, .htmx-added, transicoes CSS |

## Como Aplicar

1. Identifique o tipo de interacao (swap de conteudo, form submit, lazy load, inline edit)
2. Consulte o arquivo de regras correspondente na tabela acima
3. Sempre retorne HTML completo do servidor — nao JSON
4. View Cells/Blade Components sao a unidade basica de renderizacao — nunca faca queries na view
5. Rota de Cell SEMPRE aplica o filtro CSRF (exceto GETs publicos)
