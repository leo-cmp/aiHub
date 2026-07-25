# Regras de Negócio — Financeiro

## Precisão Monetária
- Todos os valores monetários usam `DECIMAL(15,2)`.
- Nunca use `FLOAT` ou `DOUBLE` para dinheiro.

## Imutabilidade
- Transações financeiras NUNCA são alteradas após confirmação.
- Estornos criam nova transação (nunca alteram a original).

## Auditoria
- Toda transação registra: `created_at`, `created_by`, `ip_address`.
