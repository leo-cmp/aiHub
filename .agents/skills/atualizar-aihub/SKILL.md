---
name: atualizar-aihub
description: Atualiza o aiHub (submodulo git) para a versao mais recente. Faz fetch, checkout da tag mais recente, e reexecuta install.sh.
---

# Atualizar aiHub

## Fluxo

1. **Verificar status:** confirme que nao ha alteracoes locais no submodulo:
   ```bash
   git -C .aihub status --porcelain
   ```
   Se houver alteracoes NAO comitadas, pergunte ao usuario se deseja descarta-las ou fazer backup.

2. **Fetch:**
   ```bash
   git -C .aihub fetch origin --tags
   ```

3. **Encontrar versao mais recente:**
   ```bash
   git -C .aihub tag --sort=-version:refname | head -1
   ```

4. **Atualizar:**
   ```bash
   git -C .aihub checkout $(git -C .aihub tag --sort=-version:refname | head -1)
   ```

5. **Reinstalar:**
   ```bash
   .aihub/scripts/install.sh
   ```

6. **Reportar:**
   - Versao anterior: X.Y.Z
   - Versao atual: X.Y.Z
   - Alteracoes: (mostre `git -C .aihub log --oneline versao_anterior..HEAD`)

## Seguranca

- Se houver alteracoes locais no submodulo, PARE e pergunte.
- Nao execute `git reset --hard` sem confirmacao explicita.
- Se a atualizacao falhar, informe o usuario e nao tente corrigir automaticamente.
