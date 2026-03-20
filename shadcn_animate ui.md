# UX - Proyecto de test con animate-ui

## Descripcion del proyecto

Proyecto para testear la libreria [animate-ui](https://animate-ui.com/) instalando componentes animados via el MCP de shadcn y construyendo una web con ellos. Desplegado en **https://ux.desarrolloappsur.es** (hosting SiteGround).

## Stack tecnologico

| Capa | Tecnologia | Version | Motivo |
|---|---|---|---|
| Backend | Laravel | 12 | Framework PHP, hosting compartido |
| Bridge | Inertia.js | 2.x | Conecta Laravel con React sin API REST |
| Frontend | React | 19 | Requerido por animate-ui |
| Animaciones | Framer Motion | 12.x | Requerido por animate-ui |
| CSS | Tailwind CSS | 4 | Requerido por shadcn/animate-ui |
| Build | Vite | 6 | Bundler (con laravel-vite-plugin) |
| Componentes | shadcn/ui + animate-ui | latest | Sistema de componentes con animaciones |
| Iconos | Lucide React | latest | Iconos SVG |

**Por que React si es un proyecto PHP?** animate-ui solo funciona con React. Se usa Laravel + Inertia.js como puente: Laravel maneja rutas/backend y React renderiza el frontend.

## Estructura del proyecto

```
ux/
├── .claude/.mcp.json        # Config MCP para Claude Code CLI
├── .vscode/mcp.json         # Config MCP para VS Code
├── app/                     # Laravel backend
│   ├── Http/
│   │   ├── Controllers/
│   │   └── Middleware/
│   │       └── HandleInertiaRequests.php  # Middleware Inertia
│   ├── Models/
│   └── Providers/
├── bootstrap/app.php        # Bootstrap Laravel (registra middleware Inertia)
├── config/                  # Configuracion Laravel
├── database/                # Migraciones y seeders
├── resources/
│   ├── css/app.css          # Entry CSS: @import "tailwindcss"
│   ├── js/
│   │   ├── app.jsx          # Entry React/Inertia
│   │   ├── Pages/           # Paginas Inertia (cada una es una ruta)
│   │   │   └── Calendar.jsx # Calendario animado
│   │   ├── components/      # Componentes shadcn/animate-ui (se crean al instalar)
│   │   │   └── ui/          # Componentes UI base
│   │   └── lib/
│   │       └── utils.js     # Utilidad cn() para clases CSS
│   └── views/
│       └── app.blade.php    # Layout Blade con directivas Inertia/Vite
├── routes/web.php           # Rutas Laravel -> Inertia::render("Page")
├── components.json          # Config shadcn + registros animate-ui
├── package.json             # Dependencias npm
├── composer.json            # Dependencias PHP
├── vite.config.js           # Config Vite
└── public/
    └── build/               # Assets compilados (generados por npm run build)
```

## MCP de shadcn - Instalacion y acceso

### Como se instalo

```bash
# Instala la config MCP para Claude Code CLI
npx shadcn@latest mcp init --client claude

# Esto crea .claude/.mcp.json automaticamente
```

Para VS Code, se creo manualmente `.vscode/mcp.json`.

### Ficheros de configuracion MCP

**.claude/.mcp.json** (Claude Code CLI):
```json
{
  "mcpServers": {
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    }
  }
}
```

**.vscode/mcp.json** (VS Code):
```json
{
  "servers": {
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    }
  }
}
```

### Como acceder al MCP

**PREREQUISITO**: Para que el MCP detecte el registro `@animate-ui`, **DEBE existir `components.json`** en la raiz del proyecto con la seccion `registries` configurada (ver seccion "Registro animate-ui - Configuracion" mas abajo). Sin este fichero, el MCP solo detectara el registro `@shadcn` por defecto y NO podra buscar/instalar componentes de animate-ui.

Las herramientas del MCP de shadcn pueden no aparecer como tools directos (`mcp__shadcn__*`). En ese caso se accede via JSON-RPC por CLI:

```bash
# Listar herramientas disponibles
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | npx shadcn@latest mcp

# Llamar una herramienta (ejemplo: listar registros)
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"get_project_registries","arguments":{}}}' | npx shadcn@latest mcp

# Buscar componentes en animate-ui
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"search_items_in_registries","arguments":{"registries":["@animate-ui"],"query":"button"}}}' | npx shadcn@latest mcp

# Listar componentes de un registro
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"list_items_in_registries","arguments":{"registries":["@animate-ui"],"limit":50}}}' | npx shadcn@latest mcp

# Ver codigo de un componente
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"view_items_in_registries","arguments":{"items":["@animate-ui/radix-tabs"]}}}' | npx shadcn@latest mcp

# Ver ejemplos de uso
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"get_item_examples_from_registries","arguments":{"registries":["@animate-ui"],"query":"tabs-demo"}}}' | npx shadcn@latest mcp

# Obtener comando de instalacion
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"get_add_command_for_items","arguments":{"items":["@animate-ui/radix-tabs"]}}}' | npx shadcn@latest mcp
```

### Herramientas MCP disponibles

| Herramienta | Descripcion |
|---|---|
| `get_project_registries` | Ver registros configurados en components.json |
| `list_items_in_registries` | Listar componentes de un registro (paginado) |
| `search_items_in_registries` | Buscar componentes por nombre (fuzzy match) |
| `view_items_in_registries` | Ver codigo fuente de un componente |
| `get_item_examples_from_registries` | Ver demos/ejemplos de uso |
| `get_add_command_for_items` | Obtener el comando `npx shadcn@latest add` |
| `get_audit_checklist` | Verificar instalacion correcta |

## Registro animate-ui - Configuracion

**IMPORTANTE**: Este fichero `components.json` es OBLIGATORIO en la raiz del proyecto. Sin el:
- El MCP de shadcn NO detecta el registro `@animate-ui`
- `npx shadcn@latest add @animate-ui/...` NO funciona
- Solo se podran instalar componentes base de shadcn

Si el fichero no existe, crearlo manualmente con este contenido:

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": false,
  "tsx": false,
  "tailwind": {
    "config": "",
    "css": "resources/css/app.css",
    "baseColor": "zinc",
    "cssVariables": true
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  },
  "registries": {
    "@animate-ui": "https://animate-ui.com/r/{name}.json"
  }
}
```

**Checklist para que animate-ui funcione (en orden):**
1. Tener `components.json` en la raiz con `registries: { "@animate-ui": "https://animate-ui.com/r/{name}.json" }`
2. Tener `jsconfig.json` en la raiz (ver mas abajo) - sin el, shadcn CLI falla
3. Tener las dependencias npm instaladas: `react`, `framer-motion`, `motion`, `tailwindcss`, `class-variance-authority`, `clsx`, `tailwind-merge`
4. Tener la config MCP en `.claude/.mcp.json` o `.vscode/mcp.json`
5. Despues de instalar, SIEMPRE mover ficheros de la raiz a `resources/js/` (ver "Problemas conocidos")

**Notas importantes:**
- `tsx: false` porque el proyecto usa `.jsx` (JavaScript), no TypeScript
- `rsc: false` porque NO usamos React Server Components (es Inertia, no Next.js)
- El alias `@` apunta a `resources/js/` (configurado en vite.config.js)
- Los componentes shadcn se instalan en `resources/js/components/ui/`
- Los componentes animate-ui se instalan en `resources/js/components/animate-ui/`
- **IMPORTANTE**: Requiere `jsconfig.json` en la raiz para resolver alias `@/`

### jsconfig.json (requerido por shadcn CLI)

```json
{
    "compilerOptions": {
        "baseUrl": ".",
        "paths": {
            "@/*": ["resources/js/*"]
        }
    },
    "include": ["resources/js/**/*"]
}
```

Sin este fichero, `npx shadcn@latest add` falla con "Failed to load jsconfig.json".

### Instalar componentes

```bash
# Instalar componente de shadcn
npx shadcn@latest add button

# Instalar componente de animate-ui (usar nombre completo del registro)
npx shadcn@latest add @animate-ui/components-buttons-ripple

# Instalar multiples
npx shadcn@latest add calendar button card @animate-ui/components-buttons-ripple @animate-ui/components-backgrounds-gradient
```

### Problemas conocidos al instalar animate-ui

1. **Los componentes animate-ui se instalan en la raiz**: `npx shadcn@latest add @animate-ui/...` crea carpetas `components/`, `lib/` y `hooks/` en la raiz del proyecto (fuera de `resources/js/`). **SIEMPRE hay que moverlas manualmente** despues de instalar:
   ```bash
   # Mover componentes (ajustar rutas segun lo instalado)
   mv components/animate-ui/* resources/js/components/animate-ui/
   # Mover libs si se crean
   mv lib/get-strict-context.jsx resources/js/lib/get-strict-context.jsx
   # Mover hooks si se crean
   mv hooks/use-controlled-state.jsx resources/js/hooks/use-controlled-state.jsx
   # Limpiar carpetas raiz sobrantes
   rm -rf components lib hooks
   ```
   **Importante**: Verificar SIEMPRE con `ls` que no queden carpetas `components/`, `lib/` o `hooks/` en la raiz despues de instalar cualquier componente de animate-ui.

2. **Import incorrecto en ripple.jsx**: El fichero `components/animate-ui/components/buttons/ripple.jsx` importa `buttonVariants` desde `primitives/buttons/button` pero ese export esta en `components/buttons/button`. Hay que corregir:
   ```js
   // INCORRECTO (como viene instalado):
   import { buttonVariants } from '@/components/animate-ui/primitives/buttons/button';
   // CORRECTO:
   import { buttonVariants } from '@/components/animate-ui/components/buttons/button';
   ```

3. **animate-ui usa `motion/react`**: Los componentes importan desde `motion/react` (paquete `motion`), no desde `framer-motion`. Ambos paquetes deben estar instalados. `motion` se instala automaticamente como dependencia.

4. **CSS variables de shadcn**: Los componentes shadcn (calendar, button, card) necesitan CSS variables (`--primary`, `--background`, etc.) definidas en `resources/css/app.css`. Sin ellas los componentes se renderizan sin estilos. Ver la seccion de CSS de este documento.

### Categorias principales de animate-ui

- **Radix UI animados**: accordion, dialog, dropdown-menu, popover, sheet, sidebar, tabs, tooltip
- **Botones**: ripple, liquid, flip, copy
- **Backgrounds**: bubble, fireworks, gradient, gravity-stars, hexagon, stars
- **Transiciones**: fade, slide, scale, rotate, blur, spring
- **Texto**: counter, morphing-text, typing, writing
- **Comunidad**: flip-card, motion-carousel, notification-list, playful-todolist

## Configuracion Inertia.js (el puente Laravel-React)

### Entry point React (`resources/js/app.jsx`)

```jsx
import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";

createInertiaApp({
    resolve: (name) => {
        const pages = import.meta.glob("./Pages/**/*.jsx", { eager: true });
        return pages[`./Pages/${name}.jsx`];
    },
    setup({ el, App, props }) {
        createRoot(el).render(<App {...props} />);
    },
});
```

### Layout Blade (`resources/views/app.blade.php`)

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>UX Calendar</title>
    @viteReactRefresh
    @vite(["resources/css/app.css", "resources/js/app.jsx"])
    @inertiaHead
</head>
<body class="bg-zinc-100 min-h-screen flex items-center justify-center">
    @inertia
</body>
</html>
```

### Rutas (`routes/web.php`)

```php
<?php
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get("/", function () {
    return Inertia::render("Calendar");
});
```

Cada `Inertia::render("NombrePagina")` busca `resources/js/Pages/NombrePagina.jsx`.

### Middleware (`bootstrap/app.php`)

```php
->withMiddleware(function (Middleware $middleware): void {
    $middleware->web(append: [
        \App\Http\Middleware\HandleInertiaRequests::class,
    ]);
})
```

## Deploy a SiteGround

### Datos del servidor

- **Host SSH**: `ssh.desarrolloappsur.es`
- **Puerto**: `18765`
- **Usuario**: `u381-fzmnkcsjk0gq`
- **Clave SSH**: `~/.ssh/siteground_chatly`
- **Ruta proyecto**: `/home/customer/www/ux.desarrolloappsur.es`
- **URL publica**: `https://ux.desarrolloappsur.es`

### Conexion SSH

```bash
ssh -o ConnectTimeout=10 -i ~/.ssh/siteground_chatly -p 18765 u381-fzmnkcsjk0gq@ssh.desarrolloappsur.es
```

### Truco public_html en SiteGround

SiteGround sirve desde `public_html/` pero Laravel usa `public/`. Se resuelve con un symlink:

```bash
ln -s public public_html
```

### Flujo de deploy

1. **Editar en local** (resources/js/, resources/css/, etc.)
2. **Compilar localmente**: `npm run build` (genera `public/build/`)
3. **Subir build al servidor**:
```bash
scp -r -o ConnectTimeout=10 -i ~/.ssh/siteground_chatly -P 18765 \
  "public/build" \
  u381-fzmnkcsjk0gq@ssh.desarrolloappsur.es:/home/customer/www/ux.desarrolloappsur.es/public/
```
4. **Limpiar cache** (si se cambian rutas/vistas/config):
```bash
ssh -o ConnectTimeout=10 -i ~/.ssh/siteground_chatly -p 18765 \
  u381-fzmnkcsjk0gq@ssh.desarrolloappsur.es \
  "cd /home/customer/www/ux.desarrolloappsur.es && php artisan view:clear && php artisan cache:clear"
```

**IMPORTANTE**: No se puede hacer `npm run build` en el servidor (SiteGround shared hosting se queda sin memoria con WebAssembly). Siempre compilar en local.

### Subir ficheros fuente al servidor

Si se modifican ficheros PHP, Blade o JS fuente:

```bash
# Ejemplo: subir un fichero especifico
scp -o ConnectTimeout=10 -i ~/.ssh/siteground_chatly -P 18765 \
  "resources/js/Pages/Calendar.jsx" \
  u381-fzmnkcsjk0gq@ssh.desarrolloappsur.es:/home/customer/www/ux.desarrolloappsur.es/resources/js/Pages/Calendar.jsx

# Ejemplo: subir un directorio entero
scp -r -o ConnectTimeout=10 -i ~/.ssh/siteground_chatly -P 18765 \
  "resources/js/components" \
  u381-fzmnkcsjk0gq@ssh.desarrolloappsur.es:/home/customer/www/ux.desarrolloappsur.es/resources/js/
```

## Compatibilidad de versiones

Las versiones en `package.json` local difieren del servidor por compatibilidad de build:

| Paquete | Local | Servidor | Motivo |
|---|---|---|---|
| vite | ^6.4.1 | ^7.0.7 | v7 funciona en servidor, local usa v6 porque plugin-react@4 no soporta v8 |
| @vitejs/plugin-react | ^4.7.0 | ^6.0.1 | v6 requiere vite@8, local usa v4 compatible con vite@6 |
| laravel-vite-plugin | ^1.3.0 | ^2.0.0 | Alineado con version de vite |

Esto NO afecta al resultado: el build se hace siempre en local y el output es identico.

## Comandos utiles

```bash
# Desarrollo local
npm run dev          # Servidor Vite con HMR
npm run build        # Build produccion

# Instalar componentes
npx shadcn@latest add <componente>                  # shadcn base
npx shadcn@latest add @animate-ui/<componente>      # animate-ui

# Git
git status
git add -A && git commit -m "descripcion"

# Deploy rapido (build + subir)
npm run build && scp -r -o ConnectTimeout=10 -i ~/.ssh/siteground_chatly -P 18765 "public/build" u381-fzmnkcsjk0gq@ssh.desarrolloappsur.es:/home/customer/www/ux.desarrolloappsur.es/public/
```

## CSS Variables (shadcn theme)

Los componentes shadcn requieren CSS variables para colores, bordes y radios. Estan definidas en `resources/css/app.css`. El fichero debe incluir:

1. `@import "tailwindcss"` - base de Tailwind
2. `@custom-variant dark` - soporte dark mode
3. `@theme inline` - mapping de CSS vars a colores Tailwind (--color-primary: var(--primary), etc.)
4. `:root` - valores reales de las variables en formato oklch (tema zinc)
5. `@layer base` - aplica border-border y bg-background/text-foreground al body

Sin estas variables los componentes shadcn se renderizan sin estilos visibles.

## Componentes instalados actualmente

### shadcn/ui (en `resources/js/components/ui/`)
- `calendar.jsx` - Calendario basado en react-day-picker con dropdowns para mes/año
- `button.jsx` - Boton base con variantes (default, destructive, outline, secondary, ghost, link)
- `card.jsx` - Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter

### animate-ui (en `resources/js/components/animate-ui/`)
- `components/backgrounds/gradient.jsx` - Fondo con gradiente animado (loop infinito)
- `components/buttons/ripple.jsx` - Boton con efecto ripple al hacer click
- `components/buttons/button.jsx` - Boton base animate-ui con buttonVariants
- `components/radix/dialog.jsx` - Dialog animado (styled, usa primitiva radix/dialog)
- `primitives/buttons/button.jsx` - Primitiva de boton con whileTap/whileHover
- `primitives/buttons/ripple.jsx` - Primitiva del efecto ripple
- `primitives/radix/dialog.jsx` - Primitiva de dialog con animacion 3D (perspective + rotate)
- `primitives/animate/slot.jsx` - Slot para composicion
- `primitives/animate/tooltip.jsx` - Tooltip animado con floating-ui
- `primitives/effects/click.jsx` - Efecto click (ring, ripple, crosshair, burst, particles)
- `primitives/effects/highlight.jsx` - Efecto highlight para items activos

### Utilidades (en `resources/js/lib/`)
- `utils.js` - cn() para merge de clases Tailwind
- `get-strict-context.jsx` - Context helper para animate-ui

### Hooks (en `resources/js/hooks/`)
- `use-controlled-state.jsx` - Hook para estado controlado/no-controlado (usado por dialog)
