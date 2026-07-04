# Tailwind CSS - Guidelines

## Proibicao de style= inline

- **Nunca** usar o atributo `style=` em templates/views/componentes. Todo estilo deve vir de:
  1. Utilities do Tailwind aplicadas via `class=`.
  2. Uma classe de componente nomeada no arquivo CSS de entrada do projeto (dentro de `@layer components`, no Tailwind v4), quando o padrao se repete ou representa um componente com identidade visual propria.
- Excecao: codigo de fabrica de bibliotecas/frameworks (ex.: paginas de erro/debug padrao) nao esta sujeito a esta regra.

## Quando extrair para uma classe nomeada

Extraia para uma classe de componente (`@layer components` no Tailwind v4) quando:
- A mesma combinacao de utilities se repete em 3 ou mais lugares, **ou**
- O elemento representa um componente com identidade propria no design system do projeto.

Para uma variante de um componente existente (ex.: uma versao menor ou compacta de um card), crie um modificador nomeado (ex.: `.card--compact`) em vez de sobrepor com `style=` ou utilities soltas na tag.

## Sem valores arbitrarios de cor

Nao usar sintaxe de valor arbitrario para cor (`bg-[#dc2626]`, `text-[rgb(220,38,38)]`, etc.). Quando o projeto usa daisyUI, ver `daisyui.md` para a politica completa de cores/temas.

## Tailwind v4 e CSS-first

No Tailwind v4, prefira o modo CSS-first: configuracao (`@import`, `@theme`, `@plugin`) vive inteiramente no arquivo CSS de entrada do projeto. **Nao criar** `tailwind.config.js` ou qualquer arquivo de configuracao JS — isso e o padrao do Tailwind v3 e conflita com o modo CSS-first do v4.

## Responsividade

- Mobile-first: escrever a classe base para o menor breakpoint e usar prefixos (`sm:`, `md:`, `lg:`, `xl:`) para telas maiores, nunca o inverso.
