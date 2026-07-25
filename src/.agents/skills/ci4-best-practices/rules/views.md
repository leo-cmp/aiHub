# Views

## Boas Praticas

### 1. View Cells (Atomic Design)
- Use View Cells para componentes reutilizaveis: `<?= view_cell('App\Cells\Atoms\StatusBadge::render', ['status' => $status]) ?>`
- Organize em Atoms, Molecules, Organisms, Templates, Pages
- Cada Cell e independente: so recebe dados via props, nao acessa banco diretamente

### 2. Layouts
- Use `<?= $this->extend('layouts/panel') ?>` para layouts compartilhados
- Defina secoes: `<?= $this->section('content') ?>...<?= $this->endSection() ?>`
- Mantenha layouts enxutos — so estrutura, sem regra de negocio

### 3. Partials
- Use `<?= $this->include('partials/header') ?>` para fragmentos compartilhados
- Nao repita markup entre views — extraia para partial ou View Cell

### 4. Dados da View
- Passe dados preparados do Controller/Service: `return view('products/list', ['products' => $products])`
- Nao faca queries no meio da view: `<?= model('ProductModel')->find($id) ?>`
- Pratique escaping: `<?= esc($product->name) ?>`

## Exemplos

```php
// Correto:
// app/Cells/Atoms/StatusBadge.php
class StatusBadge
{
    public string $status = 'pending';
    public string $class = '';

    public function render(): string
    {
        $this->class = match ($this->status) {
            'active' => 'badge-success',
            'pending' => 'badge-warning',
            default => 'badge-ghost',
        };
        return view('cells/atoms/status_badge', ['status' => $this->status, 'class' => $this->class]);
    }
}

// View:
<?= view_cell('App\Cells\Atoms\StatusBadge::render', ['status' => $order->status]) ?>

// Evitar:
<?php foreach ($products as $product): ?>
    <div class="product-card">
        <h3><?= $product->name ?></h3>
        <p><?= $product->description ?></p>
        <?php $category = model('CategoryModel')->find($product->category_id); ?>
        <span><?= $category->name ?? '' ?></span>
    </div>
<?php endforeach; ?>
```
