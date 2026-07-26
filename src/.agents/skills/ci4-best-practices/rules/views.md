# Views

## View Cells (Componentes)

View Cells sao o equivalente a Blade Components do Laravel — encapsulam logica + template em componentes reutilizaveis, renderizados no servidor. Combinados com HTMX, formam uma arquitetura de componentes interativos sem JS framework pesado.

### 1.1 Estrutura Basica

```php
// app/Cells/ProductCard.php
namespace App\Cells;

use CodeIgniter\View\Cells\Cell;

class ProductCard extends Cell
{
    public $product;
    public string $size = 'md';

    public function mount(array $params = []): void
    {
        foreach ($params as $key => $value) {
            if (property_exists($this, $key)) {
                $this->{$key} = $value;
            }
        }
    }

    public function priceFormatted(): string
    {
        return number_format($this->product->price / 100, 2, ',', '.');
    }

    public function render(): string
    {
        return view('cells/product_card', [
            'product' => $this->product,
            'size' => $this->size,
            'price' => $this->priceFormatted(),
        ]);
    }
}
```

```html
<!-- cells/product_card.php -->
<div class="card card-<?= esc($size, 'attr') ?>">
    <h3><?= esc($product->name) ?></h3>
    <span class="price">R$ <?= esc($price) ?></span>
</div>
```

Uso: `<?= view_cell('App\Cells\ProductCard::render', ['product' => $product, 'size' => 'lg']) ?>`

### 1.2 Atomic Design

```
app/Cells/
  Atoms/      # Botoes, Badges, Inputs, Icons (puro, sem regra)
    StatusBadge.php
    ActionButton.php
  Molecules/  # Combina Atoms + logica simples
    SearchBar.php
    CommentForm.php
  Organisms/  # Combina Molecules + dados do dominio
    ProductGrid.php
    CheckoutSummary.php
```

Regras:
- Atoms nao acessam banco nem services — so renderizam props
- Molecules podem acessar services leves (ex: `session()`, `auth()`) e Models via DI
- Organisms podem fazer queries proprias se encapsuladas em cache

### 1.3 Cache em View Cells

```php
class RecentPosts extends Cell
{
    protected int $ttl = 300;

    public function render(): string
    {
        $cacheKey = 'cell_recent_posts_' . (auth()->id() ?? 'guest');
        return cache()->remember($cacheKey, $this->ttl, function () {
            $posts = model('PostModel')->getRecent(10);
            return view('cells/recent_posts', ['posts' => $posts]);
        });
    }
}
```

### 1.4 Form Cells (Render + Validacao)

```php
class EmailInput extends Cell
{
    public string $name = 'email';
    public string $value = '';
    public array $errors = [];

    public function render(): string
    {
        return view('cells/forms/email_input', [
            'name' => $this->name,
            'value' => old($this->name, $this->value),
            'error' => session('errors')[$this->name] ?? null,
        ]);
    }
}
```

## HTMX + View Cells

View Cells renderizam no servidor; HTMX troca fragmentos no DOM. Juntos, formam componentes interativos sem escrever JS.

### 2.1 Padrao: Rota → Cell → HTML → HTMX Swap

```php
// Routes.php
$routes->get('cells/recent-posts/(:num)', 'CellController::recentPosts/$1');
```

```php
// app/Controllers/CellController.php
class CellController extends BaseController
{
    public function recentPosts(int $limit = 5): string
    {
        return view_cell('App\Cells\Organisms\RecentPosts::render', ['limit' => $limit]);
    }
}
```

```html
<!-- View principal -->
<div id="feed" hx-get="/cells/recent-posts/10" hx-trigger="load" hx-swap="innerHTML">
    <span class="loading">Carregando...</span>
</div>
```

### 2.2 Lazy Load com Intersection Observer

```html
<div
    hx-get="/cells/comments/<?= $postId ?>"
    hx-trigger="intersect once"
    hx-swap="outerHTML">
    <div class="skeleton">Carregando comentarios...</div>
</div>
```

### 2.3 Inline Edit (Click-to-Edit)

```html
<!-- Visualizacao -->
<div id="title-<?= $product->id ?>"
     hx-get="/cells/product-title-edit/<?= $product->id ?>"
     hx-trigger="dblclick"
     hx-swap="outerHTML">
    <?= esc($product->title) ?>
</div>
```

```php
// CellController — renderiza form inline
public function productTitleEdit(int $id): string
{
    return view_cell('App\Cells\Molecules\InlineEditTitle::render', [
        'product' => model('ProductModel')->find($id),
    ]);
}
```

```html
<!-- cells/inline_edit_title.php -->
<form id="title-<?= $product->id ?>"
      hx-put="/products/<?= $product->id ?>/title"
      hx-target="this"
      hx-swap="outerHTML">
    <input name="title" value="<?= esc($product->title, 'attr') ?>" autofocus
           hx-get="/cells/product-title-view/<?= $product->id ?>"
           hx-trigger="keyup[key=='Escape']"
           hx-target="this"
           hx-swap="outerHTML" />
</form>
```

### 2.4 Infinite Scroll / Paginacao

```html
<div id="product-grid" hx-get="/cells/products-page/2" hx-trigger="revealed"
     hx-swap="beforeend" hx-indicator="#spinner">
    <?= view_cell('App\Cells\Organisms\ProductGrid::render', ['page' => 1]) ?>
</div>
<div id="spinner" class="htmx-indicator">Carregando...</div>
```

Cell renderiza pagina + prox link automaticamente:
```php
public function render(int $page = 1, int $perPage = 12): string
{
    $products = model('ProductModel')->paginate($perPage, 'default', $page);
    $nextPage = $products['pager']->hasNext() ? $page + 1 : null;
    return view('cells/product_grid', [
        'items' => $products['items'],
        'nextPage' => $nextPage,
    ]);
}
```

A view da Cell inclui `hx-get` no ultimo item para a prox pagina.

### 2.5 CSRF com HTMX

```html
<meta name="csrf-token" content="<?= csrf_hash() ?>" />
```

```js
// assets/js/htmx-config.js
document.body.addEventListener('htmx:configRequest', (e) => {
    e.detail.headers['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').value;
});
document.body.addEventListener('htmx:afterSettle', () => {
    document.querySelector('meta[name="csrf-token"]').setAttribute('content', '<?= csrf_hash() ?>');
});
```

### 2.6 Trigger Avancados

| Trigger | Uso |
|---------|-----|
| `hx-trigger="load"` | Carrega Cell ao abrir pagina |
| `hx-trigger="intersect once"` | Lazy load quando visivel (1 vez) |
| `hx-trigger="input changed delay:300ms"` | Search-as-you-type |
| `hx-trigger="keyup[key=='Enter']"` | Submeter com Enter |
| `hx-trigger="every 30s"` | Polling (ex: notificacoes) |
| `hx-trigger="click from:.btn-group"` | Delegacao de evento |
| `hx-trigger="revealed"` | Quando elemento aparece no DOM |

### 2.7 Swap Strategies

| Swap | Uso |
|------|-----|
| `hx-swap="innerHTML"` | Substitui conteudo do target (padrao) |
| `hx-swap="outerHTML"` | Substitui o proprio elemento (inline edit) |
| `hx-swap="beforeend"` | Append (infinite scroll, chat) |
| `hx-swap="afterbegin"` | Prepend |
| `hx-swap="delete"` | Remove elemento |
| `hx-swap="none"` | So processa response headers (ex: toast) |

### 2.8 Response Headers (do Controller)

```php
return $this->response
    ->setBody(view_cell('App\Cells\Toast::render', ['message' => 'Salvo!']))
    ->setHeader('HX-Trigger', 'toast');
```

```js
document.body.addEventListener('hx:trigger:toast', () => showToast());
```

## Layouts

- Use `<?= $this->extend('layouts/panel') ?>` para layouts compartilhados
- Defina secoes: `<?= $this->section('content') ?>...<?= $this->endSection() ?>`
- Mantenha layouts enxutos — so estrutura, sem regra de negocio
- Meta tag CSRF no `<head>` do layout: `<meta name="csrf-token" content="<?= csrf_hash() ?>">`

## Partials

- Use `<?= $this->include('partials/header') ?>` para fragmentos compartilhados
- Nao repita markup entre views — extraia para partial ou View Cell
- Prefira View Cell sobre partial quando houver logica acoplada

## Dados da View

- Passe dados preparados do Controller/Service: `return view('products/list', ['products' => $products])`
- Nao faca queries no meio da view: `<?= model('ProductModel')->find($id) ?>`
- Pratique escaping: `<?= esc($product->name) ?>`
- Use `esc($value, 'attr')` para atributos HTML, `esc($value, 'js')` para inline JS
