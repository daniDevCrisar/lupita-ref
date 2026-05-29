<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;


use App\Tools\ExcelTool;
use App\Tools\BuscarEnArray;
use App\Database\DBCore;
use App\Database\DBColumns;
use App\Database\Tmp\DBTmpLotes;
use App\Database\Tmp\DBTmpLlamadas;

use App\Database\DBConductores;
use App\Database\DBTrts;
use App\Database\DBReferencias;

class ImportController extends Controller
{
    //
    public function index()
    {
        return view('index', [
            'titulo' => '$titulo',
            'usuario' => '$usuario'
        ]);
    }


    public function procesar_json()
    {
        return view('import.importar_json');
    }

    public function cargar_excel()
    {
        return view('import.importar_excel');
    }

    public function procesar_excel_referencias(\Illuminate\Http\Request $request)
    {
        //--------procesar el archivo excel --------
        if (!$request->hasFile('excel')) {
            return "No se subió archivo";
        }
        $file = $request->file('excel');
        $data = ExcelTool::leer($file->getRealPath());
        $data = ExcelTool::limpiarExcelHojas($data);

        $lote_id = ExcelTool::generarLoteId();
        //-------procesar referencias--------------
        $hoja_refs = $data['Seguimiento estado Vehículos'] ?? []; //seleccionar la hoja

        $hoja_columnas = DBColumns::$campos_referencias_excel;
        $hoja_col_ordenadas=ExcelTool::ordenarColumnasExcel($hoja_columnas, $hoja_refs,$lote_id);

        $filas_procesadas=DBCore::insertBatch('tmp_refs',DBColumns::$table_referencias, $hoja_col_ordenadas);
        DBCore::ejecutar_sp_procesar_lote($lote_id);

        return true;
    }

    public function mostrar_lote_importado($lote_id)
    {
        $cabecera = DBTmpLotes::obtenerCabecera($lote_id);
        //dd($cabecera);
        $conductores = DBTmpLotes::obtenerConductoresDuplicados($lote_id);
        $trts = DBTmpLotes::obtenerTransportistasDuplicados($lote_id);
        $llamadas_detalle = DBTmpLotes::obtenerDetalle($lote_id);
        $l_exitosas = 0;
        $total = 0;
        foreach ($llamadas_detalle as $row) {
            $fila = (array) $row;
            $ultimoValor = end($fila);
            $l_exitosas += (int) $ultimoValor;
            $total++;
        }

        $llamadas = [
            'total' => $total,
            'exitosas' => $l_exitosas,
            'fallidas' => $total - $l_exitosas,
            'detalle'=> $llamadas_detalle
        ];

        return view('import.procesar_lote', [
            'conductores' => $conductores,
            'lote_id' => $lote_id,
            'cabecera' => $cabecera,
            'trts' => $trts,
            'llamadas' => $llamadas
        ]);
    }

    public function procesar_importacion_de_lote($lote_id){
        $conductores = DBTmpLotes::obtenerConductoresDuplicados($lote_id);
        $trts = DBTmpLotes::obtenerTransportistasDuplicados($lote_id);
        $llamadas_detalle = DBTmpLotes::obtenerDetalle($lote_id);
        //-----------GENERAR TABLAS---------------------------
        //----------------INSERTAR PRIMERO CONDUCTORES---------------------
        $personas=DBTmpLotes::compararNombres($conductores,'telefono','conductor');//comparar datos parecidos
        $count=0;
        foreach ($personas as $item){
            $accion= DBConductores::buscar_duplicados($item);

            echo $accion['accion'] . ': ' . $item->conductor . ' '. $item->telefono.' - '. $accion['row']->conductor.' ('. $accion['comparar'] .'%)<br>';
            if ($accion['accion']=='nuevo') $id_conductor = DBConductores::crear($item);
            else {
                $id_conductor = $accion['id'];
                if( $accion['accion']== 'actualizar'){
                    if( DBConductores::actualizar($accion['row']))
                        echo $accion['id'] . ' actualizado correrctamente <br>';
                    else echo $accion['id'] .' hubo un error al actualizar <br>';
                }
            }

            $personas[$count]->id=$id_conductor;
            $count++;
        }
        //insertar TRTS--------------------------
        $count=0;

        foreach ($trts as $item){
            $id_trt=null; //si el nombre esta en blanco
            if ($item->transportista !='') {
                $trt_accion= DBTrts::sp_insertar_o_obtener_trts($item);

                $id_trt=$trt_accion->id;
                echo $trt_accion->es_nuevo ? 'trt nuevo <br>': 'trt duplicado<br>';
            }
            else echo 'trt vacio<br>';

            $trts[$count]->id=$id_trt;
            $count++;
        }

        $refs=DBTmpLotes::obtenerRefsDuplicadas($lote_id); //obtener ref combinadas de compromiso y otras etapas
        //-----------------------insertar llamadas------------------
        $db_llamadas= new DBTmpLlamadas();
        foreach ($llamadas_detalle as $item){
            $id_trt = BuscarEnArray::en_trt($item->transportista, $trts);
            $id_conductor= BuscarEnArray::en_conductor($item->conductor, $personas);
            if (!$id_conductor) $id_conductor=BuscarEnArray::en_conductor($item->conductor, $personas,true);

            //if ($item->vapi_id=='019D689A-1DA4-7778-B4D7-6E7C5E3A73E5') dd($personas,$item,$id_conductor);
            echo 'trt id:'.$id_trt.' **** conductor id:'.$id_conductor.'<br>';
            DBConductores::crear_telefono([ 'id'=> $id_conductor, 'telefono'=>$item->telefono ]);
            BuscarEnArray::ref_para_agregar_ids($item->ref,$id_trt, $id_conductor, $refs);
            $db_llamadas::importar_llamadas_de_tmp_al_sistema($id_trt,$id_conductor,$lote_id,$item);
        }
        //insertar referencias
        foreach ($refs as $item){
            $ref_procesada=DBReferencias::sp_insertar_o_nueva_referencia($item);
            echo $item->ref;
            if ($ref_procesada)
                echo $ref_procesada->es_nuevo ? ' ref nueva <br>': ' ref duplicada<br>';
            else echo 'ref sin conductor<br>';
        }


        echo '<h2>llamadas:'.$db_llamadas::$log->total_llamadas.' ,duplicadas:'. $db_llamadas::$log->total_duplicados .'</h2><br>';

        DBTmpLotes::actualizar_procesado($lote_id,"procesados :" . $db_llamadas::$log->total_llamadas . " duplicados: ".$db_llamadas::$log->total_duplicados,1);

        dd($refs);
        //------------------------------------------------------

    }




}
