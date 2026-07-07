# Astro + PHP - Performance Guidelines

Manual de otimizacao e performance de alta performance para agentes de IA.

Este documento serve como diretriz obrigatoria para desenvolvimento, manutencao e otimizacao de projetos Astro com backend PHP. Todas as praticas abaixo foram validadas para buscar nota maxima de 100/100 em todas as categorias do Google PageSpeed Insights: Desempenho, Acessibilidade, Melhores Praticas e SEO.

---

## 1. Otimizacao e entrega responsiva de imagens

Para evitar alertas de "Melhorar a entrega de imagens" relacionados a LCP e dimensoes incorretas no mobile/desktop, siga as regras abaixo.

### A. Geracao de miniaturas no upload

Sempre que uma imagem for processada no servidor, seja em upload ou rotinas de manutencao, o sistema deve gerar duas versoes em formato WebP com 75% de qualidade de compressao:

1. **Imagem principal:** largura maxima de 1200px, proporcional a altura.
2. **Miniatura (thumbnail):** largura maxima de 600px, proporcional a altura, salva com o sufixo `-thumb.webp`.

### B. Uso de tags `<picture>` no HTML do Astro

Nunca utilize apenas a tag `<img>` com `srcset` baseado em largura (`w`) para imagens criticas em layouts responsivos. Telas mobile de alta densidade, como Retina/DPR 3x, podem forcar o download da imagem de desktop de 1200px.

Use a tag HTML5 `<picture>` com media queries para obrigar dispositivos moveis a carregar a miniatura fisica de 600px.

```astro
<picture>
  <!-- Dispositivos moveis com largura de tela de ate 768px carregam a miniatura -->
  <source
    media="(max-width: 768px)"
    srcset={`${imageSrc.replace(/\.webp$/, '-thumb.webp')}?v=2`}
  />
  <!-- Desktop e telas maiores carregam a imagem principal -->
  <img
    src={`${imageSrc}?v=2`}
    alt={title}
    fetchpriority="high"
    width="1200"
    height="675"
  />
</picture>
```

### C. Parametro de cache-busting (`?v=N`)

Sempre adicione parametros de versao (`?v=2` ou timestamps) nas URLs das imagens em templates do Astro. Isso forca redes de borda, como Cloudflare, e navegadores a ignorarem copias obsoletas, incluindo antigos erros 404 de arquivos que ainda nao tinham sido gerados.

---

## 2. Eliminacao de recursos que impedem a renderizacao

### A. Inlining de CSS

Para sites institucionais ou blogs com arquivos de estilo leves, o carregamento de arquivos `.css` externos bloqueia a renderizacao e atrasa o First Contentful Paint (FCP).

Configure o compilador do Astro para embutir todo o CSS compilado diretamente no HTML final.

Arquivo: `astro.config.mjs`

```javascript
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://dizit.com.br',
  integrations: [sitemap()],
  build: {
    inlineStylesheets: 'always', // Remove tags <link rel="stylesheet"> externas
  },
});
```

### B. Scripts de terceiros assincronos

Scripts externos pesados, como redes de anuncios e tags de analytics, devem ser carregados de forma assincrona (`async`).

Se o script precisar disparar funcoes no corpo (`body`) da pagina, implemente loops de verificacao segura para evitar erros de execucao, como `ReferenceError: X is not defined`.

```html
<script is:inline>
  (function() {
    function run() {
      if (window.nomeDoScript) {
        window.nomeDoScript.iniciar({ parametro: 'valor' });
      } else {
        setTimeout(run, 100); // Aguarda ate que o script assincrono carregue no head
      }
    }
    run();
  })();
</script>
```

---

## 3. Acessibilidade de contraste de cores (WCAG AA)

Todos os elementos de texto devem atender estritamente aos requisitos minimos de contraste de cores definidos pelas diretrizes de acessibilidade:

- Taxa de contraste maior ou igual a 4.5:1 para texto normal.
- Taxa de contraste maior ou igual a 3.0:1 para textos grandes.

### A. Design tokens de cores seguros

Utilize uma paleta de cores balanceada. Se o site oferece suporte a tema claro e escuro, ajuste os tokens de cor cinza (`--muted` e `--meta`) de forma independente.

**Tema escuro (background `#313338`):**

- `--muted` deve ser no minimo `#b5bac1` (contraste 5.7:1).
- `--meta` deve ser no minimo `#a2a7b1` (contraste 4.6:1).

**Tema claro (background `#ffffff`):**

- `--muted` deve ser no maximo `#5c6067` (contraste 6.2:1).
- `--meta` deve ser no maximo `#6a6f77` (contraste 5.3:1).

### B. Textos de destaque e logotipos

Cuidado com as cores da identidade visual (`--accent`, azul, etc.). Se a cor de destaque da marca nao possuir contraste suficiente sobre fundos escuros, mude a cor do logotipo textual do rodape para `var(--fg-2)` e aplique a cor de destaque apenas em elementos puramente esteticos, como o ponto final da marca (`.dot`), que nao sofrem restricoes de leitura.

---

## 4. Politicas de cache de longo prazo e compressao (`.htaccess`)

Para garantir que os recursos estaticos sejam armazenados de forma eficiente no navegador de retorno, utilize configuracoes robustas que unam `mod_expires` e `mod_headers`, cobrindo servidores Hostinger com modulos desativados.

Arquivo: `public/.htaccess`, copiado automaticamente para a pasta de build final.

```apache
# 1. Habilitar compressao GZIP para texto/CSS/JS
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain text/html text/xml text/css
    AddOutputFilterByType DEFLATE application/xml application/xhtml+xml application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript application/x-javascript image/svg+xml
</IfModule>

# 2. Caching de Recursos Estaticos (1 Ano) - Modulo Principal
<IfModule mod_expires.c>
    ExpiresEngine On
    ExpiresDefault "access plus 1 month"
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/webp "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType font/woff2 "access plus 1 year"
</IfModule>

# 3. Fallback via mod_headers (Garante funcionamento se mod_expires estiver inativo)
<IfModule mod_headers.c>
    <FilesMatch "\.(css|js|ico|pdf|jpg|jpeg|png|gif|webp|svg|woff|woff2|ttf|otf)$">
        Header set Cache-Control "max-age=31536000, public"
    </FilesMatch>
</IfModule>
```

---

## 5. Integracao com CDN e proxy reverso (Cloudflare)

Para evitar que configuracoes de proxy intermediario anulem os esforcos locais:

1. **Configuracao de TTL de cache do navegador:** no painel da Cloudflare, em `Caching -> Configuration`, a opcao **Browser Cache TTL** deve estar configurada como **Respect Existing Headers**. Caso contrario, o proxy pode forcar a expiracao padrao de 7 dias e desrespeitar as diretrizes do `.htaccess`.
2. **Ciclo de atualizacoes (deploy):** apos qualquer compilacao do Astro ou reotimizacao fisica de imagens no servidor, e obrigatorio executar **Purge Everything** no painel de cache do Cloudflare e limpar o cache interno do LiteSpeed/Hostinger para que navegadores recebam imediatamente os arquivos e cabecalhos novos.
