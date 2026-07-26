# daisyUI - Guidelines

## Nao crie cores. Use os temas do daisyUI.

O daisyUI fornece um conjunto completo de tokens semanticos de cor (`primary`, `secondary`, `accent`, `neutral`, `base-100/200/300`, `info`, `success`, `warning`, `error`, e as variantes `-content`). **Use sempre esses tokens em vez de criar uma paleta propria.**

Proibido em views/componentes:
- Cores hex/rgb hardcoded (`#dc2626`, `rgb(220,38,38)`), seja em `style=` (proibido por si so, ver `tailwind.md`) ou em valor arbitrario do Tailwind (`bg-[#dc2626]`).
- Paleta padrao do Tailwind desacoplada do tema (`bg-red-500`, `text-blue-600`) — ela nao respeita troca de tema (light/dark) nem os overrides de tema do daisyUI.
- Uso direto de `var(--color-*)` dentro de `style=` inline nas views — se o token ja existe como classe Tailwind (`bg-primary`, `border-error`), use a classe. `var(--color-*)` so e aceitavel dentro do arquivo CSS de entrada do projeto, em `@layer components`.

## Prefira variantes nativas de estado

daisyUI ja resolve estados de erro/sucesso/foco nos proprios componentes. Use a variante nativa em vez de estilizar manualmente:
- `input input-error` / `select select-error` para campos com erro de validacao.
- `btn btn-primary`, `btn btn-error`, etc. para botoes.
- `alert alert-error`, `alert alert-success` para mensagens de feedback.

Exemplo (campo com erro condicional):
```php
class="input input-bordered <?= isset($errors['campo']) ? 'input-error' : '' ?>"
```

## Customizacao de tema: apenas sob demanda explicita

**Nao crie cores ou temas customizados por padrao.** O daisyUI ja fornece temas prontos — isso e suficiente para a esmagadora maioria do trabalho de UI.

Customizacao de paleta (ex.: um tema exclusivo de marca) so deve ser feita quando o usuario pedir explicitamente. Quando isso acontecer:
- Defina o tema via configuracao CSS-first do daisyUI (v5+), dentro do bloco `@plugin "daisyui" { themes: ... }` no arquivo CSS de entrada do projeto.
- Nao espalhe cores soltas pelas views para simular um tema — o tema inteiro vive naquele bloco central.

## Motivo

Cor hardcoded quebra a troca de tema (dark/light) e cria inconsistencia visual entre componentes que deveriam compartilhar a mesma paleta. Centralizar em tokens do daisyUI mantem o design system coerente e trocavel em um unico lugar.
