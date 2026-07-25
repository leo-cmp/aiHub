# Entities

## Boas Praticas

### 1. Convencoes
- Herdam de `CodeIgniter\Entity\Entity`
- Nome igual ao Model sem sufixo (ex: `Product` para `ProductModel`)
- Definir `$dates` para campos que precisam ser instancias de `DateTime`

### 2. Getters e Setters
- Use `setNome()` para transformar dados ao atribuir (ex: lowercase para email)
- Use `getNome()` para transformar dados ao acessar (ex: formatar data)
- Nunca acesse o banco de dados de dentro de uma Entity

### 3. Casting
- Defina `$casts` para tipos primitivos: `'integer'`, `'float'`, `'boolean'`, `'datetime'`
- Use casting manual em setters para formatos customizados

### 4. Hydratation
- O Model faz `find()` ou `first()` e retorna a Entity automaticamente
- Para criar manualmente: `$entity = new Product($data)`

## Exemplos

```php
// Correto:
class Product extends Entity
{
    protected $dates = ['created_at', 'updated_at'];
    protected $casts = [
        'id' => 'integer',
        'price' => 'float',
        'active' => 'boolean',
    ];

    public function setName(string $name): static
    {
        $this->attributes['name'] = trim($name);
        return $this;
    }

    public function getPriceFormatted(): string
    {
        return 'R$ ' . number_format($this->attributes['price'], 2, ',', '.');
    }
}

// Evitar:
class Product extends Entity
{
    public function getPrice()
    {
        $model = new ProductModel();
        $discount = $model->getDiscount($this->id);
        return $this->attributes['price'] - $discount;
    }
}
```
