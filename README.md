# Dubi — Portfolio + CRM personal

Portfolio personal y CRM propio para gestión de clientes, leads, proyectos y finanzas.

## Fases del proyecto

| Fase | Estado |
|------|--------|
| Portfolio | En desarrollo |
| Landings por sector | Pendiente |
| CRM (área privada) | Pendiente |

## Stack

| Capa | Tecnología |
|------|-----------|
| Backend | Laravel 13 + PHP 8.4 |
| Frontend | React 19 + Inertia.js v2 |
| CSS | Tailwind CSS v4 |
| Componentes | shadcn/ui + animate-ui |
| Build | Vite |
| Deploy | Docker + EasyPanel |
| BD producción | MySQL 8.x |
| BD local | SQLite |

## Arranque local

```bash
# Instalar dependencias
composer install
npm install

# Variables de entorno
cp .env.example .env
php artisan key:generate

# Base de datos (SQLite local)
php artisan migrate

# Servidor de desarrollo
php artisan serve
npm run dev
```

## Deploy

Push a `master` → webhook → EasyPanel reconstruye automáticamente.

```bash
git add .
git commit -m "descripción del cambio"
git push origin master
```

## Estructura de páginas

```
resources/js/Pages/
├── Portfolio/     # Página pública del portfolio
├── Landings/      # Landings por sector (pendiente)
└── Crm/           # Área privada con login (pendiente)
```

## Documentación técnica

Ver [CLAUDE.md](CLAUDE.md) para arquitectura completa, rutas, modelo de datos y trampas conocidas.
