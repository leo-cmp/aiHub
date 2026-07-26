# Validation

## Boas Praticas

### 1. Validacao no Controller
- Use `$this->validate($rules, $messages)` no controller
- Defina `$rules` como array associativo: `'campo' => 'regra1|regra2'`
- Verifique `$this->validator->getErrors()` para mensagens de erro

### 2. Custom Rules
- Crie classes em `app/Validation/CustomRules.php`
- Registre no `Config\Validation::$ruleSets`
- Use `{field}` e `{param}` nos templates de mensagem

### 3. Grupos de Validacao
- Defina grupos em `Config\Validation.php`: array `'grupo' => ['campo' => 'regras']`
- Use `$this->validate($rules, $messages, 'grupo')` para aplica-los

### 4. Mensagens em pt-BR
- Use o pacote `natanfelles/codeigniter4-pt-BR` para traducao
- Sobrescreva mensagens customizadas via `$this->validate($rules, ['campo.regra' => 'Mensagem'])`

## Exemplos

```php
// Correto:
$rules = [
    'name' => 'required|min_length[3]|max_length[255]',
    'email' => 'required|valid_email|is_unique[users.email]',
    'price' => 'required|greater_than[0]|decimal',
];

if (!$this->validate($rules)) {
    return redirect()->back()
        ->withInput()
        ->with('errors', $this->validator->getErrors());
}

// Evitar:
$name = $this->request->getPost('name');
if (empty($name)) {
    echo 'Nome obrigatório';
    return;
}
if (strlen($name) < 3) {
    echo 'Nome muito curto';
    return;
}
```
