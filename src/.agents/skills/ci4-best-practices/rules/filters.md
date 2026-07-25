# Filters

## Boas Praticas

### 1. Convencoes
- Implementam `FilterInterface` com `before()` e `after()`
- Registrados em `app/Config/Filters.php` nos arrays `$aliases` e `$filters`
- Nome em PascalCase (ex: `AuthFilter`, `CorsFilter`)

### 2. Autenticacao
- Use `before()` para verificar sessao/token antes do controller
- Redirecione para login se nao autenticado: `return redirect()->to('/login')`
- Use `session()->get('user_id')` em vez de acessar cookie direto

### 3. Rate Limit
- Controle por IP ou user ID usando cache
- Retorne 429 Too Many Requests com header Retry-After

### 4. CORS
- Defina headers no `after()` para nao interferir em erros de autenticacao
- Permita origens, metodos e headers especificos — nunca use `*` em producao

## Exemplos

```php
// Correto:
class AuthFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        if (!session()->get('isLoggedIn')) {
            return redirect()->to('/login');
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        // nada
    }
}

// Config/Filters.php:
public array $aliases = [
    'auth' => \App\Filters\AuthFilter::class,
    'cors' => \App\Filters\CorsFilter::class,
];
```
