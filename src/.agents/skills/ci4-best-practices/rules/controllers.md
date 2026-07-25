# Controllers

## Boas Praticas

### 1. Convencoes
- Nomes em PascalCase com sufixo `Controller` (ex: `ProductController`)
- Metodos publicos sao acionaveis por rota; metodos privados/protegidos sao auxiliares
- Use `$this->request` para acessar a requisicao em vez de `service('request')`

### 2. Injeção de Dependencia
- Prefira injetar services via construtor com `Services::nome()` em vez de instanciar direto
- Use `$this->service` em vez de `model()` helper dentro do controller

### 3. Respostas
- Use `$this->response` com tipos explicitos (`setJSON()`, `setXML()`, `noCache()`)
- Sempre retorne o objeto Response; nao use `echo` ou `exit`
- Se API, defina Content-Type e status code explicitamente

### 4. Controller Enxuto
- Maximo 5 linhas por metodo: receber input, delegar ao service, retornar resposta
- Nao coloque regra de negocio ou queries diretas em controllers
- Validacao de formulario usa `$this->validate()` e redireciona com `redirect()->withInput()`

## Exemplos

```php
// Correto:
class ProductController extends BaseController
{
    private ProductService $productService;

    public function __construct()
    {
        $this->productService = Services::product();
    }

    public function show(string $id): ResponseInterface
    {
        $product = $this->productService->findById($id);
        return $this->response->setJSON($product);
    }
}

// Evitar:
class ProductController extends BaseController
{
    public function show($id)
    {
        $model = new ProductModel();
        echo json_encode($model->find($id));
    }
}
```
