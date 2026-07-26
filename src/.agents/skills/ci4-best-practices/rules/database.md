# Database

## Boas Praticas

### 1. Queries
- Use Query Builder: `$db->table('products')->where('active', 1)->get()`
- Para queries complexas, use `$db->query('SELECT ...', $binds)` com parametros
- Use `$db->transStart()` e `$db->transComplete()` para transacoes

### 2. Joins
- Prefira joins via Query Builder: `$db->table('p')->join('c', 'c.id = p.category_id')`
- Sempre prefixe colunas em joins: `p.name`, `c.name as category_name`
- Evite subqueries quando um join resolve

### 3. Performance
- Use `$db->table('x')->select('col1, col2')` — nunca `SELECT *` em queries de producao
- Use `$model->paginate(20)` para listas grandes
- Crie indices para colunas usadas em WHERE, JOIN e ORDER BY

### 4. Migrations para Schema
- Nunca altere schema via SQL bruto em producao — use migrations
- Teste migrations com `php spark migrate` e `php spark migrate:rollback`
- Use seeders para dados iniciais/auxiliares

## Exemplos

```php
// Correto:
$result = $db->table('products p')
    ->select('p.id, p.name, p.price, c.name as category')
    ->join('categories c', 'c.id = p.category_id', 'left')
    ->where('p.active', 1)
    ->orderBy('p.name', 'ASC')
    ->get()
    ->getResult();

// Transaction:
$db->transStart();
$orderModel->insert($orderData);
$stockModel->decrement($productId, $quantity);
$db->transComplete();

// Evitar:
$db->query("SELECT * FROM products p LEFT JOIN categories c ON c.id = p.category_id");
```
