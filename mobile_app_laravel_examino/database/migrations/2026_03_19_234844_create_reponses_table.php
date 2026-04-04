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
    {Schema::create('reponses', function (Blueprint $table) {
    $table->id();
    $table->foreignId('id_etudiant')->constrained('users')->onDelete('cascade');
    
    $table->unsignedBigInteger('id_question');
    $table->foreign('id_question')->references('id_question')->on('questions')->onDelete('cascade');
    
    $table->unsignedBigInteger('id_proposition');
    $table->foreign('id_proposition')->references('id_proposition')->on('propositions')->onDelete('cascade');

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reponses');
    }
};
