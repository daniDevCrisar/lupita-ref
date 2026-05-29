<?php

use App\Http\Controllers\ImportController;
use App\Http\Controllers\ReferenciasController;
use Illuminate\Support\Facades\Route;
use Livewire\Volt\Volt;



Route::view('dashboard', 'dashboard')
    ->middleware(['auth', 'verified'])
    ->name('dashboard');

Route::middleware(['auth'])->group(function () {
    Route::redirect('settings', 'settings/profile');

    Volt::route('settings/profile', 'settings.profile')->name('settings.profile');
    Volt::route('settings/password', 'settings.password')->name('settings.password');
    Volt::route('settings/appearance', 'settings.appearance')->name('settings.appearance');
});

require __DIR__.'/auth.php';


Route::prefix('importar')->group(function () {

    Route::get('/json', [ImportController::class, 'procesar_json'])->name('importar.json');
    //Route::post('/json/procesar', [ImportController::class, 'jsonProcesar']);

    Route::get('/excel', [ImportController::class, 'cargar_excel'])->name('importar.excel');
    Route::post('/excel/procesar', [ImportController::class, 'procesar_excel_referencias']);

    Route::get('/excel/{lote_id}', [ImportController::class, 'mostrar_lote_importado'])->name('importar.excel.lote');
    Route::get('/excel/{lote_id}/procesar', [ImportController::class, 'procesar_importacion_de_lote'])->name('importar.excel.procesar');

});

Route::get('/referencias', [ReferenciasController::class, 'lista_referencias'])->name('principal.referencias');

