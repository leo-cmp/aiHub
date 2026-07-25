# CSS & Animacao

HTMX expoe estados via classes CSS no elemento que faz o request e no target. Use isso para animacoes declarativas — sem JS.

## Classes HTMX no Elemento (quem dispara)

| Classe | Quando |
|--------|--------|
| `.htmx-request` | Durante o request |
| `.htmx-sending` | Enquanto envia (v2) |
| `.htmx-loading` | Equivalente a `.htmx-request` (alias) |

## Classes HTMX no Target (quem recebe)

| Classe | Quando |
|--------|--------|
| `.htmx-swapping` | Antes do swap (breve) |
| `.htmx-settling` | Apos swap, transicoes CSS ativas |
| `.htmx-added` | Elementos novos inseridos no DOM |
| `.htmx-before-swap` | Elemento original (antes do swap, depois some) |
| `.htmx-before-settle` | Elemento apos swap (antes de remover classes) |

## Indicadores de Loading

### Padrao: `htmx-indicator`

```html
<button hx-post="/save" hx-indicator="#spinner">
    Salvar
</button>
<img id="spinner" class="htmx-indicator" src="/spinner.svg" style="display:none" />
```

```css
.htmx-indicator {
    display: none;
}
.htmx-request .htmx-indicator,
.htmx-request.htmx-indicator {
    display: inline;
}
```

### Tailwind CSS + HTMX

```html
<button hx-post="/save" hx-disabled-elt="this"
        class="btn btn-primary">
    <span class="htmx-indicator-content">Salvar</span>
    <span class="htmx-indicator loading loading-spinner hidden"></span>
</button>
```

```css
.htmx-indicator-content { display: inline; }
.htmx-indicator { display: none; }
.htmx-request .htmx-indicator-content { display: none; }
.htmx-request .htmx-indicator { display: inline-flex; }
```

### Skeleton Loading

```html
<div id="content" hx-get="/cells/products"
     hx-trigger="load" hx-swap="innerHTML">
    <div class="skeleton skeleton-card"></div>
    <div class="skeleton skeleton-card"></div>
    <div class="skeleton skeleton-card"></div>
</div>
```

```css
.skeleton-card {
    @apply h-48 bg-base-200 animate-pulse rounded-lg;
}
```

## Transicoes CSS (View Transitions)

### Fade In (ao inserir novo conteudo)

```css
.htmx-added {
    animation: fadeIn 200ms ease-in;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(8px); }
    to   { opacity: 1; transform: translateY(0); }
}
```

### Fade Out (ao remover elemento)

```css
.htmx-swapping.htmx-swap-delete {
    animation: fadeOut 200ms ease-out;
}

@keyframes fadeOut {
    from { opacity: 1; transform: scale(1); }
    to   { opacity: 0; transform: scale(0.95); }
}
```

Para usar com `hx-swap="delete"`, adicione ao target:
```html
<div id="item-<?= $id ?>" class="htmx-swappable">...</div>
```

E no swap:
```html
<button hx-delete="/items/<?= $id ?>"
        hx-target="#item-<?= $id ?>"
        hx-swap="delete swap:200ms">
    Excluir
</button>
```

O delay no swap (`swap:200ms`) espera a animacao terminar antes de remover do DOM.

### Transicao ao Trocar Conteudo

```html
<div hx-get="/cells/page/2"
     hx-target="#content"
     hx-swap="innerHTML transition:true">
    Proxima
</div>
```

```css
#content.htmx-swapping {
    opacity: 0;
    transition: opacity 150ms ease-out;
}
#content {
    transition: opacity 150ms ease-in;
}
```

Ou com `@starting-style` (navegadores modernos):
```css
#content {
    transition: opacity 150ms;
}
@starting-style {
    #content.htmx-swapping { opacity: 0; }
}
```

### Swap em Grupo (Varios Elementos com Mesma Transicao)

```css
.feed-item {
    transition: all 300ms ease;
}
.feed-item.htmx-swapping {
    opacity: 0;
    transform: translateX(24px);
}
.htmx-added.feed-item {
    opacity: 0;
    transform: translateY(12px);
}
```

## hx-preserve (Manter Elemento Durante Swap)

```html
<div id="timeline" hx-get="/cells/timeline" hx-trigger="every 10s" hx-swap="innerHTML">
    <audio id="player" hx-preserve="true" controls></audio>
    <div>...</div>
</div>
```

## hx-target-error (Fallback em Erro)

```html
<button hx-post="/api/danger"
        hx-target="#result"
        hx-target-error="#error-box"
        hx-swap="innerHTML">
    Executar
</button>
<div id="result"></div>
<div id="error-box" class="text-error"></div>
```

---

## Boas Praticas

1. **Use classes HTMX, nao listeners JS** — `.htmx-request`, `.htmx-added`, `.htmx-swapping` sao suficientes para 90% das animacoes
2. **Sempre defina `hx-indicator`** — usuario precisa saber que algo esta acontecendo
3. **Atraso no swap para animacao de saida** — `hx-swap="delete swap:200ms"` com `.htmx-swap-delete`
4. **Skeleton > Spinner para cargas iniciais** — define altura/largura esperada, evita layout shift
5. **`hx-preserve` para players/estado** — audio, video, iframe, canvas que nao devem ser destruidos
6. **View Transitions no swap** — `hx-swap="innerHTML transition:true"` para transicoes suaves entre estados
7. **`hx-target-error` para feedback de erro** — separa fluxo feliz do fluxo de erro no DOM
8. **Prefira animacoes curtas (150-300ms)** — sensacao de fluidez sem atrasar o usuario
