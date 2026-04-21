-- ==============================================================
-- FutbolTrack - Procedimiento Almacenado #1
-- Nombre   : sp_registrar_jugador_completo
-- Proposito: Registrar un jugador y su acudiente en una unica
--            transaccion atomica. Si cualquier INSERT falla,
--            todos los cambios se revierten (ROLLBACK).
-- Tablas   : persona (x2), jugador, acudiente
-- Autor    : Juan David Pena  (DBA MySQL)
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- --------------------------------------------------------------
-- Parametros de entrada - Jugador:
--   p_identificacion_jugador : TI o CC del jugador
--   p_nombre_jugador         : Nombre(s) del jugador
--   p_apellido_jugador       : Apellido(s) del jugador
--   p_fecha_nacimiento       : Fecha de nacimiento YYYY-MM-DD
--   p_posicion               : Portero|Defensa|Mediocampista|Delantero
--   p_id_categoria           : FK hacia tabla categoria
-- Parametros de entrada - Acudiente:
--   p_cedula_acudiente       : CC del acudiente (adulto)
--   p_nombre_acudiente       : Nombre(s) del acudiente
--   p_apellido_acudiente     : Apellido(s) del acudiente
--   p_telefono_acudiente     : Telefono de contacto
--   p_parentesco             : Ej: Padre, Madre, Tutor legal
-- Parametro de salida:
--   p_mensaje                : Resultado: OK ... o ERROR ...
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
COMMENT 'Registra jugador y acudiente en transaccion atomica con validaciones.'

sp_main: BEGIN

    -- Declaración de variables (Nomenclatura del curso)
    DECLARE vn_edad_jugador    INT DEFAULT 0;
    DECLARE vn_edad_min        INT DEFAULT 0;
    DECLARE vn_edad_max        INT DEFAULT 0;
    DECLARE vv_cat_nombre      VARCHAR(60) DEFAULT '';
    DECLARE vn_cat_count       INT DEFAULT 0;
    DECLARE vn_existe_jugador  INT DEFAULT 0;
    DECLARE vn_existe_acudiente INT DEFAULT 0;

    -- Manejo de excepciones (Equivalente al EXCEPTION WHEN OTHERS de la guía)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET param_mensaje = 'ERROR: Excepcion inesperada en base de datos. Transaccion revertida.';
    END;

    -- ===========================================================
    -- PASO 1 - VALIDAR PARÁMETROS IN (Salida anticipada con LEAVE)
    -- ===========================================================

    -- 1.1 Campos obligatorios
    IF TRIM(IFNULL(param_identificacion_jugador, '')) = '' THEN
        SET param_mensaje = 'ERROR: La identificacion del jugador es obligatoria.';
        LEAVE sp_main; -- Simula el RETURN anticipado de Oracle
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
    -- PASO 2 - LÓGICA DE NEGOCIO (Consultas y validaciones)
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

    -- 2.3 Categoria existe (Capturamos agregados para evitar error si no existe)
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
    -- TRANSACCION ATOMICA (Ejecución de DML)
    -- ===========================================================
    START TRANSACTION;

        INSERT INTO persona (identificacion, nombre, apellido)
        VALUES (param_identificacion_jugador, TRIM(param_nombre_jugador), TRIM(param_apellido_jugador));

        INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
        VALUES (param_identificacion_jugador, param_fecha_nacimiento, param_posicion, param_id_categoria);

        INSERT INTO persona (identificacion, nombre, apellido)
        VALUES (param_cedula_acudiente, TRIM(param_nombre_acudiente), TRIM(param_apellido_acudiente));

        INSERT INTO acudiente (cedula_acudiente, telefono, parentesco, identificacion_jugador)
        VALUES (param_cedula_acudiente, param_telefono_acudiente, TRIM(param_parentesco), param_identificacion_jugador);

    COMMIT;

    -- ===========================================================
    -- PASO 3 - ASIGNAR RESULTADO OUT (Éxito)
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


-- ==============================================================
-- CASOS DE PRUEBA
-- ==============================================================

-- PRUEBA 1: Registro exitoso - jugador Sub-15 (13 anios)
CALL sp_registrar_jugador_completo(
    '1008100001', 'Tomas Alejandro', 'Bermudez Rios',
    '2012-06-15', 'Delantero', 1,
    '55100001', 'Gloria Ines', 'Rios Pacheco',
    '3164001001', 'Madre',
    @resultado
);
SELECT @resultado AS resultado_prueba_1;

-- PRUEBA 2: Error - jugador ya existe (identificacion duplicada)
CALL sp_registrar_jugador_completo(
    '1008100001', 'Tomas Alejandro', 'Bermudez Rios',
    '2012-06-15', 'Delantero', 1,
    '55100002', 'Luis Enrique', 'Bermudez Castro',
    '3164001002', 'Padre',
    @resultado
);
SELECT @resultado AS resultado_prueba_2;

-- PRUEBA 3: Error - identificaciones iguales
CALL sp_registrar_jugador_completo(
    '1008100003', 'Kevin Stiven', 'Lozano Mora',
    '2011-09-10', 'Mediocampista', 1,
    '1008100003', 'Carlos', 'Lozano',
    '3001230000', 'Padre',
    @resultado
);
SELECT @resultado AS resultado_prueba_3;

-- PRUEBA 4: Error - posicion invalida
CALL sp_registrar_jugador_completo(
    '1008100004', 'Brayan Stiven', 'Cardenas Mora',
    '2012-02-20', 'Extremo', 1,
    '55100004', 'Rosa Maria', 'Mora Gil',
    '3154001004', 'Madre',
    @resultado
);
SELECT @resultado AS resultado_prueba_4;

-- PRUEBA 5: Error - categoria inexistente
CALL sp_registrar_jugador_completo(
    '1008100005', 'Jhoan Sebastian', 'Pedraza Torres',
    '2012-04-11', 'Defensa', 99,
    '55100005', 'Ana Milena', 'Torres Blanco',
    '3114001005', 'Madre',
    @resultado
);
SELECT @resultado AS resultado_prueba_5;

-- PRUEBA 6: Error - edad fuera de rango (10 anios en Sub-15)
CALL sp_registrar_jugador_completo(
    '1008100006', 'Samuel David', 'Quintero Parra',
    '2016-01-25', 'Portero', 1,
    '55100006', 'Claudia Ximena', 'Parra Ramos',
    '3134001006', 'Madre',
    @resultado
);
SELECT @resultado AS resultado_prueba_6;

-- PRUEBA 7: Solo la prueba 1 debe aparecer persistida
SELECT
    p.identificacion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_completo,
    CASE
        WHEN j.identificacion_jugador IS NOT NULL THEN 'jugador'
        WHEN a.cedula_acudiente       IS NOT NULL THEN 'acudiente'
        ELSE '?'
    END AS rol
FROM      persona   p
LEFT JOIN jugador   j ON p.identificacion = j.identificacion_jugador
LEFT JOIN acudiente a ON p.identificacion = a.cedula_acudiente
WHERE p.identificacion IN (
    '1008100001','1008100003','1008100004',
    '1008100005','1008100006','55100001'
)
ORDER BY p.identificacion;