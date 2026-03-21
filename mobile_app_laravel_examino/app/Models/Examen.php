<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Question;

class Examen extends Model
{
    protected $table = 'examen';
    protected $primaryKey = 'id_examen';
    public $timestamps = false;

    protected $fillable = [
        'titre',
        'date_examen',
        'duree',
        'id_matiere'
    ];

    public function matiere()
    {
        return $this->belongsTo(Matiere::class, 'id_matiere');
    }

    public function passages()
    {
        return $this->hasMany(PassageExamen::class, 'examen_id');
    }
    public function questions()
{
    return $this->hasMany(Question::class, 'id_examen');
}

}