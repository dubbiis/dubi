#!/bin/sh
set -e

echo "[entrypoint] Iniciando Dubi..."

# Cache de configuración (con las env vars de EasyPanel ya disponibles)
echo "[entrypoint] Cacheando configuración..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Migraciones automáticas
echo "[entrypoint] Ejecutando migraciones..."
php artisan migrate --force

echo "[entrypoint] Listo. Arrancando servicios..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
