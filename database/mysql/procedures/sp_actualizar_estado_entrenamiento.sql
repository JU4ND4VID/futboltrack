-- ==============================================================
-- FutbolTrack - Procedimiento Almacenado #4
-- Nombre   : sp_actualizar_estado_entrenamiento
-- Proposito: Actualizar el estado de una sesión de entrenamiento.
--            Valida que el estado sea correcto y evita transiciones
--            incoherentes (ej. de realizado a programado).
-- Tablas   : entrenamiento
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_actualizar_estado_entrenamiento`$$

CREATE PROCEDURE `sp_actualizar_estado_entrenamiento`(
    IN  param_id_entrenamiento INT,
    IN  param_nuevo_estado     VARCHAR(45),
    OUT param_mensaje          VARCHAR(500)
)
COMMENT 'Actualiza el estado de un entrenamiento. Sin control transaccional interno.'

sp_main: BEGIN

    -- Declaración de variables (Nomenclatura del curso)
    DECLARE vn_existe_entren   INT         DEFAULT 0;
    DECLARE vv_estado_actual   VARCHAR(20) DEFAULT '';

    -- Manejo de excepciones
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET param_mensaje = 'ERROR: Excepcion inesperada en base de datos. Orquestador debe revertir.';
    END;

    -- ===========================================================
    -- PASO 1 - VALIDAR PARÁMETROS BÁSICOS
    -- ===========================================================

    -- 1.1 Validar nulos
    IF param_id_entrenamiento IS NULL OR param_id_entrenamiento <= 0 THEN
        SET param_mensaje = 'ERROR: El ID del entrenamiento es obligatorio y debe ser positivo.';
        LEAVE sp_main;
    END IF;

    IF TRIM(IFNULL(param_nuevo_estado, '')) = '' THEN
        SET param_mensaje = 'ERROR: El nuevo estado es obligatorio.';
        LEAVE sp_main;
    END IF;

    -- 1.2 Validación de dominio del Estado
    IF param_nuevo_estado NOT IN ('programado', 'realizado', 'cancelado') THEN
        SET param_mensaje = 'ERROR: Estado inválido. Valores aceptados: programado, realizado, cancelado.';
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 2 - LÓGICA DE NEGOCIO Y VALIDACIÓN DE ESTADO PREVIO
    -- ===========================================================

    -- 2.1 Verificar que el entrenamiento exista y obtener su estado actual
    SELECT COUNT(*), IFNULL(MAX(estado), '')
      INTO vn_existe_entren, vv_estado_actual
      FROM entrenamiento
     WHERE id_entrenamiento = param_id_entrenamiento;

    IF vn_existe_entren = 0 THEN
        SET param_mensaje = CONCAT('ERROR: No existe un entrenamiento con ID ', param_id_entrenamiento, '.');
        LEAVE sp_main;
    END IF;

    -- 2.2 Verificar que haya un cambio real
    IF vv_estado_actual = param_nuevo_estado THEN
        SET param_mensaje = CONCAT('Aviso: El entrenamiento ya se encuentra en estado "', vv_estado_actual, '". No se realizaron cambios.');
        LEAVE sp_main;
    END IF;

    -- 2.3 Prevenir transiciones ilógicas (respaldo a la lógica del trigger)
    IF vv_estado_actual = 'realizado' AND param_nuevo_estado = 'programado' THEN
        SET param_mensaje = 'ERROR DE LÓGICA: Un entrenamiento que ya fue "realizado" no puede volver a estar "programado".';
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 3 - ACTUALIZACIÓN (DML)
    -- ===========================================================
    
    UPDATE entrenamiento
       SET estado = param_nuevo_estado
     WHERE id_entrenamiento = param_id_entrenamiento;

    -- ===========================================================
    -- PASO 4 - MENSAJE DE EXITO AL PARAMETRO OUT
    -- ===========================================================
    SET param_mensaje = CONCAT(
        'OK: El estado del entrenamiento ID ', param_id_entrenamiento, 
        ' fue actualizado de "', vv_estado_actual, '" a "', param_nuevo_estado, '".'
    );

END$$

DELIMITER ;