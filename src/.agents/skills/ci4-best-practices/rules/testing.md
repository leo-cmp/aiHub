# Testing

## Boas Praticas

### 1. Configuracao
- Use PHPUnit integrado: `vendor/bin/phpunit`
- Testes em `tests/app/` espelhando estrutura de `app/`
- Configure `phpunit.xml.dist` com variaveis de ambiente especificas para testes

### 2. HTTP Tests
- Use `$this->withBodyFormat('json')->post('/api/products', $data)` para APIs
- Verifique `$result->assertStatus(201)`, `$result->assertJSONFragment(['id' => $id])`
- Use `$this->withSession(['user_id' => 1])` para simular sessao

### 3. Database Tests
- Use `use DatabaseTestTrait;` e configure `$refresh = true` para migrar a cada teste
- Popule dados com seeders: `$this->seed('TestDataSeeder')`
- Verifique dados com: `$this->seeInDatabase('products', ['name' => 'Test'])`

### 4. Mocks
- Use `$this->getMockBuilder()` para Services externos
- Mock HTTP responses com `$this->mockClient()`
- Nao mocke Models do proprio projeto — use banco de teste real

## Exemplos

```php
// Correto:
class ProductControllerTest extends FeatureTestCase
{
    use DatabaseTestTrait;

    protected $refresh = true;

    public function testCreateProduct(): void
    {
        $result = $this->withBodyFormat('json')
            ->post('/api/v1/products', [
                'name' => 'Produto Teste',
                'price' => 99.90,
            ]);

        $result->assertStatus(201);
        $result->assertJSONFragment(['name' => 'Produto Teste']);
        $this->seeInDatabase('products', ['name' => 'Produto Teste']);
    }
}
```
