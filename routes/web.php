<?php

use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

// Rutas públicas
Route::get('/', function () {
    return Inertia::render('Portfolio/Index');
});

// CRM — área privada (con auth más adelante)
Route::middleware(['auth'])->prefix('crm')->group(function () {
    Route::get('/', function () {
        return Inertia::render('Crm/Dashboard');
    });
});
