DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_procesar_lote`$$

CREATE PROCEDURE `sp_procesar_lote`(
    IN p_lote_id VARCHAR(100)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_ref VARCHAR(100);
    DECLARE v_continue BOOLEAN DEFAULT TRUE;
    DECLARE cur CURSOR FOR
        SELECT ref FROM tmp_refs
        WHERE lote_id=p_lote_id ;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_continue = FALSE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_ref;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Intentar actualizar, si hay error continua con el siguiente
        BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
                BEGIN
                    SELECT CONCAT('Error omitido en ref: ', v_ref) AS advertencia;
                END;
            CALL sp_procesar_importacion_ref(v_ref,p_lote_id);
        END;

    END LOOP;

    CLOSE cur;

    SELECT 'Proceso completado. Se omitieron errores.' AS mensaje;

END$$

DELIMITER ;
CALL sp_procesar_lote('202605271519385245');
