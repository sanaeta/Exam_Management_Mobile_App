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
        Schema::create('reclamations', function (Blueprint $table) {
            $table->id();
            $table->text('message');
            $table->string('statut')->default('en_attente');
            $table->unsignedBigInteger('id_etudiant');
            $table->unsignedBigInteger('id_examen');
            $table->dateTime('date_depot'); // Ou timestamp
            $table->foreign('id_etudiant')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('id_examen')->references('id_examen')->on('examen')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reclamations');
    }
};
