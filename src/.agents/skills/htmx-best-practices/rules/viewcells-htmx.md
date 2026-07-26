# View Cells + HTMX

A combinacao: Cell renderiza no servidor, HTMX faz swap no DOM. Cada Cell e um endpoint renderizavel.

## Padrao Canonic

```
Browser → HTMX request → Route → Controller → view_cell() → HTML → HTMX swap
```

### 1. Rota dedicada para Cell

```php
// app/Config/Routes.php
$routes->group('cells', ['filter' => 'csrf'], function ($routes) {
    $routes->get('status-badge/(:segment)', 'CellController::statusBadge/$1');
    $routes->get('product-grid/(:num)', 'CellController::productGrid/$1');
    $routes->get('inline-edit-title/(:num)', 'CellController::inlineEditTitle/$1');
});
```

### 2. CellController (magro)

```php
// app/Controllers/CellController.php
namespace App\Controllers;

use CodeIgniter\Controller;

class CellController extends Controller
{
    public function statusBadge(string $status): string
    {
        return view_cell('App\Cells\Atoms\StatusBadge::render', ['status' => $status]);
    }

    public function productGrid(int $page = 1): string
    {
        return view_cell('App\Cells\Organisms\ProductGrid::render', ['page' => $page]);
    }

    public function inlineEditTitle(int $id): string
    {
        $product = model('ProductModel')->find($id);
        if (! $product) {
            return $this->response->setStatusCode(404)->setBody('');
        }
        return view_cell('App\Cells\Molecules\InlineEditTitle::render', ['product' => $product]);
    }
}
```

**Regras:**
- Controller so chama a Cell — zero logica de negocio
- Valide existencia do recurso antes de passar pra Cell
- Retorne string (HTML puro), nunca view completa com layout

## Patterns

### Lazy Load (intersect once)

```html
<!-- So carrega quando visivel no viewport (1 vez) -->
<div hx-get="/cells/comments/<?= $postId ?>"
     hx-trigger="intersect once"
     hx-swap="innerHTML">
    <div class="skeleton skeleton-text"></div>
</div>
```

### Inline Edit (Click-to-Edit)

```html
<!-- Visualizacao → duplo clique → form inline -->
<span id="title-<?= $product->id ?>"
      hx-get="/cells/inline-edit-title/<?= $product->id ?>"
      hx-trigger="dblclick"
      hx-swap="outerHTML">
    <?= esc($product->title) ?>
</span>
```

Cell que renderiza o form:
```php
// app/Cells/Molecules/InlineEditTitle.php
class InlineEditTitle extends Cell
{
    public $product;

    public function render(): string
    {
        return view('cells/molecules/inline_edit_title', [
            'product' => $this->product,
        ]);
    }
}
```

```html
<!-- cells/molecules/inline_edit_title.php -->
<form id="title-<?= $product->id ?>"
      hx-put="/products/<?= $product->id ?>/title"
      hx-target="this"
      hx-swap="outerHTML">
    <input type="text" name="title" value="<?= esc($product->title, 'attr') ?>"
           class="input input-bordered input-sm" autofocus
           hx-get="/cells/product-title-view/<?= $product->id ?>"
           hx-trigger="keyup[key=='Escape']"
           hx-target="this"
           hx-swap="outerHTML" />
</form>
```

Controller que processa o PUT:
```php
public function updateTitle(int $id): string
{
    $title = $this->request->getPost('title');
    model('ProductModel')->update($id, ['title' => $title]);
    $product = model('ProductModel')->find($id);

    return view_cell('App\Cells\Atoms\ProductTitle::render', ['product' => $product]);
}
```

### Infinite Scroll

```html
<div id="feed">
    <?= view_cell('App\Cells\Organisms\PostGrid::render', ['page' => 1]) ?>
</div>
```

```php
// PostGrid.php — renderiza pagina + link para proxima
class PostGrid extends Cell
{
    public int $page = 1;
    public int $perPage = 10;

    public function render(): string
    {
        $posts = model('PostModel')->paginate($this->perPage, 'default', $this->page);
        $pager = model('PostModel')->pager;
        $nextPage = $pager->hasNext() ? $this->page + 1 : null;

        return view('cells/organisms/post_grid', [
            'posts' => $posts,
            'nextPage' => $nextPage,
        ]);
    }
}
```

```html
<!-- cells/organisms/post_grid.php -->
<?php foreach ($posts as $post): ?>
    <?= view_cell('App\Cells\Molecules\PostCard::render', ['post' => $post]) ?>
<?php endforeach; ?>

<?php if ($nextPage): ?>
    <div hx-get="/cells/post-grid/<?= $nextPage ?>"
         hx-trigger="intersect once"
         hx-swap="outerHTML"
         hx-target="this">
        <div class="skeleton">Carregando mais...</div>
    </div>
<?php endif; ?>
```

### Polling (Atualizacao Periodica)

```html
<!-- Badge de notificacoes atualiza a cada 30s -->
<?= view_cell('App\Cells\Atoms\NotificationBadge::render') ?>
```

```html
<!-- cells/atoms/notification_badge.php -->
<span id="notification-badge"
      hx-get="/cells/notification-badge"
      hx-trigger="every 30s"
      hx-swap="outerHTML">
    <?php if ($count > 0): ?>
        <span class="badge badge-error"><?= $count ?></span>
    <?php endif; ?>
</span>
```

### Modal / Dialog com HTMX

```html
<button hx-get="/cells/modal/product-details/<?= $id ?>"
        hx-target="#modal-container"
        hx-swap="innerHTML">
    Detalhes
</button>
<dialog id="modal-container"></dialog>
```

```html
<!-- cells/organisms/product_details_modal.php -->
<article>
    <h3><?= esc($product->name) ?></h3>
    <p><?= esc($product->description) ?></p>
    <button hx-get="/cells/empty" hx-target="#modal-container" hx-swap="innerHTML">Fechar</button>
</article>
```

---

## Boas Praticas

1. **Rota de Cell sempre retorna HTML, nunca JSON** — HTMX espera HTML
2. **Cell nao acessa `$this->request` diretamente** — receba dados via props do Controller
3. **Use cache nas Cells pesadas** — `cache()->remember('cell_key', $ttl, fn() => ...)`
4. **Nao coloque layout em resposta de Cell** — apenas o fragmento que sera swapeado
5. **Sempre considere estado vazio** — Cell deve renderizar algo significativo quando nao ha dados
6. **Indicadores de loading** — sempre inclua `hx-indicator` para feedback visual
7. **Trate erros** — Cells devem retornar HTML de erro + status code, nunca quebrar o HTMX
