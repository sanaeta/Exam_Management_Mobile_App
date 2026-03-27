<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Api\ExamenController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\Api\PasswordController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/filieres', [AuthController::class, 'getFilieres']);


// Routes Protégées par Sanctum
Route::middleware('auth:sanctum')->group(function () {
    // Dashboard (Résumé)
    Route::get('/examens-dashboard', [ExamenController::class, 'getDashboardData']);
    // Listes complètes pour le "Voir plus" et les "Filtres"
    Route::get('/examens-passes', [ExamenController::class, 'getPasses']);
    Route::get('/correction/{id}', [ExamenController::class, 'getCorrection']);
    Route::get('/examens-avenir', [ExamenController::class, 'getAvenir']);
    Route::get('/examens-aujourdhui', [ExamenController::class, 'getAujourdhui']);
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::post('/reclamations', [ExamenController::class, 'postReclamation']);
});

Route::post('/password/forgot', [PasswordController::class, 'sendResetEmail']);
Route::post('/password/reset', [PasswordController::class, 'resetPassword']);