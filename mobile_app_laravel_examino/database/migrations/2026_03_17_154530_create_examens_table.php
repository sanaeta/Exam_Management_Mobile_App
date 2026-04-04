<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
       Schema::create('examen', function (Blueprint $table) {
    $table->id('id_examen');
    $table->string('titre');
    $table->dateTime('date_examen');
    $table->integer('duree');
    $table->foreignId('id_matiere')->constrained('matieres'); 
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('examen');
    }
};
