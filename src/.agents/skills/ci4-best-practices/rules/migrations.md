# Migrations

## Boas Praticas

### 1. Criação
- Use `php spark make:migration NomeDaMigration` para criar
- Nome descritivo: `CreateProductsTable`, `AddCategoryIdToProducts`
- Uma migration por alteracao de schema

### 2. Forge
- Use `$this->forge->addField()` para definir colunas
- Defina PKs, FKs, indices e constraints explicitamente
- Use `$this->forge->createTable('table', true)` com IF NOT EXISTS

### 3. Indices e Foreign Keys
- Crie indices em colunas de busca e filtro frequente
- Use `$this->forge->addForeignKey()` para FKs com ON DELETE/UPDATE
- Nomeie indices e FKs explicitamente para facilitar rollback

### 4. Rollback
- A funcao `down()` deve desfazer exatamente o que `up()` fez
- `$this->forge->dropTable('table', true)` com IF EXISTS
- Remova FKs antes de dropar tabelas

## Exemplos

```php
// Correto:
public function up()
{
    $this->forge->addField([
        'id' => ['type' => 'VARCHAR', 'constraint' => 26],
        'name' => ['type' => 'VARCHAR', 'constraint' => 255],
        'price' => ['type' => 'DECIMAL', 'constraint' => '15,2'],
        'category_id' => ['type' => 'VARCHAR', 'constraint' => 26, 'null' => true],
        'created_at' => ['type' => 'DATETIME', 'null' => true],
        'updated_at' => ['type' => 'DATETIME', 'null' => true],
    ]);
    $this->forge->addKey('id', true);
    $this->forge->addForeignKey('category_id', 'categories', 'id', 'SET NULL', 'CASCADE');
    $this->forge->createTable('products', true);
}

public function down()
{
    $this->forge->dropTable('products', true);
}
```
