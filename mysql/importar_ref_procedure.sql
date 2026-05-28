DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_procesar_importacion_ref`$$

CREATE PROCEDURE `sp_procesar_importacion_ref`(
    IN p_ref VARCHAR(100),
    IN p_lote_id VARCHAR(100)
)
BEGIN
#  -------------INICIO----------------------
    DECLARE v_existe_ref VARCHAR(100); -- campo: codigo
    # --------------Datos normales-------------
    DECLARE v_guia VARCHAR(100); -- campo: codigo
    DECLARE v_placa VARCHAR(100); -- campo: placa

    # -------------- IDS de Agentes--------------------
    DECLARE v_cliente_origen VARCHAR(100); -- campo: empresa
    DECLARE v_cliente_destino VARCHAR(100); -- campo: cliente_destino
    DECLARE v_trt VARCHAR(100); -- campo: empresa_trt
    DECLARE v_nombre_coordinador VARCHAR(100); -- campo: empresa_trt

    #---------------Ubigeo---------------------
    DECLARE v_origen VARCHAR(100); -- campo: empresa
    DECLARE v_destino VARCHAR(100); -- campo: cliente_destino

    #-------------- Estados-------------------------
    DECLARE v_monitoreo_finalizado VARCHAR(100); -- campo: monitoreo_finalizado (FINALIZADO|EN CURSO)
    DECLARE v_finalizado_por VARCHAR(100); -- campo: finalizado_por ,usuario q finalizo

    DECLARE v_status_actual VARCHAR(100); -- campo: status_actual , ultimo evento registrado
    DECLARE v_fecha_status_actual VARCHAR(100); -- campo: fecha_hora_status_actual, fecha del ultimo evento

    #---------------FECHAS IMPORTANTES-----------
    DECLARE v_fin_descargue VARCHAR(100); -- campo: fin_descargue_fecha
    DECLARE v_inicio_descargue VARCHAR(100); -- campo: inicio_descargue_fecha
    DECLARE v_llegada_destino VARCHAR(100); -- campo: llegada_a_destino_fecha

    DECLARE v_inicio_ruta VARCHAR(100); -- campo: inicio_ruta_fecha

    DECLARE v_fin_de_carga VARCHAR(100); -- campo: fin_de_carga_fecha
    DECLARE v_inicio_de_carga VARCHAR(100); -- campo: inicio_de_carga_fecha
    DECLARE v_presenta_para_carga VARCHAR(100); -- campo: presenta_para_carga_fecha
    DECLARE v_compromiso_carga VARCHAR(100); -- campo: fecha_hora_compromiso_llegada

    DECLARE v_fecha_de_cargue VARCHAR(100); -- campo: fecha_de_cargue

    DECLARE v_evento_fecha VARCHAR(100); -- campo: fecha_hora_status_actual

    #------------BUSCAR EN TABLAS------------------
    DECLARE n_trt_id INT;
    DECLARE n_trt_nombres VARCHAR(100);
    DECLARE n_trt_nuevo  TINYINT(1) DEFAULT 0;
    #--------------CLIENTE----------------
    DECLARE n_cliente_origen_id INT;
    DECLARE n_cliente_origen_nombres VARCHAR(100);
    DECLARE n_cliente_origen_nuevo  TINYINT(1) DEFAULT 0;

    DECLARE n_cliente_destino_id INT;
    DECLARE n_cliente_destino_nombres VARCHAR(100);
    DECLARE n_cliente_destino_nuevo  TINYINT(1) DEFAULT 0;
    #--------------FINALIZADO?----------------
    DECLARE n_estado_finalizado TINYINT(1) DEFAULT 0;
    #--------------ULTIMO EVENTO----------------
    DECLARE n_evento_id INT;
    DECLARE n_evento_etapa_id INT;
    DECLARE n_evento_nombre VARCHAR(100);
    #--------------UBIGEO----------------
    DECLARE n_origen_ubigeo VARCHAR(6);
    DECLARE n_destino_ubigeo VARCHAR(6);
    #--------------UBIGEO----------------
    DECLARE n_coordinador_id INT;
    DECLARE n_coordinador_nuevo TINYINT(1) DEFAULT 0;

    SELECT ref,
           codigo, placa, empresa, cliente_destino, empresa_trt, monitoreo_finalizado,
           finalizado_por, status_actual, fecha_hora_status_actual, fin_descargue_fecha,
           inicio_descargue_fecha, llegada_a_destino_fecha, inicio_ruta_fecha, fin_de_carga_fecha,
           inicio_de_carga_fecha, presenta_para_carga_fecha, fecha_hora_compromiso_llegada,
           origen,destino,nombre_coordinador , fecha_de_cargue ,fecha_hora_status_actual
    INTO
        v_existe_ref,
        v_guia, v_placa, v_cliente_origen, v_cliente_destino, v_trt, v_monitoreo_finalizado,
        v_finalizado_por, v_status_actual, v_fecha_status_actual, v_fin_descargue,
        v_inicio_descargue, v_llegada_destino, v_inicio_ruta, v_fin_de_carga,
        v_inicio_de_carga, v_presenta_para_carga, v_compromiso_carga,
        v_origen,v_destino , v_nombre_coordinador , v_fecha_de_cargue , v_evento_fecha
    FROM tmp_refs
    WHERE ref = p_ref AND lote_id = p_lote_id
    LIMIT 1;

    IF v_existe_ref IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La referencia no existe';
    END IF;

    # ----------- BUSCAR TRT DE REF-------------------------------
    IF v_trt !='' OR v_trt IS NULL THEN
        SELECT id,nombres INTO n_trt_id , n_trt_nombres FROM trts where nombres = v_trt limit 1;
        #comprobar si se encontro si no agregarlo ala tabla
        IF n_trt_id IS NULL THEN
            INSERT INTO trts (nombres,activo) VALUES (v_trt,1);
            SET n_trt_id = LAST_INSERT_ID();  -- Obtener el último ID insertado
            SET n_trt_nombres = v_trt;         -- Asignar el nombre
            set n_trt_nuevo = 1;
        END IF;
    ELSE
        SET v_trt = NULL;
    END IF;
    # ----------------------------------------------------------------
    # -------------------BUSCAR CLIENTE--------------------------------
    IF v_cliente_origen !='' OR v_cliente_origen IS NULL OR v_cliente_origen != v_origen THEN
        SELECT id,nombres INTO n_cliente_origen_id , n_cliente_origen_nombres
                          FROM clientes where nombres = v_cliente_origen limit 1;
        # comprobar si se encontro si no agregarlo ala tabla
        IF n_cliente_origen_id IS NULL THEN
            INSERT INTO clientes (nombres,activo) VALUES (v_cliente_origen,1);
            SET n_cliente_origen_id = LAST_INSERT_ID();  -- Obtener el último ID insertado
            SET n_cliente_origen_nombres = v_cliente_origen;         -- Asignar el nombre
            set n_cliente_origen_nuevo = 1;
        END IF;
    ELSE
        SET v_cliente_origen = NULL;
    END IF;
    # cliente destino
    IF v_cliente_destino !='' OR v_cliente_destino IS NULL  OR v_cliente_destino != v_destino THEN
        SELECT id,nombres INTO n_cliente_destino_id , n_cliente_destino_nombres FROM clientes
        where nombres = v_cliente_destino limit 1;
        IF n_cliente_destino_id IS NULL THEN
            INSERT INTO clientes (nombres,activo) VALUES (v_cliente_destino,1);
            SET n_cliente_destino_id = LAST_INSERT_ID();  -- Obtener el último ID insertado
            SET n_cliente_destino_nombres = v_cliente_origen;         -- Asignar el nombre
            set n_cliente_destino_nuevo = 1;
        END IF;
    ELSE
        SET v_cliente_destino = NULL;
    END IF;
    # -----------------ESTADO---------------
    IF v_monitoreo_finalizado='FINALIZADO' THEN
        set n_estado_finalizado =1;
    END IF;
    # ---------------ESTADO ACTUAL-----------
    select id , etapa_id , nombre INTO n_evento_id , n_evento_etapa_id , n_evento_nombre
    from eventos where nombre= v_status_actual limit 1;
    # ---------------BUSCAR COORDINADOR
    IF v_nombre_coordinador !='' OR v_nombre_coordinador IS NULL THEN
        select id into n_coordinador_id FROM coordinadores WHERE nombres = v_nombre_coordinador limit 1;
        IF n_coordinador_id IS NULL THEN
            INSERT INTO coordinadores (nombres,activo) VALUES (v_nombre_coordinador,1);
            SET n_coordinador_id = LAST_INSERT_ID();  -- Obtener el último ID insertado
            set n_coordinador_nuevo = 1;
        END IF;
    ELSE
        SET v_nombre_coordinador = NULL;
    END IF;
    # ----------------OBTENER ORIGEN , DESTINO UBIGEO provincia---------------------
    IF v_origen ='PROV. CONST. DEL CALLAO' THEN
        set v_origen= 'CALLAO';
    END IF;
    IF v_origen !='' OR v_origen IS NULL THEN
        SELECT ubigeo into n_origen_ubigeo FROM ubigeo_provincias
        WHERE provincia REGEXP CONCAT('\\b', UPPER(v_origen) , '\\b') limit 1;
        # SI NO SE ENCUENTRA LA PROVINCIA BUSCAR EL DISTRITO
        IF n_origen_ubigeo IS NULL THEN
            SELECT ubigeo into n_origen_ubigeo FROM ubigeo_distritos
            WHERE distrito REGEXP CONCAT('\\b', UPPER(v_origen) , '\\b') limit 1;
        end if;
    ELSE
        SET v_origen = NULL;
    END IF;

    IF v_destino ='PROV. CONST. DEL CALLAO' THEN
        set v_destino= 'CALLAO';
    END IF;

    IF v_destino !='' OR v_destino IS NULL THEN
        SELECT ubigeo into n_destino_ubigeo FROM ubigeo_provincias
        WHERE provincia REGEXP CONCAT('\\b', UPPER(v_destino) , '\\b') limit 1;
        # SI NO SE ENCUENTRA LA PROVINCIA BUSCAR EL DISTRITO
        IF n_destino_ubigeo IS NULL THEN
            SELECT ubigeo into n_destino_ubigeo FROM ubigeo_distritos
            WHERE distrito REGEXP CONCAT('\\b', UPPER(v_destino) , '\\b') limit 1;
        end if;
    ELSE
        SET v_destino = NULL;
    END IF;

    # convertir en null fechas vacias
    SET v_fin_descargue = NULLIF(v_fin_descargue, '');
    SET v_inicio_descargue = NULLIF(v_inicio_descargue, '');
    SET v_llegada_destino = NULLIF(v_llegada_destino, '');
    SET v_inicio_ruta = NULLIF(v_inicio_ruta, '');
    SET v_fin_de_carga = NULLIF(v_fin_de_carga, '');
    SET v_inicio_de_carga = NULLIF(v_inicio_de_carga, '');
    SET v_presenta_para_carga = NULLIF(v_presenta_para_carga, '');
    SET v_compromiso_carga = NULLIF(v_compromiso_carga, '');
    SET v_fecha_de_cargue = NULLIF(v_fecha_de_cargue, '');
    SET v_evento_fecha = NULLIF(v_evento_fecha, '');

    INSERT INTO referencias (
        ref,
        trt_id,
        conductor_id,
        coordinador_id,
        origen_txt,
        origen_ubigeo,
        origen_cliente_id,
        destino_txt,
        destino_ubigeo,
        destino_cliente_id,
        titulo_viaje,
        ruta_id,
        placa,
        fecha_despachador,
        fin_descargue,
        inicio_descargue,
        llegada_destino,
        inicio_ruta,
        fin_de_carga,
        inicio_de_carga,
        presenta_para_carga,
        compromiso_carga,
        fecha_de_cargue,

        monitoreo_finalizado,
        evento_actual,
        evento_actual_fecha
    ) VALUES (
    p_ref,     -- ref (PRIMARY KEY)
    n_trt_id,                  -- trt_id
    NULL,                -- conductor_id
    n_coordinador_id,
    v_origen,             -- origen_txt
    n_origen_ubigeo,           -- origen_ubigeo
    n_cliente_origen_id,                 -- origen_cliente_id
    v_destino,           -- destino_txt
    n_destino_ubigeo,           -- destino_ubigeo
    n_cliente_destino_id,                 -- destino_cliente_id
    NULL, -- titulo_viaje
    NULL,                  -- ruta_id
    v_placa,          -- placa
    null,  -- fecha_despachador
    v_fin_descargue,               -- fin_descargue
    v_inicio_descargue,               -- inicio_descargue
    v_llegada_destino,               -- qr_llegada_destino
    v_inicio_ruta,               -- inicio_ruta
    v_fin_de_carga,               -- fin_de_carga
    v_inicio_de_carga,               -- inicio_de_carga
    v_presenta_para_carga,  -- presenta_para_carga
    v_compromiso_carga,   -- compromiso_carga
    v_fecha_de_cargue,
    n_estado_finalizado,
    n_evento_id,
    v_evento_fecha
    )
    ON DUPLICATE KEY UPDATE
     trt_id = VALUES(trt_id),
     conductor_id = VALUES(conductor_id),
     origen_txt = VALUES(origen_txt),
     origen_ubigeo = VALUES(origen_ubigeo),
     origen_cliente_id = VALUES(origen_cliente_id),
     destino_txt = VALUES(destino_txt),
     destino_ubigeo = VALUES(destino_ubigeo),
     destino_cliente_id = VALUES(destino_cliente_id),
     titulo_viaje = VALUES(titulo_viaje),
     ruta_id = VALUES(ruta_id),
     placa = VALUES(placa),
     fecha_despachador = VALUES(fecha_despachador),
     fin_descargue = VALUES(fin_descargue),
     inicio_descargue = VALUES(inicio_descargue),
     llegada_destino = VALUES(llegada_destino),
     inicio_ruta = VALUES(inicio_ruta),
     fin_de_carga = VALUES(fin_de_carga),
     inicio_de_carga = VALUES(inicio_de_carga),
     presenta_para_carga = VALUES(presenta_para_carga),
     compromiso_carga = VALUES(compromiso_carga),
     fecha_de_cargue = VALUES(fecha_de_cargue),
     monitoreo_finalizado = VALUES(monitoreo_finalizado),
     evento_actual = VALUES(evento_actual),
     evento_actual_fecha = VALUES(evento_actual_fecha);

#     SELECT n_trt_id,n_trt_nombres,n_trt_nuevo ,
#            n_cliente_origen_id,n_cliente_origen_nombres,n_cliente_origen_nuevo,
#            n_cliente_destino_id,n_cliente_destino_nombres,n_cliente_destino_nuevo,
#            n_evento_id,n_evento_nombre,n_evento_etapa_id , n_origen_ubigeo , n_destino_ubigeo;


# ---------------FIN--------------------
END$$

DELIMITER ;




call sp_procesar_importacion_ref ('1027681','202605271519385245');
