<?php

namespace App\Http\Controllers;

use App\Database\DBCoordinadores;
use App\Database\DBEtapasLogisticas;
use Illuminate\Http\Request;


use App\Database\DBReferencias;

class ReferenciasController extends Controller
{
    public function lista_referencias(Request $request){
        $refs= new DBReferencias;
        $refs::$request = $request;
        $refs::listaPrincipal();
        $etapas_logisticas = DBEtapasLogisticas::listaPrincipal();
        $coordinadores = DBCoordinadores::listaPrincipal();

        return view('principal.lista_referencias',compact('refs','etapas_logisticas','coordinadores'));
    }
}
