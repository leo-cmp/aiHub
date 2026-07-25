---
id: TASK-1.2
title: "Service de Cálculo de Frete"
created_at: 2026-07-25 14:00
updated_at: 2026-07-25 15:30
status: in_progress
assignee: claude
cargo: "backend-engineer"
modelo_recomendado: "claude-sonnet-4-20250514"
substitutos: "gemini-2.5-pro"
motivo: "backend com regra de negócio sem UI"
issue: "https://github.com/exemplo/ecommerce/issues/42"
---

# Service de Cálculo de Frete

## Objetivo

Criar service `FreteService` que calcula frete via API dos Correios com cache por CEP.

## Criterios de Aceite

- [x] Service `FreteService` em `app/Services/`
- [x] Método `calcular(string $cep, float $peso): FreteResult`
- [ ] Cache de 2h para consulta de mesmo CEP
- [x] Testes unitários com mock da API dos Correios
- [ ] Validação de CEP inválido retorna erro tratado

## Plano de Execucao

- [x] Criar Service com injeção de cache
- [x] Implementar chamada HTTP à API dos Correios
- [x] Criar testes unitários com mock
- [ ] Adicionar cache layer com TTL de 2h
- [ ] Tratar erro de CEP inválido

## Contador de Tentativas

| Criterio | Tentativas | Ultima tentativa | Status |
|----------|------------|------------------|--------|
| Service criado | 1 | 2026-07-25 14:15 | concluido |
| metodo calcular | 1 | 2026-07-25 14:30 | concluido |
| Cache 2h | 0 | — | pendente |
| Testes unitarios | 1 | 2026-07-25 15:00 | concluido |
| Validacao CEP | 0 | — | pendente |

## Estado Atual

> Ultima atualizacao: 2026-07-25 15:30

Service criado e testado. Cache pendente de implementação.

## Log de Evidencias

* 2026-07-25 14:15 - [Criar Service: `php spark make:service FreteService` → Service created successfully. (exit 0)]
* 2026-07-25 15:00 - [Testes: `php vendor/bin/phpunit tests/Services/FreteServiceTest.php` → OK (2 tests, 4 assertions) (exit 0)]
