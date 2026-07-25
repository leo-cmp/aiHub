# Security

## Boas Praticas

### 1. XSS Prevention
- Use `esc($value)` para output HTML; `esc($value, 'attr')` para atributos
- Use `esc($value, 'js')` para contexto JavaScript
- Nunca confie em `$request->getGet()` ou `$request->getPost()` sem sanitizacao

### 2. CSRF Protection
- Habilite em `app/Config/Filters.php`: `'csrf' => \CodeIgniter\Filters\CSRF::class`
- Use `csrf_field()` helper em todos os forms
- Para APIs, use token via header em vez de campo hidden

### 3. SQL Injection
- Use Query Builder do CI4 — ja faz binding de parametros
- Se precisar de SQL bruto, use `$db->query('SELECT * FROM table WHERE id = ?', [$id])`
- Nunca concatene input de usuario em queries

### 4. Validacao de Input
- Valide TODOS os inputs com `$this->validate()` antes de processar
- Use `$this->request->getPost('campo', FILTER_SANITIZE_STRING)` para sanitizacao basica
- Para numeros: `FILTER_VALIDATE_INT`, `FILTER_VALIDATE_FLOAT`

## Exemplos

```php
// Correto:
$id = $this->request->getPost('id');
$model->where('id', $id)->find(); // Query Builder com binding

// view:
<input type="hidden" name="<?= csrf_token() ?>" value="<?= csrf_hash() ?>">
<p><?= esc($user->name) ?></p>

// Evitar:
$id = $_POST['id'];
$db->query("SELECT * FROM users WHERE id = $id"); // SQL Injection!
```
