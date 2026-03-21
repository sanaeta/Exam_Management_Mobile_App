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
        Schema::create('propositions', function (Blueprint $table) {
         $table->id('id_proposition');
            $table->string('texte');
            $table->boolean('est_vrai')->default(false);
            $table->unsignedBigInteger('id_question');
            $table->timestamps();

            $table->foreign('id_question')
                  ->references('id_question')
                  ->on('questions')
                  ->onDelete('cascade');
        });
    }
    

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('propositions');
    }
};
