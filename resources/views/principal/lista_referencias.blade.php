@extends('layouts.app')

@section('title', 'Inicio')

@section('heads')
    @livewireStyles
@endsection

@section('content')

    <div class="row">
        <div class="col-12">
            <h1>Lista de Referencias</h1>
        </div>
        @include('principal.resources.filtros_busqueda')
    </div>

    <div class="row">

        <div class="col-12">{{ $refs::$lista->links() }}</div>
        <div class="col-12">
            <div class="table-responsive" style="max-height: 800px; overflow-y: auto;">
                <table class="table table-bordered table-hover table-sm table-dark">
                    <thead class="table-primary" style="position: sticky;top: 0;z-index: 2;">
                    <tr>
                        <th>#</th>
                        <th>Ref</th>
                        <th>Fechas</th>
                        <th>Viaje</th>
                        <th>Clientes</th>
                        <th>Coordinador</th>
                        <th>Status</th>

                    </tr>
                    </thead>
                    <tbody style="font-size: 1rem;">
                    @foreach($refs::$lista as $row)
                    <tr class="{{ $loop->odd ? 'table-secondary' : '' }}">

                    <td class="bg-{{$row->monitoreo_finalizado? 'success' : ''}}">
                        {{ $loop->index+1}}
                    </td>
                    <td>{{$row->evento_status_etapa_emoji .' ' .$row->ref}}</td>
                    <td>
                        <div class="table-responsive p-1">
                            <table class="table table-hover table-dark">
                                <tbody>
                                <tr>
                                    <td class="table-success">1</td>
                                    <td>✅ Compromiso</td>
                                    <td><span class="badge bg-success">{{$refs::format_fecha($row->compromiso_carga)}}</span></td>

                                    <td class="table-warning">4</td>
                                    <td>🛣️ En ruta</td>
                                    <td><span class="badge bg-warning">{{$refs::format_fecha($row->inicio_ruta)}}</span></td>
                                </tr>
                                <tr>
                                    <td class="table-primary">2</td>
                                    <td>🛻 Fuera de planta para carga</td>
                                    <td><span class="badge bg-primary">{{$refs::format_fecha($row->presenta_para_carga)}}</span></td>

                                    <td class="table-danger">5</td>
                                    <td>🚛 Fuera de planta para descarga</td>
                                    <td><span class="badge bg-danger">{{$refs::format_fecha($row->llegada_destino)}}</span></td>
                                </tr>
                                <tr>
                                    <td class="table-info">3</td>
                                    <td>🏭 Dentro de planta para carga</td>
                                    <td><span
                                            class="badge bg-info fs-6"> {{$refs::format_fecha($row->inicio_de_carga)}} <br>
                                            {{$refs::format_fecha($row->fin_de_carga)}}</span>
                                    </td>

                                    <td class="table-success">6</td>
                                    <td>🏁 Dentro de planta para descarga</td>
                                    <td>
                                        <span
                                            class="badge bg-success">{{$refs::format_fecha($row->inicio_descargue)}} <br>
                                            {{$refs::format_fecha($row->fin_descargue)}}</span>
                                    </td>
                                </tr>

                                </tbody>
                            </table>
                        </div>
                    </td>
                    <td style="font-size: 0.8rem;">
                        <i class="bi bi-airplane"></i>
                        {{$row->origen_ubigeo_prov??$row->origen_ubigeo_dis??$row->origen_txt}} -
                        {{$row->destino_ubigeo_prov??$row->destino_ubigeo_dis??$row->destino_txt}} <br>
                        <i class="bi bi-card-text"></i> {{ $row->placa }} <br>
                        <i class="bi bi-truck-front"></i>{{ $row->trt_nombre }} (#{{$row->trt_id}})
                    </td>
                    <td style="font-size: 0.8rem;">
                        <i class="bi bi-buildings text-success"></i>
                            @if($row->origen_cliente_id==null)
                                📍{{$row->origen_ubigeo_prov??$row->origen_ubigeo_dis??$row->origen_txt}}
                            @else
                                <i class="bi bi-arrow-right-short text-success"></i> {{ $row->origen_cliente_nombre }}
                                (#{{$row->origen_cliente_id}})
                            @endif
                        <br>
                            @if($row->destino_cliente_id==null)
                                📍{{$row->destino_ubigeo_prov??$row->destino_ubigeo_dis??$row->destino_txt}}
                            @else
                                <i class="bi bi-buildings text-danger"></i>
                                <i class="bi bi-arrow-left-short text-danger"></i> {{ $row->destino_cliente_nombre }}
                                (#{{$row->destino_cliente_id}})
                           @endif
                    </td>

                    <td><i class="bi bi-person-gear"></i>{{ $row->coordinador_nombre}} (#{{$row->coordinador_id}})</td>
                    <td>{{ $row->evento_status_nombre}}</td>
                    </tr>
                    @endforeach
                    </tbody>
                </table>

            </div>
        </div>
        <div class="col-12">{{ $refs::$lista->links() }}</div>


    </div>
@endsection
@section('scripts')

@endsection
