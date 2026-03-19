<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Examen;

class Matiere extends Model
{
    // La table s'appelle 'matieres' (au pluriel), c'est la convention, 
    // donc pas besoin de préciser $table, mais on le fait par sécurité.
    protected $table = 'matieres';


    protected $fillable = [
        'nom',
        'enseignant'
    ];
    public function examens() {
        return $this->hasMany(Examen::class, 'id_matiere');
    }
}
