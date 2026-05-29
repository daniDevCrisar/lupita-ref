<?php

namespace App\Database;

use Illuminate\Support\Facades\DB;

class DBCoordinadores
{
    public static function listaPrincipal(){
        $sql = "SELECT * from coordinadores";
        return DB::select($sql);
    }
}
