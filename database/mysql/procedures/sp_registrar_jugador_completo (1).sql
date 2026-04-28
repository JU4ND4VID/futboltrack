-- ==============================================================
-- FutbolTrack - Procedimiento Almacenado #1
-- Nombre   : sp_registrar_jugador_completo
-- Proposito: Registrar un jugador y su acudiente en una unica
--            transaccion atomica (controlada por el orquestador).
-- Tablas   : persona (x2), jugador, acudiente
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- --------------------------------------------------------------
-- Parametros de entrada - Jugador:
--   param_identificacion_jugador : TI o CC del jugador
--   param_nombre_jugador         : Nombre(s) del jugador
--   param_apellido_jugador       : Apellido(s) del jugador
--   param_fecha_nacimiento       : Fecha de nacimiento YYYY-MM-DD
--   param_posicion               : Portero|Defensa|Mediocampista|Delantero
--   param_id_categoria           : FK hacia tabla categoria
-- Parametros de entrada - Acudiente:
--   param_cedula_acudiente       : CC del acudiente (adulto)
--   param_nombre_acudiente       : Nombre(s) del acudiente
--   param_apellido_acudiente     : Apellido(s) del acudiente
--   param_telefono_acudiente     : Telefono de contacto
--   param_parentesco             : Ej: Padre, Madre, Tutor legal
-- Parametro de salida:
--   param_mensaje                : Resultado: OK ... o ERROR ...
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_registrar_jugador_completo`$$

CREATE PROCEDURE `sp_registrar_jugador_completo`(
    IN  param_identificacion_jugador  VARCHAR(15),
    IN  param_nombre_jugador          VARCHAR(45),
    IN  param_apellido_jugador        VARCHAR(45),
    IN  param_fecha_nacimiento        DATE,
    IN  param_posicion                VARCHAR(20),
    IN  param_id_categoria            INT,
    IN  param_cedula_acudiente        VARCHAR(15),
    IN  param_nombre_acudiente        VARCHAR(45),
    IN  param_apellido_acudiente      VARCHAR(45),
    IN  param_telefono_acudiente      VARCHAR(20),
    IN  param_parentesco              VARCHAR(30),
    OUT param_mensaje                 VARCHAR(500)
)
COMMENT 'Registra jugador y acudiente. Sin control transaccional interno.'

sp_main: BEGIN

    -- Declaracion de variables (Nomenclatura del curso)
    DECLARE vn_edad_jugador    INT DEFAULT 0;
    DECLARE vn_edad_min        INT DEFAULT 0;
    DECLARE vn_edad_max        INT DEFAULT 0;
    DECLARE vv_cat_nombre      VARCHAR(60) DEFAULT '';
    DECLARE vn_cat_count       INT DEFAULT 0;
    DECLARE vn_existe_jugador  INT DEFAULT 0;
    DECLARE vn_existe_acudiente INT DEFAULT 0;

    -- Manejo de excepciones (Equivalente al EXCEPTION WHEN OTHERS de la guia)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET param_mensaje = 'ERROR: Excepcion inesperada en base de datos. Orquestador debe revertir.';
    END;

    -- ===========================================================
    -- PASO 1 - VALIDAR PARAMETROS IN (Salida anticipada con LEAVE)
    -- ===========================================================

    -- 1.1 Campos obligatorios
    IF TRIM(IFNULL(param_identificacion_jugador, '')) = '' THEN
        SET param_mensaje = 'ERROR: La identificacion del jugador es obligatoria.';
        LEAVE sp_main; -- Simula el RETURN anticipado
    END IF;

    IF TRIM(IFNULL(param_nombre_jugador, '')) = '' OR TRIM(IFNULL(param_apellido_jugador, '')) = '' THEN
        SET param_mensaje = 'ERROR: El nombre y apellido del jugador son obligatorios.';
        LEAVE sp_main;
    END IF;

    IF param_fecha_nacimiento IS NULL THEN
        SET param_mensaje = 'ERROR: La fecha de nacimiento es obligatoria.';
        LEAVE sp_main;
    END IF;

    IF TRIM(IFNULL(param_cedula_acudiente, '')) = '' THEN
        SET param_mensaje = 'ERROR: La cedula del acudiente es obligatoria.';
        LEAVE sp_main;
    END IF;

    IF TRIM(IFNULL(param_nombre_acudiente, '')) = '' OR TRIM(IFNULL(param_apellido_acudiente, '')) = '' THEN
        SET param_mensaje = 'ERROR: El nombre y apellido del acudiente son obligatorios.';
        LEAVE sp_main;
    END IF;

    IF TRIM(IFNULL(param_telefono_acudiente, '')) = '' THEN
        SET param_mensaje = 'ERROR: El telefono del acudiente es obligatorio.';
        LEAVE sp_main;
    END IF;

    -- 1.2 Identificaciones distintas
    IF param_identificacion_jugador = param_cedula_acudiente THEN
        SET param_mensaje = 'ERROR: La identificacion del jugador y la del acudiente no pueden ser iguales.';
        LEAVE sp_main;
    END IF;

    -- 1.3 Posicion valida
    IF param_posicion NOT IN ('Portero', 'Defensa', 'Mediocampista', 'Delantero') THEN
        SET param_mensaje = 'ERROR: Posicion invalida. Valores: Portero, Defensa, Mediocampista, Delantero.';
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 2 - LOGICA DE NEGOCIO (Consultas y validaciones)
    -- ===========================================================

    -- 2.1 Jugador no duplicado
    SELECT COUNT(*) INTO vn_existe_jugador FROM persona WHERE identificacion = param_identificacion_jugador;
    IF vn_existe_jugador > 0 THEN
        SET param_mensaje = 'ERROR: Ya existe una persona con esa identificacion de jugador.';
        LEAVE sp_main;
    END IF;

    -- 2.2 Acudiente no duplicado
    SELECT COUNT(*) INTO vn_existe_acudiente FROM persona WHERE identificacion = param_cedula_acudiente;
    IF vn_existe_acudiente > 0 THEN
        SET param_mensaje = 'ERROR: Ya existe una persona con esa cedula de acudiente.';
        LEAVE sp_main;
    END IF;

    -- 2.3 Categoria existe
    SELECT COUNT(*), IFNULL(MIN(edad_minima), 0), IFNULL(MAX(edad_maxima), 0), IFNULL(MAX(nombre), '')
      INTO vn_cat_count, vn_edad_min, vn_edad_max, vv_cat_nombre
      FROM categoria WHERE id_categoria = param_id_categoria;

    IF vn_cat_count = 0 THEN
        SET param_mensaje = 'ERROR: La categoria especificada no existe.';
        LEAVE sp_main;
    END IF;

    -- 2.4 Edad coherente con la categoria
    SET vn_edad_jugador = TIMESTAMPDIFF(YEAR, param_fecha_nacimiento, CURDATE());
    IF vn_edad_jugador < vn_edad_min OR vn_edad_jugador > vn_edad_max THEN
        SET param_mensaje = CONCAT('ERROR: El jugador tiene ', vn_edad_jugador, ' anio(s). ',
                                   'La categoria ', vv_cat_nombre, ' requiere entre ',
                                   vn_edad_min, ' y ', vn_edad_max, ' anios.');
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 3 - EJECUCION DE DML (Sin COMMIT interno)
    -- ===========================================================

    INSERT INTO persona (identificacion, nombre, apellido)
    VALUES (param_identificacion_jugador, TRIM(param_nombre_jugador), TRIM(param_apellido_jugador));

    INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
    VALUES (param_identificacion_jugador, param_fecha_nacimiento, param_posicion, param_id_categoria);

    INSERT INTO persona (identificacion, nombre, apellido)
    VALUES (param_cedula_acudiente, TRIM(param_nombre_acudiente), TRIM(param_apellido_acudiente));

    INSERT INTO acudiente (cedula_acudiente, telefono, parentesco, identificacion_jugador)
    VALUES (param_cedula_acudiente, param_telefono_acudiente, TRIM(param_parentesco), param_identificacion_jugador);

    -- ===========================================================
    -- PASO 4 - ASIGNAR RESULTADO OUT (Exito)
    -- ===========================================================
    SET param_mensaje = CONCAT(
        'OK: Jugador "', TRIM(param_nombre_jugador), ' ', TRIM(param_apellido_jugador),
        '" (', param_identificacion_jugador, ') registrado en ', vv_cat_nombre,
        ' como ', param_posicion, '. Acudiente "',
        TRIM(param_nombre_acudiente), ' ', TRIM(param_apellido_acudiente),
        '" vinculado. Parentesco: ', TRIM(param_parentesco), '.'
    );

END$$

DELIMITER ;