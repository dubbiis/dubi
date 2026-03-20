# CLAUDE.md — Dubi (Portfolio + CRM personal)

> Documento vivo. Actualizar en cada cambio relevante de arquitectura, rutas, modelos o configuración.
> Este archivo debe ser suficiente para que otra IA continúe el proyecto sin contexto previo.

---

## Descripción del Proyecto

Portfolio personal + CRM propio para gestión de clientes, leads, proyectos y finanzas.

**Fases:**
1. **Portfolio** — Página pública que muestra proyectos, servicios y proceso de trabajo. Con formulario de contacto.
2. **Landings** — Una por sector (hostelería, talleres mecánicos, etc.) para captar leads. Todos los formularios alimentan el CRM.
3. **CRM** — Área privada con login. Gestión completa: leads → clientes → proyectos → pagos → gastos personales.

---

## Stack Técnico

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Backend | Laravel | 13.x (framework v13.1.1) |
| Frontend | React + Inertia.js | React 19, Inertia 2.x |
| CSS | Tailwind CSS | v4 (@tailwindcss/vite) |
| Componentes | shadcn/ui + animate-ui | registry @animate-ui |
| Animaciones | framer-motion / motion | última |
| Build | Vite + @vitejs/plugin-react | — |
| Auth | Laravel Breeze (pendiente, área CRM) | — |
| Deploy | Docker + EasyPanel | — |
| BD producción | MySQL 8.x | — |
| BD local | SQLite | — |
| Node | 22.x | — |
| PHP | 8.4 | — |

---

## Arquitectura

```
dubi.es/
├── app/
│   ├── Http/
│   │   ├── Controllers/      # Controladores (públicos y CRM separados)
│   │   └── Middleware/
│   │       └── HandleInertiaRequests.php   # Middleware Inertia (compartir datos globales)
│   └── Models/
├── resources/
│   ├── css/app.css           # Tailwind 4 + variables CSS shadcn
│   ├── js/
│   │   ├── app.jsx           # Entry point Inertia
│   │   ├── Pages/
│   │   │   ├── Portfolio/    # Rutas públicas del portfolio
│   │   │   ├── Landings/     # Rutas públicas de landings por sector
│   │   │   └── Crm/          # Área privada (con auth)
│   │   ├── components/
│   │   │   └── ui/           # Componentes shadcn/animate-ui instalados aquí
│   │   ├── lib/
│   │   │   └── utils.js      # cn() helper (clsx + tailwind-merge)
│   │   └── hooks/
│   └── views/
│       └── app.blade.php     # Layout único para Inertia
├── routes/
│   └── web.php               # Rutas públicas + grupo /crm con auth
├── docker/
│   ├── nginx.conf
│   └── supervisord.conf
├── Dockerfile
├── components.json           # Config shadcn/ui + registro @animate-ui
└── vite.config.js
```

### Flujo de una petición
```
Browser → Nginx (docker) → PHP-FPM → Laravel Router → Controller → Inertia::render()
       ↓
       React (Inertia client) hidrata el componente de la Page correspondiente
```

---

## Rutas

### Públicas
| Método | URI | Page React | Descripción |
|--------|-----|-----------|-------------|
| GET | `/` | `Portfolio/Index` | Portfolio principal |
| GET | `/landings/{sector}` | `Landings/{Sector}` | Landings por sector (pendiente) |
| POST | `/contacto` | — | Formulario de contacto (pendiente) |

### CRM (privada — con auth)
| Método | URI | Page React | Descripción |
|--------|-----|-----------|-------------|
| GET | `/crm` | `Crm/Dashboard` | Dashboard CRM (pendiente) |
| GET | `/login` | — | Login (pendiente con Breeze) |

---

## Modelo de Datos

> Pendiente de diseñar. Se añadirá cuando empiece el CRM.

Entidades planificadas: `Lead`, `Client`, `Project`, `Invoice`, `Payment`, `Expense`

---

## Variables de Entorno

### Local (`.env`) — SQLite
```
APP_NAME=Dubi
APP_ENV=local
APP_DEBUG=true
DB_CONNECTION=sqlite
APP_LOCALE=es
```

### Producción — configurar en EasyPanel
```
APP_ENV=production
APP_DEBUG=false
APP_URL=https://dubi.es
DB_CONNECTION=mysql
DB_HOST=<host-interno-easypanel>
DB_DATABASE=dubi_db
DB_USERNAME=dubi
DB_PASSWORD=<ver DATOS-CONEXION.md>
```

---

## Comandos Frecuentes

```bash
# Desarrollo local
npm run dev          # Vite dev server
php artisan serve    # Laravel dev server

# Instalar componente shadcn/ui
npx shadcn@latest add button

# Instalar componente animate-ui (via MCP o CLI)
npx shadcn@latest add @animate-ui/<nombre>

# Build para producción
npm run build

# Caché Laravel (producción)
php artisan config:cache && php artisan route:cache && php artisan view:cache

# Migrations
php artisan migrate
```

---

## Configuración shadcn/ui + animate-ui

- `components.json` en la raíz define el registro `@animate-ui: https://animate-ui.com/r/{name}.json`
- El MCP de shadcn está configurado en `.claude/.mcp.json`
- Los alias `@/` apuntan a `resources/js/`
- Los componentes instalados van a `resources/js/components/ui/`

---

## Deploy — EasyPanel

- **Webhook:** `http://185.158.132.130:3000/api/deploy/6fde678f7d7dc52d2ef817c03fc4c668d8250ef1f0899e30`
- **Rama:** `master`
- **Flujo:** `git push origin master` → webhook → EasyPanel reconstruye Dockerfile → deploy automático
- **Stack Docker:** Nginx + PHP-FPM (supervisor) en imagen Alpine
- **Sin GitHub Actions.** Solo webhook.

---

## Trampas Conocidas

### 1. animate-ui se instala en la raíz del proyecto
El CLI de shadcn instala los componentes de `@animate-ui` en la raíz (`/components/ui/`) en lugar de en `resources/js/components/ui/`. Hay que moverlos manualmente después de cada instalación.

### 2. Tailwind 4 — no hay tailwind.config.js
Con Tailwind v4 + `@tailwindcss/vite`, la configuración va en el CSS (`app.css`) con `@theme`. No existe `tailwind.config.js`.

### 3. app.js → app.jsx
El entry point de Vite debe ser `.jsx`, no `.js`. El `vite.config.js` apunta a `resources/js/app.jsx`.

### 4. Middleware Inertia registrado en bootstrap/app.php
El `HandleInertiaRequests` se registra como middleware web en `bootstrap/app.php`, no en `Kernel.php` (que ya no existe en Laravel 11+).

---

## Diseño Responsive — Requisito Obligatorio

**Todo el proyecto debe verse correctamente en móvil, tablet y escritorio.** Portfolio y landings son páginas públicas — la mayoría de visitas llegarán desde móvil.

- Enfoque **mobile-first**: diseñar primero para móvil y escalar hacia arriba
- Breakpoints Tailwind: `sm` (640px), `md` (768px), `lg` (1024px), `xl` (1280px)
- Testear siempre en al menos: 375px (iPhone SE), 768px (tablet), 1280px (escritorio)
- Nunca usar anchos o alturas fijas sin su variante responsive
- Imágenes con `max-w-full` y `object-cover` por defecto
- El Playwright MCP se usará para verificar el layout en diferentes viewports antes de hacer push

---

## Skills Activos

Todos los skills están en `C:\Users\dagar\.agents\skills\`.
Se invocan con `/nombre-skill` en Claude Code.

| Skill | Ruta | Cuándo usarlo |
|-------|------|--------------|
| `vercel-react-best-practices` | `~\.agents\skills\vercel-react-best-practices` | Al crear componentes React, hooks, contextos o optimizar rendimiento |
| `web-design-guidelines` | `~\.agents\skills\web-design-guidelines` | Al diseñar secciones del portfolio, landings o cualquier UI pública |
| `tailwind-v4-shadcn` | `~\.agents\skills\tailwind-v4-shadcn` | Al trabajar con Tailwind v4, variables CSS o instalar componentes shadcn — nuestro stack exacto |
| `tailwindcss-mobile-first` | `~\.agents\skills\tailwindcss-mobile-first` | Al maquetar cualquier componente — garantiza enfoque mobile-first |
| `tailwind-design-system` | `~\.agents\skills\tailwind-design-system` | Al definir tokens de diseño, escalas o sistema de colores global |
| `e2e-testing-patterns` | `~\.agents\skills\e2e-testing-patterns` | Al escribir tests E2E con Playwright |
| `laravel-specialist` | `~\.agents\skills\laravel-specialist` | Al crear modelos, migraciones, controladores, rutas o auth en Laravel |
| `solid` | `~\.agents\skills\solid` | Al refactorizar o diseñar arquitectura — aplica SOLID y clean code |
| `simplify` | builtin | Tras terminar una feature, para revisar y simplificar el código generado |

**MCPs activos:**
- `shadcn` (proyecto, `.claude/.mcp.json`) — instalar componentes shadcn/animate-ui
- `playwright` (`~\.claude\mcp.json`) — testing visual en navegador real, verificar responsive

---

## Git y Deploy

- **No hacer force push a master.**
- **Commits en español**, descriptivos.
- **Subir al repo después de cada cambio.** Cada modificación va a GitHub en el mismo momento.
- Cada commit que cambie funcionalidad debe actualizar también este CLAUDE.md si aplica.
