# CodeIgniter 4 Guidelines

- **Tipagem Estrita**: Sempre declare `declare(strict_types=1);` na primeira linha de todos os arquivos PHP criados ou modificados.
- **Tipagem de Retorno e Parametros**: Use tipagem explicita e coerente para todos os metodos e propriedades de classe.
- **Estrutura de Rotas**: Defina todas as rotas da aplicacao explicitamente em `app/Config/Routes.php`. Evite roteamento automatico para manter controle rigido sobre os endpoints publicos e paineis privados.

---

## Padroes de Arquitetura (Entities, Models, Services)

### 1. Entities (Objeto de Dominio)
- Representam uma unica linha da tabela como um objeto.
- **Nao** conhecem o banco de dados.
- Devem conter apenas **Mutators e Accessors** (getters e setters) para sanitizar ou formatar dados (ex: e-mail em minusculo, hash de senha automatico).

### 2. Models (Repositorio de Dados)
- Camada estrita de acesso a dados. **Nao** tomam decisoes de negocio.
- Devem conter apenas: configuracoes de tabela (nome, PK, `$allowedFields`), validacoes brutas e metodos de Query Builder customizados.
- **PROIBIDO** colocar logicas de disparo de e-mails, integracoes externas ou validacoes de regra de negocio nos Models.

### 3. Services (Camada de Regras de Negocio)
- Orquestram as Entities e os Models de forma isolada do protocolo HTTP.
- Registre as classes de servico em `app/Config/Services.php` utilizando a flag `$getShared` (Singletons) quando fizer sentido.
- Controllers devem ser enxutos, apenas recebendo parametros HTTP e chamando o Service correspondente.

---

## Praticas Essenciais de Desenvolvimento no CI4

### 1. View Cells (Componentizacao do Front-end)
- Use **View Cells** (`<?= view_cell('App\Cells\NomeCell') ?>`) para criar componentes de tela reaproveitaveis e independentes (ex: menus, widgets, alertas de status).
- Antes de duplicar markup entre views, verifique se ja existe (ou cabe criar) uma View Cell para o componente.
- Logica de interface complexa nao deve ficar no Controller principal nem inflar a View.

### 2. Filters (Middlewares)
- Regras de seguranca, CORS, autenticacao de sessao e isolamento multi-tenant devem ser executadas em **Filters** (`app/Config/Filters.php`).
- **Nunca** faca validacoes manuais de sessao repetitivas dentro de metodos de Controllers.

### 3. Events (Publish/Subscribe)
- Utilize o sistema de **Events** do CI4 (`Events::trigger('algo_aconteceu', ...)`) para desacoplar tarefas secundarias da logica de negocio principal dos Services.
- Tarefas como envio de e-mail ou notificacoes pos-acao devem ser ouvidas por Listeners, mantendo o Service principal focado na operacao primaria.

### 4. Migrations e Seeders
- Toda alteracao estrutural no banco deve possuir uma Migration Spark (`php spark make:migration`).
- A funcao `down()` de cada migration deve desfazer corretamente as alteracoes feitas em `up()`.
- Seeders devem ser utilizados para popular tabelas auxiliares ou dados ficticios (Faker) para testes.

### 5. Custom Spark Commands (CLI)
- Tarefas periodicas ou rotinas do sistema devem ser implementadas como comandos Spark customizados estendendo `BaseCommand`.
- Podem ser agendadas usando o scheduler do pacote **Tasks**, quando disponivel.

### 6. Custom Validation Rules
- Regras de validacao de negocio avancadas (ex: documentos, formatos especificos) devem ser implementadas em classes de validacao customizadas e injetadas no validador do framework.

---

## Banco de Dados

- Todas as alteracoes de schema devem ser feitas via migrations Spark (`php spark make:migration`).
- Crie indices em FKs e campos de busca/filtro frequente.

## Testes

- Use a suite PHPUnit integrada do CodeIgniter 4.
- Executar todos os testes: `vendor/bin/phpunit`.
- Executar teste especifico: `vendor/bin/phpunit caminho/do/Teste.php`.
- Filtrar por metodo: `vendor/bin/phpunit --filter nomeDoTeste`.

## Frontend (a preencher conforme o projeto)

- Definir aqui a stack de UI usada (ex: Tailwind + DaisyUI + HTMX, ou outra), padroes de componentizacao via View Cells e estados visuais (loading/empty/erro/sucesso).
