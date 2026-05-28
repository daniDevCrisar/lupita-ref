CREATE TABLE tmp_refs (
                             lote_id VARCHAR(100),
                             codigo VARCHAR(100),
                             ref VARCHAR(100),
                             origen VARCHAR(100),
                             destino VARCHAR(100),
                             cliente_destino VARCHAR(100),
                             fecha_de_cargue VARCHAR(100),
                             empresa VARCHAR(100),
                             aliado VARCHAR(100),
                             empresa_trt VARCHAR(100),
                             placa VARCHAR(100),
                             monitoreo_finalizado VARCHAR(100),
                             finalizado_por VARCHAR(100),
                             status_actual VARCHAR(100),
                             fecha_hora_status_actual VARCHAR(100),
                             status_tiempo VARCHAR(100),
                             fecha_hora_aprox_llegada_eta VARCHAR(100),
                             fecha_hora_compromiso_llegada VARCHAR(100),
                             fecha_hora_ingreso_vigilancia VARCHAR(100),
                             fecha_hora_salida_vigilancia VARCHAR(100),
                             carreta VARCHAR(100),
                             procesamiento_opl VARCHAR(100),
                             nombre_coordinador VARCHAR(100),
                             presenta_para_carga_fecha VARCHAR(100),
                             presenta_para_carga_monitorista VARCHAR(100),
                             presenta_para_carga_observacion VARCHAR(100),
                             llegada_a_origen_fecha VARCHAR(100),
                             llegada_a_origen_monitorista VARCHAR(100),
                             llegada_a_origen_observacion VARCHAR(100),
                             pre_enturnamiento_fecha VARCHAR(100),
                             pre_enturnamiento_monitorista VARCHAR(100),
                             pre_enturnamiento_observacion VARCHAR(100),
                             enturnamiento_fecha VARCHAR(100),
                             enturnamiento_monitorista VARCHAR(100),
                             enturnamiento_observacion VARCHAR(100),
                             inicio_de_carga_fecha VARCHAR(100),
                             inicio_de_carga_monitorista VARCHAR(100),
                             inicio_de_carga_observacion VARCHAR(100),
                             fin_de_carga_fecha VARCHAR(100),
                             fin_de_carga_monitorista VARCHAR(100),
                             fin_de_carga_observacion VARCHAR(100),
                             inicio_de_toldeo_fecha VARCHAR(100),
                             inicio_de_toldeo_monitorista VARCHAR(100),
                             inicio_de_toldeo_observacion VARCHAR(100),
                             fin_de_toldeo_fecha VARCHAR(100),
                             fin_de_toldeo_monitorista VARCHAR(100),
                             fin_de_toldeo_observacion VARCHAR(100),
                             generacion_de_documento_fecha VARCHAR(100),
                             generacion_de_documento_monitorista VARCHAR(100),
                             generacion_de_documento_observacion VARCHAR(100),
                             entrega_de_documento_fecha VARCHAR(100),
                             entrega_de_documento_monitorista VARCHAR(100),
                             entrega_de_documento_observacion VARCHAR(100),
                             inicio_ruta_fecha VARCHAR(100),
                             inicio_ruta_monitorista VARCHAR(100),
                             inicio_ruta_observacion VARCHAR(100),
                             en_ruta_fecha VARCHAR(100),
                             en_ruta_monitorista VARCHAR(100),
                             en_ruta_observacion VARCHAR(100),
                             llegada_a_destino_fecha VARCHAR(100),
                             llegada_a_destino_monitorista VARCHAR(100),
                             llegada_a_destino_observacion VARCHAR(100),
                             inicio_descargue_fecha VARCHAR(100),
                             inicio_descargue_monitorista VARCHAR(100),
                             inicio_descargue_observacion VARCHAR(100),
                             fin_descargue_fecha VARCHAR(100),
                             fin_descargue_monitorista VARCHAR(100),
                             fin_descargue_observacion VARCHAR(100),
                             en_resguardo_fecha VARCHAR(100),
                             en_resguardo_monitorista VARCHAR(100),
                             en_resguardo_observacion VARCHAR(100),
                             alerta_de_retraso_de_descarga_fecha VARCHAR(100),
                             alerta_de_retraso_de_descarga_monitorista VARCHAR(100),
                             alerta_de_retraso_de_descarga_observacion VARCHAR(100),
                             parada_por_otros_fecha VARCHAR(100),
                             parada_por_otros_monitorista VARCHAR(100),
                             parada_por_otros_observacion VARCHAR(100),
                             parada_por_descanso_fecha VARCHAR(100),
                             parada_por_descanso_monitorista VARCHAR(100),
                             parada_por_descanso_observacion VARCHAR(100),
                             operador_no_responde_fecha VARCHAR(100),
                             operador_no_responde_monitorista VARCHAR(100),
                             operador_no_responde_observacion VARCHAR(100),
                             PRIMARY KEY (lote_id, ref)
);

CREATE TABLE tmp_lotes (
                           lote_id BIGINT PRIMARY KEY,
                           usuario_id INT NOT NULL,
                           tipo TINYINT(1),  -- para q sea escalable en este solo sería 1 para el json basico de vapi
                           nombre VARCHAR(50) NOT NULL,
                           comentario VARCHAR(200) NOT NULL,
                           procesado TINYINT(1) NOT NULL DEFAULT 0 ,
                           created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


drop table if exists referencias;
CREATE TABLE referencias (
    ref VARCHAR(12) PRIMARY KEY,

    trt_id INT,
    conductor_id INT,
    coordinador_id INT,

    origen_txt VARCHAR(100),
    origen_ubigeo VARCHAR(6),
    origen_cliente_id INT,

    destino_txt VARCHAR(100),
    destino_ubigeo VARCHAR(6),
    destino_cliente_id INT,

    titulo_viaje VARCHAR(200),
    ruta_id INT ,

    placa VARCHAR(10) ,

    fecha_despachador TIMESTAMP DEFAULT NULL,

    fin_descargue TIMESTAMP DEFAULT NULL,
    inicio_descargue TIMESTAMP DEFAULT NULL,
    llegada_destino TIMESTAMP DEFAULT NULL,
    inicio_ruta TIMESTAMP DEFAULT NULL,

    fin_de_carga TIMESTAMP DEFAULT NULL,
    inicio_de_carga TIMESTAMP DEFAULT NULL,
    presenta_para_carga TIMESTAMP DEFAULT NULL,
    compromiso_carga TIMESTAMP DEFAULT NULL,

    # OTROS NO SE
    fecha_de_cargue TIMESTAMP DEFAULT NULL,

    monitoreo_finalizado TINYINT(1) NOT NULL DEFAULT 1,
    evento_actual int,
    evento_actual_fecha TIMESTAMP DEFAULT NULL
);

CREATE TABLE trts (
                      id INT AUTO_INCREMENT PRIMARY KEY,
                      sis_id VARCHAR(9) NULL,
                      nombres VARCHAR(100) NOT NULL,
                      ruc VARCHAR(12) NULL,

                      activo TINYINT(1) NOT NULL DEFAULT 1,
                      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      FULLTEXT(nombres)
);

CREATE TABLE coordinadores (
                      id INT AUTO_INCREMENT PRIMARY KEY,
                      sis_id VARCHAR(9) NULL,
                      nombres VARCHAR(100) NOT NULL,

                      activo TINYINT(1) NOT NULL DEFAULT 1,
                      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      FULLTEXT(nombres)
);

CREATE TABLE clientes (
                      id INT AUTO_INCREMENT PRIMARY KEY,
                      sis_id VARCHAR(9) NULL,
                      nombres VARCHAR(150) NOT NULL,
                      ruc VARCHAR(12) NULL,

                      activo TINYINT(1) NOT NULL DEFAULT 1,
                      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      FULLTEXT(nombres)
);

CREATE TABLE etapas_logisticas (
                                   id INT PRIMARY KEY AUTO_INCREMENT,
                                   nombre VARCHAR(50) NOT NULL,
                                   descripcion TEXT,
                                   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                   UNIQUE KEY uk_nombre (nombre)
);

-- Inserción de datos
INSERT INTO etapas_logisticas (id, nombre, descripcion) VALUES
('1', 'Confirmado', 'Estado inicial de confirmación del viaje'),
('2', 'Llegada Origen', 'Eventos relacionados con la llegada al punto de origen'),
('3', 'Estadia Planta Origen', 'Permanencia en planta de origen para carga y trámites'),
('4', 'En ruta', 'Viaje hacia el destino, incluye paradas y novedades'),
('5', 'Llegada Destino', 'Eventos de llegada al punto de destino'),
('6', 'Descarga', 'Proceso de descarga de mercancía'),
('100', 'Alerta GPS', 'Alertas relacionadas con GPS y tracking'),
('101', 'Reprogramacion', 'Viajes que han sido reprogramados'),
('102', 'Sin Monitoreo', 'Viajes sin seguimiento activo'),
('103', 'Sin respuesta', 'Operador no responde a comunicaciones');

drop table if exists eventos;
CREATE TABLE eventos (
                         id INT PRIMARY KEY,
                         etapa_id INT NOT NULL,
                         nombre_evento VARCHAR(100) NOT NULL,
                         nombre VARCHAR(100) NOT NULL,
                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                         FOREIGN KEY (etapa_id) REFERENCES etapas_logisticas(id)
);

INSERT INTO eventos (id, etapa_id, nombre_evento, nombre) VALUES

-- Etapa 1: Confirmado (id_etapa=1) → ids: 1001, 1002...
(1001, 1, 'Confirmado', 'CONFIRMADO'),

-- Etapa 2: Llegada Origen (id_etapa=2) → ids: 2001, 2002...
(2001, 2, 'Presenta para Carga', 'PRESENTA PARA CARGA'),
(2002, 2, 'En Espera de ingreso', 'EN ESPERA DE INGRESO'),
(2003, 2, 'Llegada a Origen', 'LLEGADA A ORIGEN'),
(2004, 2, 'Notificación de Llegada', 'NOTIFICACION DE LLEGADA'),

-- Etapa 3: Estadia Planta Origen (id_etapa=3) → ids: 3001, 3002...
(3001, 3, '¡ALERTA DE RETRASO DE CARGA!', 'ALERTA DE RETRASO DE CARGA'),
(3002, 3, 'EN CARGA', 'EN CARGA'),
(3003, 3, 'Entrega de Documento', 'ENTREGA DE DOCUMENTO'),
(3004, 3, 'Fin de carga', 'FIN DE CARGA'),
(3005, 3, 'Inicio de Carga', 'INICIO DE CARGA'),
(3006, 3, 'Inicio de Toldeo', 'INICIO DE TOLDEO'),
(3007, 3, 'Pre - Enturnamiento', 'PRE - ENTURNAMIENTO'),
(3008, 3, 'En espera de cargue', 'EN ESPERA DE CARGUE'),
(3009, 3, 'Enturnamiento', 'ENTURNAMIENTO'),
(3010, 3, 'ESPERA DE DOCUMENTOS', 'ESPERA DE DOCUMENTOS'),
(3011, 3, 'ESPERA DE INICIO', 'ESPERA DE INICIO'),
(3012, 3, 'Fin de Toldeo', 'FIN DE TOLDEO'),
(3013, 3, 'Final Cargue', 'FINAL CARGUE'),
(3014, 3, 'Generación de Documento', 'GENERACION DE DOCUMENTO'),
(3015, 3, 'Ingreso', 'INGRESO'),
(3016, 3, 'Inicio Cargue', 'INICIO CARGUE'),

-- Etapa 4: En ruta (id_etapa=4) → ids: 4001, 4002...
(4001, 4, 'Carga de Combustible', 'CARGA DE COMBUSTIBLE'),
(4002, 4, 'Caseta', 'CASETA'),
(4003, 4, 'En Resguardo', 'EN RESGUARDO'),
(4004, 4, 'En ruta', 'EN RUTA'),
(4005, 4, 'Falla Mecánica', 'FALLA MECANICA'),
(4006, 4, 'Inicio Ruta', 'INICIO RUTA'),
(4007, 4, 'PARADA POR DESCANSO', 'PARADA POR DESCANSO'),
(4008, 4, 'Parada por Mantenimiento', 'PARADA POR MANTENIMIENTO'),
(4009, 4, 'Parada por Otros', 'PARADA POR OTROS'),
(4010, 4, 'Parada por Alimentos', 'PARADA POR ALIMENTOS'),
(4011, 4, 'Salida', 'SALIDA'),
(4012, 4, 'Stand By', 'STAND BY'),

-- Etapa 5: Llegada Destino (id_etapa=5) → ids: 5001, 5002...
(5001, 5, 'Confirmación Llegada Destino', 'CONFIRMACION LLEGADA DESTINO'),
(5002, 5, 'Llegada a Destino', 'LLEGADA A DESTINO'),

-- Etapa 6: Descarga (id_etapa=6) → ids: 6001, 6002...
(6001, 6, '¡ALERTA DE RETRASO DE DESCARGA!', 'ALERTA DE RETRASO DE DESCARGA'),
(6002, 6, 'CONFIRMACIÓN FIN DESCARGUE', 'CONFIRMACION FIN DESCARGUE'),
(6003, 6, 'Confirmación Inicio Descargue', 'CONFIRMACION INICIO DESCARGUE'),
(6004, 6, 'Fin Descargue', 'FIN DESCARGUE'),
(6005, 6, 'Inicio Descargue', 'INICIO DESCARGUE'),
(6006, 6, 'EN DESCARGUE', 'EN DESCARGUE'),
(6007, 6, 'En espera de descargue', 'EN ESPERA DE DESCARGUE'),
(6008, 6, 'En Proceso de Descargue', 'EN PROCESO DE DESCARGUE'),

-- Etapa 100: Alerta GPS (id_etapa=100) → ids: 100001, 100002...
(100001, 100, '¡ALERTA DE GPS!', 'ALERTA DE GPS'),
(100002, 100, 'Sin acceso a cuenta espejo', 'SIN ACCESO A CUENTA ESPEJO'),

-- Etapa 101: Reprogramacion (id_etapa=101) → ids: 101001, 101002...
(101001, 101, 'VIAJE REPROGRAMADO', 'VIAJE REPROGRAMADO'),

-- Etapa 102: Sin Monitoreo (id_etapa=102) → ids: 102001, 102002...
(102001, 102, 'Sin Monitoreo', 'SIN MONITOREO'),
(102002, 102, 'Sin Información', 'SIN INFORMACION'),

-- Etapa 103: Sin respuesta (id_etapa=103) → ids: 103001, 103002...
(103001, 103, 'Operador no responde', 'OPERADOR NO RESPONDE');

