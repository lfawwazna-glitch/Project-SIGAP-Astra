<?php

use App\Http\Controllers\HealthController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - SIGAP Backend
|--------------------------------------------------------------------------
| Seluruh rute API publik dan internal untuk komunikasi dashboard,
| FastAPI AI service, dan simulator fase lampu lalu lintas.
*/

Route::get('/health', [HealthController::class, 'check'])->name('api.health');

// Fallback status rute
Route::get('/', function () {
    return response()->json([
        'message' => 'SIGAP Backend API is running',
        'health_check' => url('/api/health'),
    ]);
});

