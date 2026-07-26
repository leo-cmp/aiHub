# Forms & Validacao

## Form Submit com HTMX

```html
<form hx-post="/products"
      hx-target="this"
      hx-swap="outerHTML"
      hx-indicator="#form-spinner">
    <input type="text" name="title" value="<?= old('title') ?>" />
    <textarea name="description"><?= old('description') ?></textarea>
    <button type="submit">
        Salvar
        <span id="form-spinner" class="htmx-indicator spinner"></span>
    </button>
</form>
```

## Validacao Server-Side (CI4)

```php
// app/Controllers/ProductController.php
public function store(): string
{
    $rules = [
        'title' => 'required|min_length[3]|max_length[255]',
        'description' => 'required|min_length[10]',
    ];

    if (! $this->validate($rules)) {
        // Retorna o form com erros — nao redireciona
        return view_cell('App\Cells\Molecules\ProductForm::render', [
            'errors' => $this->validator->getErrors(),
            'data' => $this->request->getPost(),
        ]);
    }

    $id = model('ProductModel')->insert($this->request->getPost());

    // Sucesso: retorna a visualizacao do item + trigger toast
    $product = model('ProductModel')->find($id);
    $this->response->setHeader('HX-Trigger', json_encode([
        'toast' => ['level' => 'success', 'message' => 'Produto criado!'],
    ]));

    return view_cell('App\Cells\Organisms\ProductCard::render', ['product' => $product]);
}
```

## Form Cell que Renderiza Erros

```php
// app/Cells/Molecules/ProductForm.php
class ProductForm extends Cell
{
    public array $errors = [];
    public array $data = [];
    public ?object $product = null; // null = create, object = edit

    public function render(): string
    {
        return view('cells/molecules/product_form', [
            'errors' => $this->errors,
            'data' => $this->data,
            'product' => $this->product,
        ]);
    }
}
```

```html
<!-- cells/molecules/product_form.php -->
<form hx-post="<?= $product ? '/products/' . $product->id : '/products' ?>"
      hx-target="this" hx-swap="outerHTML"
      class="space-y-4">
    <div class="form-control">
        <label class="label">Titulo</label>
        <input type="text" name="title"
               class="input input-bordered <?= isset($errors['title']) ? 'input-error' : '' ?>"
               value="<?= esc(old('title', $data['title'] ?? $product->title ?? ''), 'attr') ?>" />
        <?php if (isset($errors['title'])): ?>
            <label class="label"><span class="label-text-alt text-error"><?= esc($errors['title']) ?></span></label>
        <?php endif; ?>
    </div>

    <div class="form-control">
        <label class="label">Descricao</label>
        <textarea name="description"
                  class="textarea textarea-bordered <?= isset($errors['description']) ? 'textarea-error' : '' ?>"><?= esc(old('description', $data['description'] ?? $product->description ?? '')) ?></textarea>
        <?php if (isset($errors['description'])): ?>
            <label class="label"><span class="label-text-alt text-error"><?= esc($errors['description']) ?></span></label>
        <?php endif; ?>
    </div>

    <button type="submit" class="btn btn-primary"
            hx-disabled-elt="this">
        Salvar
        <span class="htmx-indicator loading loading-spinner"></span>
    </button>
</form>
```

## Validacao em Tempo Real (Field-Level)

```html
<input type="text" name="email"
       hx-post="/validate/email"
       hx-trigger="input changed delay:500ms"
       hx-target="next .field-error"
       hx-swap="innerHTML"
       class="input input-bordered" />
<div class="field-error text-error text-sm"></div>
```

```php
// CellController — valida campo unico e retorna erro ou vazio
public function validateEmail(): string
{
    $email = $this->request->getPost('email');
    $validation = \Config\Services::validation();
    $validation->setRule('email', 'Email', 'valid_email|is_unique[users.email]');

    if (! $validation->run(['email' => $email])) {
        return '<span>' . esc($validation->getError('email')) . '</span>';
    }
    return '';
}
```

## File Upload com HTMX

```html
<form hx-encoding="multipart/form-data"
      hx-post="/upload"
      hx-target="#preview"
      hx-swap="innerHTML">
    <input type="file" name="image" accept="image/*" />
    <button type="submit">Upload</button>
</form>
```

```php
// Controller
public function upload(): string
{
    $file = $this->request->getFile('image');
    if (! $file->isValid()) {
        return view_cell('App\Cells\Atoms\Alert::render', ['type' => 'error', 'message' => $file->getErrorString()]);
    }

    $path = $file->store();
    return view_cell('App\Cells\Molecules\ImagePreview::render', ['path' => $path]);
}
```

## Confirmacao Antes de Delete

```html
<button hx-delete="/products/<?= $id ?>"
        hx-confirm="Tem certeza que deseja excluir este produto?"
        hx-target="closest .product-card"
        hx-swap="delete">
    Excluir
</button>
```

## Redirecionamento Apos Submit

Use `HX-Redirect` header:

```php
// Apos criar produto, redireciona pra lista
return $this->response
    ->setHeader('HX-Redirect', site_url('/products'));
```

Ou redireciona via `hx-push-url` apos swap:

```html
<form hx-post="/products"
      hx-push-url="/products"
      hx-target="#content"
      hx-swap="innerHTML">
```

---

## Boas Praticas

1. **Sempre retorne o form com erros** — nunca redirecione com flash message em requests HTMX (o usuario perde o contexto)
2. **Nao use `$this->request->getPost()` sem validar** — use `$this->request->getPost('field')` com fallback
3. **Form re-renderiza com `outerHTML`** — substitui o form inteiro, nao so o conteudo
4. **Use `hx-disabled-elt` no botao submit** — evita double-submit
5. **`hx-confirm` para acoes destrutivas** — sem precisar de JS customizado
6. **File upload usa `hx-encoding="multipart/form-data"`** — obrigatorio para arquivos
7. **Sempre retorne HTML com codigo de status adequado** — 422 para erro de validacao, 201 para criado, 200 para sucesso
