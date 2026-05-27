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
    DECLARE n_origen_ubigeo VARCHAR(4);
    DECLARE n_destino_ubigeo VARCHAR(4);


    SELECT ref,
           codigo, placa, empresa, cliente_destino, empresa_trt, monitoreo_finalizado,
           finalizado_por, status_actual, fecha_hora_status_actual, fin_descargue_fecha,
           inicio_descargue_fecha, llegada_a_destino_fecha, inicio_ruta_fecha, fin_de_carga_fecha,
           inicio_de_carga_fecha, presenta_para_carga_fecha, fecha_hora_compromiso_llegada,
           origen,destino
    INTO
        v_existe_ref,
        v_guia, v_placa, v_cliente_origen, v_cliente_destino, v_trt, v_monitoreo_finalizado,
        v_finalizado_por, v_status_actual, v_fecha_status_actual, v_fin_descargue,
        v_inicio_descargue, v_llegada_destino, v_inicio_ruta, v_fin_de_carga,
        v_inicio_de_carga, v_presenta_para_carga, v_compromiso_carga,
        v_origen,v_destino
    FROM tmp_refs
    WHERE ref = p_ref AND lote_id = p_lote_id
    LIMIT 1;

    IF v_existe_ref IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La referencia no existe';
    END IF;

    # ----------- BUSCAR TRT DE REF-------------------------------
    SELECT id,nombres INTO n_trt_id , n_trt_nombres FROM trts where nombres = v_trt;
    #comprobar si se encontro si no agregarlo ala tabla
    IF n_trt_id IS NULL THEN
        INSERT INTO trts (nombres,activo) VALUES (v_trt,1);
        SET n_trt_id = LAST_INSERT_ID();  -- Obtener el último ID insertado
        SET n_trt_nombres = v_trt;         -- Asignar el nombre
        set n_trt_nuevo = 1;
    END IF;
    # ----------------------------------------------------------------
    # -------------------BUSCAR CLIENTE--------------------------------
    SELECT id,nombres INTO n_cliente_origen_id , n_cliente_origen_nombres FROM clientes where nombres = v_cliente_origen;
    # comprobar si se encontro si no agregarlo ala tabla
    IF n_cliente_origen_id IS NULL THEN
        INSERT INTO clientes (nombres,activo) VALUES (v_cliente_origen,1);
        SET n_cliente_origen_id = LAST_INSERT_ID();  -- Obtener el último ID insertado
        SET n_cliente_origen_nombres = v_cliente_origen;         -- Asignar el nombre
        set n_cliente_origen_nuevo = 1;
    END IF;
    # cliente destino
    SELECT id,nombres INTO n_cliente_destino_id , n_cliente_destino_nombres FROM clientes where nombres = v_cliente_destino;
    IF n_cliente_destino_id IS NULL THEN
        INSERT INTO clientes (nombres,activo) VALUES (v_cliente_destino,1);
        SET n_cliente_destino_id = LAST_INSERT_ID();  -- Obtener el último ID insertado
        SET n_cliente_destino_nombres = v_cliente_origen;         -- Asignar el nombre
        set n_cliente_destino_nuevo = 1;
    END IF;
    # -----------------ESTADO---------------
    IF v_monitoreo_finalizado='FINALIZADO' THEN
        set n_estado_finalizado =1;
    END IF;
    # ---------------ESTADO ACTUAL-----------
    select id , etapa_id , nombre INTO n_evento_id , n_evento_etapa_id , n_evento_nombre
    from eventos where nombre= v_status_actual;
    # ----------------OBTENER ORIGEN , DESTINO UBIGEO provincia---------------------
    SELECT ubigeo into n_origen_ubigeo FROM ubigeo_provincias
    WHERE provincia REGEXP CONCAT('\\b', UPPER(v_origen) , '\\b');

    SELECT ubigeo into n_destino_ubigeo FROM ubigeo_provincias
    WHERE provincia REGEXP CONCAT('\\b', UPPER(v_destino) , '\\b');

    INSERT INTO referencias (
        ref,
        trt_id,
        conductor_id,
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
        compromiso_carga
    ) VALUES (
    p_ref,     -- ref (PRIMARY KEY)
    n_trt_id,                  -- trt_id
    NULL,                -- conductor_id
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
    v_compromiso_carga   -- compromiso_carga
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
     compromiso_carga = VALUES(compromiso_carga);

    SELECT n_trt_id,n_trt_nombres,n_trt_nuevo ,
           n_cliente_origen_id,n_cliente_origen_nombres,n_cliente_origen_nuevo,
           n_cliente_destino_id,n_cliente_destino_nombres,n_cliente_destino_nuevo,
           n_evento_id,n_evento_nombre,n_evento_etapa_id , n_origen_ubigeo , n_destino_ubigeo;


# ---------------FIN--------------------
END$$

DELIMITER ;




call sp_procesar_importacion_ref ('1022547','202605271519385245')
