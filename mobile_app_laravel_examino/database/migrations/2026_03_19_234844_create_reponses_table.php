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
        Schema::create('reponses', function (Blueprint $table) {
              $table->id();
            $table->unsignedBigInteger('id_etudiant');
            $table->unsignedBigInteger('id_question');
            $table->unsignedBigInteger('id_proposition');

            $table->timestamps();

            $table->foreign('id_etudiant')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('id_question')->references('id_question')->on('questions')->onDelete('cascade');
            $table->foreign('id_proposition')->references('id_proposition')->on('propositions')->onDelete('cascade');
       
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
