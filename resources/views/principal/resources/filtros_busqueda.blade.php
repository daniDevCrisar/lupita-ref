<form method="GET">
    <fieldset class="border p-3 rounded mb-3">
        <legend class="float-none w-auto px-2 fs-6">
            Filtros de búsqueda
        </legend>

        <div class="row g-3">
            <div class="col-md-4">
                <label class="form-label" for="etapa_logistica_id">Etapa Logistica</label>
                <select name="etapa_logistica_id" id="etapa_logistica_id"
                        class="form-control">
                    <option value="" @selected((string) request('etapa_logistica_id')==='') >Todos</option>
                    @foreach($etapas_logisticas as $item)
                        <option value="{{$item->id}}"
                            @selected(request('etapa_logistica_id') === (string) $item->id)>{{$item->emoji . ' ' . $item->nombre}}</option>
                    @endforeach
                </select>
            </div>

            <div class="col-md-4">
                <label class="form-label" for="fecha_inicio">Fecha inicio</label>
                <input type="date" id="fecha_inicio"
                       name="fecha_inicio"
                       value="{{ request('fecha_inicio') }}"
                       class="form-control">
            </div>

            <div class="col-md-4">
                <label class="form-label" for="fecha_fin">Fecha fin</label>
                <input type="date" id="fecha_fin"
                       name="fecha_fin"
                       value="{{ request('fecha_fin') }}"
                       class="form-control">
            </div>

            <div class="col-md-4">
                <label class="form-label" for="coordinador_id">Coordinador</label>
                <select name="coordinador_id" id="coordinador_id"
                        class="form-control">
                    <option value="" @selected((string) request('coordinador_id')==='') >Todos</option>
                    @foreach($coordinadores as $item)
                        <option value="{{$item->id}}"
                            @selected(request('coordinador_id') === (string) $item->id)>👔 {{$item->nombres}}</option>
                    @endforeach
                </select>
            </div>

            <div class="col-md-4">
                <label class="form-label" for="viaje_origen">Viaje Origen</label>
                <select name="viaje_origen" id="viaje_origen"
                        class="form-control">
                    <option value="" @selected((string) request('viaje_origen')==='') >Todos</option>
                    <option value="1" @selected((string) request('viaje_origen')==='1') >🌉 Lima</option>
                    <option value="2" @selected((string) request('viaje_origen')==='2') >🌄 Provincia</option>
                </select>
            </div>

            <div class="col-md-4">
                <label class="form-label" for="viaje_destino">Viaje Destino</label>
                <select name="viaje_destino" id="viaje_destino"
                        class="form-control">
                    <option value="" @selected((string) request('viaje_destino')==='') >Todos</option>
                    <option value="1" @selected((string) request('viaje_destino')==='1') >🌉 Lima</option>
                    <option value="2" @selected((string) request('viaje_destino')==='2') >🌄 Provincia</option>
                </select>
            </div>

            <div class="col-md-4 d-flex align-items-end">
                <button type="submit" class="btn btn-primary me-2">
                    <i class="bi bi-search"></i> Filtrar
                </button>

                <a href="{{ url()->current() }}" class="btn btn-secondary">
                    Limpiar
                </a>
            </div>

        </div>


    </fieldset>

</form>
