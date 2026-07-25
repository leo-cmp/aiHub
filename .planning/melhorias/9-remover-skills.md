# 9.1, 9.2, 9.3, 9.4, 9.5, 9.6 — Remoção de Skills do Core

**Categoria:** Skills — Remoções | **Prioridade:** 🔴/🟡/🟢 | **Esforço:** S (cada)
**Fonte:** DEEPSEEK

## Objetivo

Remover skills que não pertencem ao core de engenharia de software. Seis skills saem: 3 de imagem/notificação, 3 redundantes ou de nicho extremo.

## Skills a Remover

| # | Skill | Prioridade | Motivo |
|---|-------|-----------|--------|
| 9.1 | `ai-image-generation` | 🔴 | Zero relação com engenharia de software. Ferramenta de imagem |
| 9.2 | `nano-banana-2` | 🔴 | Mesmo caso — geração de imagem |
| 9.3 | `iagentbot` (notify-telegram) | 🔴 | Telegram não funcionou como esperado. Será reformulado depois |
| 9.4 | `find-skills` | 🟡 | Meta-descoberta desnecessária. Usuário usa atalho direto |
| 9.5 | `socialite-development` | 🟡 | Nicho extremo (OAuth Laravel). Quem usa instala por fora |
| 9.6 | `web-design-guidelines` | 🟢 | Overlap com `frontend-design` + `daisyui`. Redundante no core |

## Especificação

Para cada skill:

1. **Remover diretório:** `rm -rf src/.agents/skills/<nome-da-skill>/`
2. **Verificar referências:** `grep -r "<nome-da-skill>" src/` e remover menções em:
   - `src/.ai/roles/*.md` (seções "Skills")
   - `src/.ai/guidelines/stacks/*.md` (seções "Skills")
   - `src/AGENTS.md` (se houver menção)
3. **Atualizar `available_skills`:** estas skills são listadas no system prompt do bootloader. Após remoção dos diretórios, não serão mais carregadas. Verificar se o bootloader do aiHub (fora do src/) referencia estas skills — se sim, remover.

### Referências encontradas para verificar:

| Skill | Referenciada em |
|-------|-----------------|
| `web-design-guidelines` | Confirmar se está em algum role |
| `socialite-development` | `src/.ai/guidelines/stacks/laravel.md:14` |
| `iagentbot` | `src/.ai/roles/technical-lead.md:32`, `backend-engineer.md:29`, `fullstack-engineer.md:31` |

### Pós-remoção

Se `iagentbot` for removido, roles que o referenciam perdem a skill de notificação. Substituir por menção genérica:

```markdown
- Notifique o usuario em tarefas longas (use a ferramenta de mensagem disponivel no ambiente).
```

## Arquivos Afetados

- `src/.agents/skills/ai-image-generation/`: REMOVER diretório
- `src/.agents/skills/nano-banana-2/`: REMOVER diretório
- `src/.agents/skills/iagentbot/`: REMOVER diretório
- `src/.agents/skills/find-skills/`: REMOVER diretório
- `src/.agents/skills/socialite-development/`: REMOVER diretório
- `src/.agents/skills/web-design-guidelines/`: REMOVER diretório
- `src/.ai/guidelines/stacks/laravel.md`: remover referência a `socialite-development`
- `src/.ai/roles/technical-lead.md`: remover/substituir referência a `iagentbot`
- `src/.ai/roles/backend-engineer.md`: remover/substituir referência a `iagentbot`
- `src/.ai/roles/fullstack-engineer.md`: remover/substituir referência a `iagentbot`

## Critérios de Aceite

- [ ] 6 diretórios de skills removidos de `src/.agents/skills/`
- [ ] `grep -r "ai-image-generation\|nano-banana-2\|iagentbot\|find-skills\|socialite-development\|web-design-guidelines" src/` retorna vazio (ou apenas menções históricas em docs)
- [ ] Roles que referiam `iagentbot` têm texto substituto
- [ ] `laravel.md` não referencia `socialite-development`
- [ ] Sistema continua funcional — skills restantes carregam normalmente
