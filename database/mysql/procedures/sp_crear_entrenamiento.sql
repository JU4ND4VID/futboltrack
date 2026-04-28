-- ==============================================================
-- FutbolTrack - Procedimiento Almacenado #3
-- Nombre   : sp_crear_entrenamiento
-- Proposito: Registra una nueva sesión de entrenamiento. 
--            Valida coherencia de horas, dominios permitidos y
--            existencia de las llaves foráneas.
-- Tablas   : entrenamiento, lugar, categoria, entrenador
-- Autor    : Nicolas Matheus (DBA MySQL)
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_crear_entrenamiento`$$

CREATE PROCEDURE `sp_crear_entrenamiento`(
    IN  param_fecha               DATE,
    IN  param_hora_inicio         TIME,
    IN  param_hora_fin            TIME,
    IN  param_tipo                VARCHAR(45),
    IN  param_id_lugar            INT,
    IN  param_id_categoria        INT,
    IN  param_cedula_entrenador   VARCHAR(15),
    OUT param_mensaje             VARCHAR(500)
)
COMMENT 'Crea un entrenamiento. Sin control transaccional interno.'

sp_main: BEGIN

    -- Declaración de variables (Nomenclatura del curso)
    DECLARE vn_existe_lugar       INT         DEFAULT 0;
    DECLARE vn_existe_categoria   INT         DEFAULT 0;
    DECLARE vn_existe_entrenador  INT         DEFAULT 0;
    DECLARE vv_estado_defecto     VARCHAR(20) DEFAULT 'programado';

    -- Manejo de excepciones
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET param_mensaje = 'ERROR: Excepcion inesperada en base de datos. Orquestador debe revertir.';
    END;

    -- ===========================================================
    -- PASO 1 - VALIDAR PARÁMETROS BÁSICOS Y DE NEGOCIO
    -- ===========================================================

    -- 1.1 Validar nulos
    IF param_fecha IS NULL THEN
        SET param_mensaje = 'ERROR: La fecha del entrenamiento es obligatoria.';
        LEAVE sp_main;
    END IF;

    IF param_hora_inicio IS NULL OR param_hora_fin IS NULL THEN
        SET param_mensaje = 'ERROR: Las horas de inicio y fin son obligatorias.';
        LEAVE sp_main;
    END IF;

    IF param_id_lugar IS NULL OR param_id_categoria IS NULL OR TRIM(IFNULL(param_cedula_entrenador, '')) = '' THEN
        SET param_mensaje = 'ERROR: Lugar, categoría y entrenador son obligatorios.';
        LEAVE sp_main;
    END IF;

    -- 1.2 Coherencia de horas
    IF param_hora_inicio >= param_hora_fin THEN
        SET param_mensaje = 'ERROR: La hora de inicio debe ser estrictamente anterior a la hora de fin.';
        LEAVE sp_main;
    END IF;

    -- 1.3 Validación de dominio del Tipo (Físico, Táctico, Técnico, Mixto)
    IF param_tipo NOT IN ('Físico', 'Táctico', 'Técnico', 'Mixto') THEN
        SET param_mensaje = 'ERROR: Tipo de sesión inválido. Valores aceptados: Físico, Táctico, Técnico, Mixto.';
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 2 - VALIDAR INTEGRIDAD REFERENCIAL (FKs)
    -- ===========================================================

    -- 2.1 Validar existencia del lugar
    SELECT COUNT(*) INTO vn_existe_lugar FROM lugar WHERE id_lugar = param_id_lugar;
    IF vn_existe_lugar = 0 THEN
        SET param_mensaje = CONCAT('ERROR: El lugar de entrenamiento con ID ', param_id_lugar, ' no existe en el sistema.');
        LEAVE sp_main;
    END IF;

    -- 2.2 Validar existencia de la categoría
    SELECT COUNT(*) INTO vn_existe_categoria FROM categoria WHERE id_categoria = param_id_categoria;
    IF vn_existe_categoria = 0 THEN
        SET param_mensaje = CONCAT('ERROR: La categoria con ID ', param_id_categoria, ' no existe.');
        LEAVE sp_main;
    END IF;

    -- 2.3 Validar existencia del entrenador
    SELECT COUNT(*) INTO vn_existe_entrenador FROM entrenador WHERE cedula_entrenador = param_cedula_entrenador;
    IF vn_existe_entrenador = 0 THEN
        SET param_mensaje = CONCAT('ERROR: El entrenador con cedula ', param_cedula_entrenador, ' no esta registrado.');
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 3 - INSERCIÓN DML
    -- (El COMMIT será manejado por el backend/Python)
    -- ===========================================================
    
    INSERT INTO entrenamiento (
        fecha, 
        hora_inicio, 
        hora_fin, 
        tipo, 
        estado, 
        id_lugar, 
        id_categoria, 
        cedula_entrenador
    ) VALUES (
        param_fecha, 
        param_hora_inicio, 
        param_hora_fin, 
        param_tipo, 
        vv_estado_defecto,  -- Siempre nace como 'programado'
        param_id_lugar, 
        param_id_categoria, 
        param_cedula_entrenador
    );

    -- ===========================================================
    -- PASO 4 - MENSAJE DE EXITO AL PARAMETRO OUT
    -- ===========================================================
    SET param_mensaje = CONCAT(
        'OK: Entrenamiento (', param_tipo, ') programado exitosamente para el ', 
        param_fecha, ' de ', param_hora_inicio, ' a ', param_hora_fin, 
        '. ID Generado: ', LAST_INSERT_ID()
    );

END$$

DELIMITER ;