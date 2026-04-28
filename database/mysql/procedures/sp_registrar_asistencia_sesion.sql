-- ==============================================================
-- FutbolTrack - Procedimiento Almacenado #2
-- Nombre   : sp_registrar_asistencia_sesion
-- Proposito: Registrar o actualizar la asistencia de multiples
--            jugadores en una sesion de entrenamiento usando
--            un JSON como entrada.
-- Tablas   : entrenamiento, jugador, asistencia
-- Autor    : Juan David Pena (DBA MySQL)
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_registrar_asistencia_sesion`$$

CREATE PROCEDURE `sp_registrar_asistencia_sesion`(
    IN  param_id_entrenamiento  INT,
    IN  param_json_asistencia   JSON,
    OUT param_mensaje           VARCHAR(500)
)
COMMENT 'Registra asistencia masiva via JSON. Sin control transaccional interno (delegado al llamador).'

sp_main: BEGIN

    -- 1. Declaracion de Variables (Nomenclatura del curso)
    DECLARE vn_existe_entren   INT          DEFAULT 0;
    DECLARE vv_estado_entren   VARCHAR(20)  DEFAULT '';
    DECLARE vn_id_categoria    INT          DEFAULT 0;
    DECLARE vv_cat_nombre      VARCHAR(60)  DEFAULT '';

    DECLARE vn_total_jugadores INT          DEFAULT 0;
    DECLARE vn_idx             INT          DEFAULT 0;
    DECLARE vv_id_jugador      VARCHAR(15)  DEFAULT '';
    DECLARE vv_estado_asist    VARCHAR(20)  DEFAULT '';
    DECLARE vv_observacion     TEXT;
    DECLARE vn_existe_jugador  INT          DEFAULT 0;
    DECLARE vn_cat_jugador     INT          DEFAULT 0;

    DECLARE vn_presentes       INT          DEFAULT 0;
    DECLARE vn_ausentes        INT          DEFAULT 0;
    DECLARE vn_justificados    INT          DEFAULT 0;

    -- Manejo de excepciones (Equivalente al EXCEPTION WHEN OTHERS)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- ¡OJO! Eliminado el ROLLBACK interno según estándares del curso.
        SET param_mensaje = 'ERROR: Excepcion inesperada en base de datos. Orquestador debe revertir.';
    END;

    -- ===========================================================
    -- PASO 1 - VALIDAR PARAMETROS (Salidas anticipadas con LEAVE)
    -- ===========================================================

    IF param_id_entrenamiento IS NULL OR param_id_entrenamiento <= 0 THEN
        SET param_mensaje = 'ERROR: El ID del entrenamiento es obligatorio y debe ser positivo.';
        LEAVE sp_main;
    END IF;

    IF param_json_asistencia IS NULL OR JSON_LENGTH(param_json_asistencia) = 0 THEN
        SET param_mensaje = 'ERROR: El JSON de asistencia es obligatorio y no puede estar vacio.';
        LEAVE sp_main;
    END IF;

    IF JSON_TYPE(param_json_asistencia) != 'ARRAY' THEN
        SET param_mensaje = 'ERROR: El parametro JSON debe ser un array. Ejemplo: [{"id":"123","estado":"presente","obs":""}]';
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 2 - VALIDAR EL ENTRENAMIENTO
    -- ===========================================================

    SELECT COUNT(*), IFNULL(MAX(estado), ''), IFNULL(MAX(id_categoria), 0)
      INTO vn_existe_entren, vv_estado_entren, vn_id_categoria
      FROM entrenamiento
     WHERE id_entrenamiento = param_id_entrenamiento;

    IF vn_existe_entren = 0 THEN
        SET param_mensaje = CONCAT('ERROR: No existe un entrenamiento con ID ', param_id_entrenamiento, '.');
        LEAVE sp_main;
    END IF;

    IF vv_estado_entren = 'cancelado' THEN
        SET param_mensaje = CONCAT('ERROR: El entrenamiento ID ', param_id_entrenamiento, ' esta cancelado.');
        LEAVE sp_main;
    END IF;

    SELECT IFNULL(MAX(nombre), '') INTO vv_cat_nombre
      FROM categoria WHERE id_categoria = vn_id_categoria;

    -- ===========================================================
    -- PASO 3 - VALIDAR CADA JUGADOR DEL JSON
    -- ===========================================================

    SET vn_total_jugadores = JSON_LENGTH(param_json_asistencia);
    SET vn_idx = 0;

    WHILE vn_idx < vn_total_jugadores DO

        SET vv_id_jugador   = JSON_UNQUOTE(JSON_EXTRACT(param_json_asistencia, CONCAT('$[', vn_idx, '].id')));
        SET vv_estado_asist = JSON_UNQUOTE(JSON_EXTRACT(param_json_asistencia, CONCAT('$[', vn_idx, '].estado')));

        IF vv_estado_asist NOT IN ('presente', 'ausente', 'justificado') THEN
            SET param_mensaje = CONCAT('ERROR: Estado invalido "', vv_estado_asist, '" para jugador ID ', vv_id_jugador);
            LEAVE sp_main;
        END IF;

        SELECT COUNT(*), IFNULL(MAX(id_categoria), 0)
          INTO vn_existe_jugador, vn_cat_jugador
          FROM jugador
         WHERE identificacion_jugador = vv_id_jugador;

        IF vn_existe_jugador = 0 THEN
            SET param_mensaje = CONCAT('ERROR: El jugador con ID "', vv_id_jugador, '" no existe en el sistema.');
            LEAVE sp_main;
        END IF;

        IF vn_cat_jugador != vn_id_categoria THEN
            SET param_mensaje = CONCAT('ERROR: El jugador ID "', vv_id_jugador, '" no pertenece a la categoria ', vv_cat_nombre, '.');
            LEAVE sp_main;
        END IF;

        SET vn_idx = vn_idx + 1;
    END WHILE;

    -- ===========================================================
    -- PASO 4 - UPSERT ASISTENCIA + CAMBIO DE ESTADO
    -- (El COMMIT será manejado por el backend/Python)
    -- ===========================================================
    
    SET vn_idx = 0;

    WHILE vn_idx < vn_total_jugadores DO

        SET vv_id_jugador   = JSON_UNQUOTE(JSON_EXTRACT(param_json_asistencia, CONCAT('$[', vn_idx, '].id')));
        SET vv_estado_asist = JSON_UNQUOTE(JSON_EXTRACT(param_json_asistencia, CONCAT('$[', vn_idx, '].estado')));
        SET vv_observacion  = JSON_UNQUOTE(JSON_EXTRACT(param_json_asistencia, CONCAT('$[', vn_idx, '].obs')));

        IF vv_observacion = '' OR vv_observacion = 'null' THEN
            SET vv_observacion = NULL;
        END IF;

        INSERT INTO asistencia (id_entrenamiento, identificacion_jugador, estado_asistencia, observacion)
        VALUES (param_id_entrenamiento, vv_id_jugador, vv_estado_asist, vv_observacion)
        ON DUPLICATE KEY UPDATE
            estado_asistencia = VALUES(estado_asistencia),
            observacion       = VALUES(observacion);

        IF vv_estado_asist = 'presente'    THEN SET vn_presentes    = vn_presentes    + 1; END IF;
        IF vv_estado_asist = 'ausente'     THEN SET vn_ausentes     = vn_ausentes     + 1; END IF;
        IF vv_estado_asist = 'justificado' THEN SET vn_justificados = vn_justificados + 1; END IF;

        SET vn_idx = vn_idx + 1;
    END WHILE;

    UPDATE entrenamiento
       SET estado = 'realizado'
     WHERE id_entrenamiento = param_id_entrenamiento
       AND estado = 'programado';

    -- ===========================================================
    -- PASO 5 - MENSAJE DE EXITO AL PARAMETRO OUT
    -- ===========================================================
    SET param_mensaje = CONCAT(
        'OK: Asistencia registrada para entrenamiento ID ', param_id_entrenamiento,
        ' (', vv_cat_nombre, '). Total: ', vn_total_jugadores, ' jugadores. ',
        'Presentes: ', vn_presentes, ' | Ausentes: ', vn_ausentes, ' | Justificados: ', vn_justificados, '.'
    );

END$$

DELIMITER ;