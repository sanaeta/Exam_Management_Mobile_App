<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Question extends Model
{
    protected $table = 'questions';
    protected $primaryKey = 'id_question';
    public $timestamps = false;

   
public function propositions()
{
    return $this->hasMany(Proposition::class, 'id_question');
}

}