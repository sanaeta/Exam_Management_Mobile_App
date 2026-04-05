<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Examen;

class Matiere extends Model
{
   
    protected $table = 'matieres';


    protected $fillable = [
        'nom',
        'enseignant'
    ];
    public function examens() {
        return $this->hasMany(Examen::class, 'id_matiere');
    }
}
