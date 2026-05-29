<?php

namespace App\Database;

use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class DBCore
{
    /* =============================
       INSERT MASIVO
    ============================= */
    public static function insertBatch($tabla, array $columnas, array $filas)
    {
        if (empty($filas)) return 0;
        $insertData = [];

        foreach ($filas as $fila) {
            if (empty($fila[0])) continue;
            $rowAssoc = [];
            foreach ($columnas as $i => $col) {
                $rowAssoc[$col] = $fila[$i] ?? "";
            }
            $insertData[] = $rowAssoc;
        }

        if (empty($insertData)) return 0;
//        return DB::table($tabla)->insertOrIgnore($insertData);

        $lote = 100; // evadir el limite maximo de inserciones en mysql
        $chunks = array_chunk($insertData, $lote);
        foreach ($chunks as $chunk) {
            DB::table($tabla)->insertOrIgnore($chunk);
        }


    return true;
    }

    public static function ejecutar_sp_procesar_lote($lote){
        return DB::statement("CALL sp_procesar_lote(?);",[$lote]);
    }

    public static function format_fecha($fecha ,$format='d/m/y H:i'){
        return Carbon::parse($fecha)->format($format);
    }

}
