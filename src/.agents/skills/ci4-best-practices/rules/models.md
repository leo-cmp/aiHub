# Models

## Boas Praticas

### 1. Convencoes
- Nomes em PascalCase (ex: `ProductModel`)
- Defina `$table`, `$primaryKey`, `$allowedFields` e `$useTimestamps` explicitamente
- Use `$beforeInsert` e `$beforeUpdate` callbacks para geracao de IDs e timestamps

### 2. Finders
- Prefira `$model->find($id)` para PK; `$model->where()->first()` para condicoes
- Nao use `$model->asArray()` como padrao — use Entities quando precisar de logica de dominio
- Crie metodos finder nomeados no model: `findActive()`, `findByCategory(string $category)`

### 3. Query Builder
- Use o Query Builder do CI4 (`$this->where()`, `$this->join()`) em vez de SQL bruto
- Nao coloque regra de negocio nos models — apenas queries e configuracoes de tabela
- Use `$this->builder()` para queries customizadas com joins complexos

### 4. Timestamps
- Habilite `$useTimestamps = true` para `created_at`, `updated_at` automaticos
- Use `$useSoftDeletes = true` com campo `deleted_at` para remocoes logicas

## Exemplos

```php
// Correto:
class ProductModel extends Model
{
    protected $table = 'products';
    protected $primaryKey = 'id';
    protected $allowedFields = ['name', 'price', 'category_id', 'active'];
    protected $useTimestamps = true;

    public function findActive(): array
    {
        return $this->where('active', 1)->findAll();
    }

    public function findByCategory(string $categoryId): array
    {
        return $this->where('category_id', $categoryId)
            ->orderBy('name', 'ASC')
            ->findAll();
    }
}

// Evitar:
class ProductModel extends Model
{
    public function getProducts()
    {
        $db = \Config\Database::connect();
        return $db->query("SELECT * FROM products WHERE active = 1")->getResult();
    }
}
```
