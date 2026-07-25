# Services

## Boas Praticas

### 1. Service Layer
- Orquestram Models e Entities — centralizam regras de negocio
- Nao estendem `BaseController` — sao classes PHP puras
- Nome em PascalCase com sufixo `Service` (ex: `ProductService`)

### 2. Injecao e Registro
- Registre em `app/Config/Services.php`: `public static function product($getShared = true)`
- Use `$getShared = true` para singleton (padrao), `false` para nova instancia
- Injete via `Services::product()` no controller

### 3. Responsabilidades
- Validacao de regra de negocio (ex: "nao pode comprar se estoque zerado")
- Orquestracao de multiplos Models (ex: criar pedido + atualizar estoque)
- Integracao com servicos externos (APIs, emails, filas)

### 4. Não Responsabilidades
- Nao acessam diretamente `$_POST`, `$_GET` ou `$request` do controller
- Nao retornam HTML ou Response objects — retornam dados ou excecoes
- Nao fazem renderizacao de views

## Exemplos

```php
// Correto:
class ProductService
{
    private ProductModel $productModel;
    private StockModel $stockModel;

    public function __construct()
    {
        $this->productModel = new ProductModel();
        $this->stockModel = new StockModel();
    }

    public function purchase(string $productId, int $quantity): Product
    {
        if (!$this->stockModel->hasStock($productId, $quantity)) {
            throw new \RuntimeException('Estoque insuficiente');
        }

        $product = $this->productModel->find($productId);
        $this->stockModel->decrement($productId, $quantity);

        return $product;
    }
}

// Config\Services.php:
public static function product($getShared = true)
{
    if ($getShared) {
        return static::getSharedInstance('product');
    }
    return new ProductService();
}

// Evitar:
class ProductService
{
    public function purchase($request)
    {
        $productId = $request->getPost('product_id');
        // ...
        echo json_encode($result);
    }
}
```
