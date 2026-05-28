<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;


use App\Database\DBReferencias;

class ReferenciasController extends Controller
{
    public function lista_referencias(){
        $refs= new DBReferencias;
        $refs::listaPrincipal();

        return view('principal.lista_referencias',compact('refs'));
    }
}
