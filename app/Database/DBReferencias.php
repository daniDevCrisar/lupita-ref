<?php

namespace App\Database;

use Illuminate\Support\Facades\DB;

class DBReferencias
{
    public static function listaPrincipal(){
        $sql="
        SELECT
            a.monitoreo_finalizado, a.ref ,
            (select provincia from ubigeo_provincias where ubigeo=LEFT(a.origen_ubigeo,4) limit 1) as origen_ubigeo_prov,
            (select distrito from ubigeo_distritos where ubigeo=a.origen_ubigeo limit 1) as origen_ubigeo_dis,
            a.trt_id , b.nombres as trt_nombre ,
            a.origen_cliente_id ,(select nombres from clientes where id= a.origen_cliente_id limit 1) as origen_cliente_nombre,
            a.destino_cliente_id,(select nombres from clientes where id= a.destino_cliente_id limit 1) as destino_cliente_nombre,
            a.coordinador_id ,c.nombres as coordinador_nombre ,
            d.id as 'evento_status_id',d.nombre as 'evento_status_nombre', d.etapa_id as 'evento_status_etapa',
            a.fin_descargue,a.inicio_descargue,a.llegada_destino , a.inicio_ruta,a.fin_de_carga,a.inicio_de_carga,a.presenta_para_carga
        FROM referencias a
        inner join trts b
        on b.id= a.trt_id
        inner join coordinadores c
        on c.id = a.coordinador_id
        inner join eventos d
        on d.id = a.evento_actual
        inner join ubigeo_provincias ub_p
        ;
        ";
    }
}
