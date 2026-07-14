# Atomic Design Guideline

Esta guideline so se aplica se `.ai/project.md` (secao `Stack`) tiver o bullet
`**Atomic Design:**` marcando o projeto como obrigatorio (ex: `- **Atomic
Design:** obrigatorio (View Cells)`). Se o projeto nao tiver esse bullet, esta
guideline nao se aplica e pode ser ignorada.

Quando aplicavel, siga ao pe da letra em qualquer task que toque frontend. O
mecanismo de componentizacao concreto (View Cells, componentes React,
Blade components, etc.) esta definido na guideline de stack do projeto (ex:
`.ai/guidelines/stacks/<stack>.md`) — esta guideline trata do processo, nao da
implementacao.

## Principio

Atomic Design e decomposicao total e bottom-up, nao uma tecnica de
deduplicacao aplicada so depois que o markup ja se repetiu em 2+ telas. Nao
espere surgir uma segunda ocorrencia para extrair um componente:

- Um `<label>` sozinho ja e um **Atom**.
- `label` + `input` juntos formam uma **Molecule**.
- Um cabecalho de pagina (titulo + subtitulo/badge + acao) e um **Organism** —
  nunca reescrito a mao por tela; toda pagina nova reaproveita (ou estende) o
  Organism ja existente, nunca duplica o layout na mao.
- Vale tanto para telas de **lista** quanto de **detalhe** — nao existe
  excecao para "tela de detalhe nao precisa de componente de cabecalho".

## No planejamento da task (`criar-task`)

Ao escrever o "Plano de Execucao" da task, liste explicitamente quais
componentes novos serao criados (por camada: Atoms/Molecules/Organisms/
Templates/Pages) e quais componentes existentes serao reaproveitados — nao
deixe implicito. Se a task tocar uma tela que ja existe, o Plano de Execucao
deve incluir um passo de auditoria rapida: "toda peca de UI tocada por esta
task que ainda nao e componente vira componente nesta task" (nao empurrar
para depois).

## Durante a execucao (`executar-task`)

Toda peca de UI nova nasce como componente (Atom/Molecule/Organism/Template),
nunca como HTML solto direto na view/pagina. Antes de escrever qualquer
trecho de markup, procure um componente existente reaproveitavel primeiro
(nao duplique layout/estilo na mao, nem "por ser pequeno").

## Gate final (obrigatorio antes de marcar a task como `done`)

Revise CADA arquivo de view/template tocado ou criado por esta task e
confirme que nao ha markup de UI solto fora da camada de componentizacao —
nem um `<label>`, nem um botao, nem um cabecalho de secao. Se encontrar algo
que deveria ser Atom/Molecule/Organism e nao e, extraia AGORA, nesta task,
antes de concluir — nao adie para uma task futura. Registre essa checagem no
Log de Evidencias (o que foi revisado, o que foi extraido).
