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
        Schema::create('passage_examens', function (Blueprint $table) {
    $table->id();
    $table->foreignId('examen_id')->constrained();
    $table->foreignId('user_id')->constrained(); // l'étudiant
    $table->decimal('note', 5, 2)->nullable();
    $table->dateTime('date_passage');
    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('passage_examens');
    }
};
