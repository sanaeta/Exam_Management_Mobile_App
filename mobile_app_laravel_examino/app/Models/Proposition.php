<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Proposition extends Model
{
      protected $table = 'propositions';
    protected $primaryKey = 'id_proposition';
    public $timestamps = false;
}
