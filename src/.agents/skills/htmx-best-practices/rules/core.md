# Core HTMX

## Atributos Principais

### hx-get / hx-post / hx-put / hx-delete
```html
<button hx-post="/orders/<?= $orderId ?>/approve" hx-target="#status-<?= $orderId ?>" hx-swap="innerHTML">
    Aprovar
</button>
<div id="status-<?= $orderId ?>">
    <?= view_cell('App\Cells\Atoms\StatusBadge::render', ['status' => $order->status]) ?>
</div>
```

**Regras:**
- GET: leitura, busca, carregamento de fragmentos (idempotente, cacheavel)
- POST: criacao, acoes sem side-effect repetivel
- PUT: atualizacao completa de recurso
- DELETE: remocao
- Nunca use GET para operacoes que alteram estado

### hx-target
Define onde o HTML retornado sera inserido.
```html
<!-- Target por ID -->
<button hx-get="/cells/search" hx-target="#results">Buscar</button>
<div id="results"></div>

<!-- Target relativo (CSS selector) -->
<div hx-get="/cells/edit" hx-target="next .editor" hx-swap="innerHTML">Editar</div>
<div class="editor"></div>

<!-- Strategy: this (o proprio elemento), closest, find, next, previous -->
```

### hx-swap (Estrategias de Substituicao)

| Valor | Comportamento | Uso tipico |
|-------|---------------|------------|
| `innerHTML` | Substitui conteudo do target (default) | Conteudo dinamico, resultados de busca |
| `outerHTML` | Substitui o proprio elemento | Inline edit, toggle de estado |
| `beforebegin` | Insere antes do target | Prepend item em lista |
| `afterbegin` | Insere no inicio do target | Prepend em feed |
| `beforeend` | Insere no fim do target | Append (infinite scroll, chat) |
| `afterend` | Insere depois do target | Append item em lista |
| `delete` | Remove o target | Deletar item com animacao |
| `none` | Nao faz swap | Side effects via HX-Trigger header |

### Modificadores de Swap
```html
<!-- Transicao CSS + scroll apos swap -->
<div hx-get="/cells/next" hx-swap="innerHTML transition:true" hx-target="#feed"></div>

<!-- Scroll para topo/target apos swap -->
<div hx-get="/cells/page" hx-swap="innerHTML show:top" hx-target="#content"></div>
<div hx-get="/cells/page" hx-swap="innerHTML show:#item-<?= $id ?>" hx-target="#content"></div>

<!-- Espera transicao terminar antes do proximo swap (default em v2) -->
<div hx-swap="innerHTML swap:200ms"></div>

<!-- Ignora titulo do response (nao atualiza <title> nem historico) -->
<div hx-get="/cells/fragment" hx-swap="innerHTML ignoreTitle:true"></div>

<!-- Estabiliza scroll durante swap -->
<div hx-get="/cells/list" hx-swap="innerHTML scroll:false"></div>
```

## Triggers

### Triggers Padrao
```html
<!-- Natural triggers: input/textarea/select → change, form → submit, outros → click -->
<button hx-post="/like">Curtir</button>  <!-- click (default) -->

<!-- Load: dispara ao carregar a pagina -->
<div hx-get="/cells/stats" hx-trigger="load"></div>

<!-- Revealed: quando elemento aparece no DOM (novo em v2) -->
<div hx-get="/cells/comments" hx-trigger="revealed"></div>

<!-- Intersect: quando visivel no viewport -->
<div hx-get="/cells/lazy-image/<?= $id ?>" hx-trigger="intersect once"></div>

<!-- Every: polling periodico -->
<div hx-get="/cells/notifications-count" hx-trigger="every 30s"></div>
```

### Filtros de Trigger
```html
<!-- Atraso (search-as-you-type) -->
<input hx-get="/cells/search" hx-trigger="input changed delay:300ms"
       hx-target="#results" name="q" />

<!-- Tecla especifica -->
<input hx-get="/cells/autocomplete" hx-trigger="keyup[key=='ArrowDown']" />

<!-- Modificadores -->
<button hx-post="/save" hx-trigger="click[ctrlKey]">Salvar (Ctrl+Click)</button>

<!-- So dispara se condicao JS for true -->
<button hx-get="/cells/next" hx-trigger="click[hasMore]">Proximo</button>
```

### Delegacao de Eventos
```html
<!-- Todos os botoes .btn-page dentro de #feed -->
<div id="feed" hx-get="/cells/posts" hx-trigger="click from:.btn-page" hx-target="#feed"></div>
```

### Trigger Server-Side (HX-Trigger)
```php
// Controller retorna header que dispara evento no client
return $this->response
    ->setBody(view_cell('App\Cells\Toast::render', ['message' => 'Salvo!']))
    ->setHeader('HX-Trigger', 'toast-success');

// Multiplos eventos (JSON)
->setHeader('HX-Trigger', json_encode([
    'toast' => ['level' => 'success', 'message' => 'Salvo!'],
    'reload-sidebar' => '',
]));
```

```js
// Listener no client
document.body.addEventListener('toast-success', () => showToast('Salvo com sucesso!'));
```

### Trigger Apos Swap
```html
<!-- hx-trigger apos o swap (novo em v2) -->
<form hx-post="/save" hx-target="this" hx-swap="outerHTML"
      hx-trigger-after-swap="load">
```

## Indicadores de Loading

```html
<!-- Spinner padrao -->
<div id="content" hx-get="/cells/data" hx-indicator="#spinner">...</div>
<img id="spinner" class="htmx-indicator" src="/spinner.svg" />

<!-- Atributo CSS (spinner inline) -->
<button hx-post="/save" class="btn" hx-disabled-elt="this">
    Salvar
    <span class="spinner htmx-indicator"></span>
</button>
```

## hx-sync (Controle de Concorrencia)

```html
<!-- Aborta request anterior ao fazer nova -->
<input hx-get="/cells/search" hx-trigger="input delay:300ms"
       hx-sync="closest form:abort" hx-target="#results" />

<!-- Enfileira requests -->
<button hx-post="/process" hx-sync="#pipeline:queue">Processar</button>

<!-- Dropa (ignora) requests enquanto um esta em voo -->
<button hx-post="/generate" hx-sync="this:drop">Gerar</button>
```

## hx-history (Navegacao)

```html
<!-- Push URL no historico -->
<a hx-get="/cells/page/2" hx-push-url="true" hx-target="#content">Pagina 2</a>

<!-- Restaurar scroll ao voltar -->
<div hx-get="/cells/list" hx-history="false">...</div>
```

## Headers Customizados

```html
<div hx-get="/cells/data" hx-headers='{"X-Client": "dashboard"}'>Carregar</div>
```

Ou globalmente via `<meta name="htmx-config" content='{"defaultHeaders":{"X-Client":"dashboard"}}'>`.
