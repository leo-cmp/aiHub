# Routes

## Boas Praticas

### 1. Definicao Explicita
- Defina TODAS as rotas em `app/Config/Routes.php`; desabilite auto-routing
- Use verbos HTTP semanticos: `->get()`, `->post()`, `->put()`, `->patch()`, `->delete()`
- Para htmx, use verbos reais: `hx-put`, `hx-patch`, `hx-delete`

### 2. Route Groups
- Agrupe por prefixo: `$routes->group('admin', ['filter' => 'auth'], static function($routes) {})`
- Aplique filters no grupo: `['filter' => 'auth:admin']`
- Use namespace para agrupar controllers

### 3. Placeholders
- `(:num)` para digitos, `(:alpha)` para letras, `(:any)` para qualquer coisa
- Nomeie parametros: `$routes->get('product/(:num)', 'Product::show/$1')`
- Use `(:segment)` para URIs com hifen/underscore

### 4. RESTful
- Use `presenter()` para rotas RESTful automaticas: `$routes->presenter('products')`
- `options()` para CORS pre-flight

## Exemplos

```php
// Correto:
$routes->group('api/v1', ['namespace' => 'App\Controllers\Api\V1'], static function ($routes) {
    $routes->get('products', 'ProductController::index');
    $routes->get('products/(:num)', 'ProductController::show/$1');
    $routes->post('products', 'ProductController::create');
    $routes->put('products/(:num)', 'ProductController::update/$1');
    $routes->delete('products/(:num)', 'ProductController::delete/$1');
});

// Evitar:
$routes->add('products/(:any)', 'Products::$1');
```
