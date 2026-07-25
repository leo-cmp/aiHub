# CSRF & Seguranca

HTMX envia requests via AJAX — e necessario configurar CSRF corretamente.

## Configuracao CSRF em CI4

### 1. Meta Tag no Layout

```html
<!-- app/Views/layouts/panel.php -->
<head>
    <meta name="csrf-token" content="<?= csrf_hash() ?>" />
    <script src="https://unpkg.com/htmx.org@2"></script>
    <script src="/assets/js/htmx-csrf.js"></script>
</head>
```

### 2. Script de Configuracao CSRF

```js
// public/assets/js/htmx-csrf.js
document.body.addEventListener('htmx:configRequest', (event) => {
    const token = document.querySelector('meta[name="csrf-token"]');
    if (token) {
        event.detail.headers['X-CSRF-TOKEN'] = token.getAttribute('content');
    }
});

document.body.addEventListener('htmx:afterSettle', () => {
    const token = document.querySelector('meta[name="csrf-token"]');
    if (token) {
        token.setAttribute('content', csrf.hash);
    }
});
```

### 3. CI4 Filter (aplicar nas rotas de Cell)

```php
// app/Config/Routes.php
$routes->group('cells', ['filter' => 'csrf'], function ($routes) {
    $routes->post('save', 'CellController::save');
    $routes->put('update/(:num)', 'CellController::update/$1');
    $routes->delete('delete/(:num)', 'CellController::delete/$1');
    // GET nao precisa de CSRF (idempotente)
    $routes->get('(:any)', 'CellController::$1');
});
```

### 4. Headers de Seguranca no Response

```php
// app/Filters/HtmxSecurity.php
namespace App\Filters;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;

class HtmxSecurity implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null) {}

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        // Apenas para rotas HTMX
        if ($request->hasHeader('HX-Request')) {
            $response->setHeader('X-Content-Type-Options', 'nosniff');
            $response->setHeader('X-Frame-Options', 'DENY');
        }
        return $response;
    }
}
```

## CSP (Content Security Policy)

Se usar CSP restritivo, precisa liberar o inline `hx-on:*` se for usar:

```html
<meta http-equiv="Content-Security-Policy"
      content="default-src 'self'; script-src 'self' 'unsafe-inline' https://unpkg.com;" />
```

## Validacao de HX-Request Header

Para garantir que endpoints de Cell so respondem a requests HTMX (nao acessados diretamente pelo navegador):

```php
// app/Filters/HtmxOnly.php
class HtmxOnly implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        if (! $request->hasHeader('HX-Request')) {
            return redirect()->to('/');
        }
    }

    public function after(...) {}
}
```

---

## Boas Praticas

1. **GET = publico, POST/PUT/DELETE = CSRF** — filtro `csrf` nas rotas mutaveis, liberado nas GET
2. **Atualize `csrf_hash()` apos cada request mutavel** — `htmx:afterSettle` atualiza a meta tag
3. **Nao confie so no HX-Request header** — ele e um bypass de CSRF? Nao: CSRF explora cookies de sessao, HX-Request nao protege contra isso. Use CSRF sempre.
4. **Rotas de Cell publicas (GET) podem ser cacheadas** — sem CSRF, sem sessao
5. **Valide permissoes no Controller** — antes de chamar a Cell, verifique se o usuario tem acesso ao recurso
6. **Nunca retorne dados sensiveis em resposta HTMX** — so o HTML necessario para o componente
7. **Rate-limit em rotas de polling** — evite DoS em `/cells/notification-badge` chamado a cada 30s
