# Laravel Guidelines

- Use Laravel Boost quando disponivel antes de decisoes Laravel, Filament, Livewire, Tailwind ou testes.
- Siga `.ai/guidelines/core/environment.md`; neste projeto os comandos Laravel rodam no PHP local.
- Use `search-docs` para documentacao versionada antes de implementar APIs ou padroes.
- Crie arquivos Laravel com `php artisan make:* --no-interaction` quando aplicavel.
- Use `declare(strict_types=1)`, tipagem explicita e nomes descritivos.
- Se criar ou alterar migrations, rode `php artisan migrate` antes dos testes de aceite.
- Se criar ou alterar seeders, rode o seeder especifico ou `php artisan db:seed` antes dos testes de aceite.
- Rode `vendor/bin/pint --dirty --format agent` apos alterar PHP.

## Skills
- `laravel-best-practices`: use como referencia de padroes e boas praticas Laravel.
- `socialite-development`: use ao implementar autenticacao social (OAuth) com Laravel Socialite.
