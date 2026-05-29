<?php

namespace App\Database;

use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Query\Builder;
class DBReferencias extends DBCore
{
    public static $lista = [];
    public static $request = [];
    public static function listaPrincipal(){
        $etapa_l= self::$request->etapa_logistica_id;
        $coordinador= self::$request->coordinador_id;

        $fecha_i =self::$request->fecha_inicio??'';
        $fecha_f= self::$request->fecha_fin??'';

        $viaje_origen =self::$request->viaje_origen??'';
        $viaje_destino = self::$request->viaje_destino??'';

        $sql="
        SELECT
            a.monitoreo_finalizado, a.ref ,
            (select provincia from ubigeo_provincias where ubigeo=LEFT(a.origen_ubigeo,4) limit 1) as origen_ubigeo_prov,
            (select distrito from ubigeo_distritos where ubigeo=a.origen_ubigeo limit 1) as origen_ubigeo_dis, a.origen_txt,

            (select provincia from ubigeo_provincias where ubigeo=LEFT(a.destino_ubigeo,4) limit 1) as destino_ubigeo_prov,
            (select distrito from ubigeo_distritos where ubigeo=a.destino_ubigeo limit 1) as destino_ubigeo_dis, a.destino_txt,

            a.trt_id , b.nombres as trt_nombre ,
            a.origen_cliente_id ,(select nombres from clientes where id= a.origen_cliente_id limit 1) as origen_cliente_nombre,
            a.destino_cliente_id,(select nombres from clientes where id= a.destino_cliente_id limit 1) as destino_cliente_nombre,
            a.coordinador_id ,c.nombres as coordinador_nombre ,
            d.id as 'evento_status_id',d.nombre as 'evento_status_nombre', d.etapa_id as 'evento_status_etapa' , e.emoji as 'evento_status_etapa_emoji',
            a.fin_descargue,a.inicio_descargue,a.llegada_destino , a.inicio_ruta,a.fin_de_carga,a.inicio_de_carga,a.presenta_para_carga
        FROM referencias a
        inner join trts b
        on b.id= a.trt_id
        inner join coordinadores c
        on c.id = a.coordinador_id
        inner join eventos d
        on d.id = a.evento_actual
        inner join etapas_logisticas e
        on e.id = d.etapa_id
        ;
        ";

        $db_refs = DB::table('referencias as a')
        ->join('trts as b', 'b.id', '=', 'a.trt_id')
        ->join('coordinadores as c', 'c.id', '=', 'a.coordinador_id')
        ->join('eventos as d', 'd.id', '=', 'a.evento_actual')
        ->join('etapas_logisticas as e', 'e.id', '=', 'd.etapa_id')
        ->selectRaw("
        a.monitoreo_finalizado,
        a.ref, a.placa,
        (SELECT provincia FROM ubigeo_provincias WHERE ubigeo = LEFT(a.origen_ubigeo, 4) LIMIT 1) as origen_ubigeo_prov,
        (SELECT distrito FROM ubigeo_distritos WHERE ubigeo = a.origen_ubigeo LIMIT 1) as origen_ubigeo_dis,
        a.origen_txt,
        (SELECT provincia FROM ubigeo_provincias WHERE ubigeo = LEFT(a.destino_ubigeo, 4) LIMIT 1) as destino_ubigeo_prov,
        (SELECT distrito FROM ubigeo_distritos WHERE ubigeo = a.destino_ubigeo LIMIT 1) as destino_ubigeo_dis,
        a.destino_txt,
        a.trt_id,
        b.nombres as trt_nombre,
        a.origen_cliente_id,
        (SELECT nombres FROM clientes WHERE id = a.origen_cliente_id LIMIT 1) as origen_cliente_nombre,
        a.destino_cliente_id,
        (SELECT nombres FROM clientes WHERE id = a.destino_cliente_id LIMIT 1) as destino_cliente_nombre,
        a.coordinador_id,
        c.nombres as coordinador_nombre,
        d.id as evento_status_id,
        d.nombre as evento_status_nombre,
        d.etapa_id as evento_status_etapa,
        e.emoji as 'evento_status_etapa_emoji',
        a.fin_descargue,
        a.inicio_descargue,
        a.llegada_destino,
        a.inicio_ruta,
        a.fin_de_carga,
        a.inicio_de_carga,
        a.compromiso_carga,
        a.presenta_para_carga
        ")
        ->when((string) $etapa_l !='', function ($query) use($etapa_l) {
            $query->where('e.id', '=', $etapa_l);
        })
        ->when((string) $coordinador !='', function ($query) use($coordinador) {
            $query->where('a.coordinador_id', '=', $coordinador);
        })
        ->when($fecha_i or $fecha_f, function ($query) use ($fecha_i, $fecha_f) {
            if ($fecha_i and !$fecha_f)
                $query->whereBetween('a.compromiso_carga', [
                    Carbon::parse($fecha_i)->startOfDay(),
                    Carbon::parse($fecha_i)->endOfDay()
                ]);
            elseif ($fecha_i and $fecha_f)
                $query->whereBetween('a.compromiso_carga', [
                    Carbon::parse($fecha_i)->startOfDay(),
                    Carbon::parse($fecha_f)->endOfDay()
                ]);
        })
        ->when((string) $viaje_origen !='', function ($query) use($viaje_origen) {
            if ($viaje_origen==1)
                $query->whereRaw("(LEFT(a.origen_ubigeo, 2) = '15' or LEFT(a.origen_ubigeo, 2) = '07')");
            else
                $query->whereRaw("(LEFT(a.origen_ubigeo, 2) != '15' and LEFT(a.origen_ubigeo, 2) != '07')");
        })
        ->when((string) $viaje_destino !='', function ($query) use($viaje_destino) {
            if ($viaje_destino==1)
                $query->whereRaw("(LEFT(a.destino_ubigeo, 2) = '15' or LEFT(a.destino_ubigeo, 2) = '07')");
            else
                $query->whereRaw("(LEFT(a.destino_ubigeo, 2) != '15' and LEFT(a.destino_ubigeo, 2) != '07')");
        })
        ->paginate(50)
        ->withQueryString();
        self::$lista = $db_refs;
        return $db_refs;
    }


}
