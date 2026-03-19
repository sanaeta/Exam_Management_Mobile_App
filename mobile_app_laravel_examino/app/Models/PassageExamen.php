<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Examen;


class PassageExamen extends Model
{
    protected $table = 'passage_examens';

    // Relation : Un passage concerne un examen
    public function examen() {
        return $this->belongsTo(Examen::class, 'examen_id', 'id_examen');
    }

    // Relation : Un passage appartient à un étudiant (User)
    public function user() {
        return $this->belongsTo(User::class, 'user_id');
    }
}