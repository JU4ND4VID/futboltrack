-- ==============================================================
-- FutbolTrack - Procedimiento Almacenado #5
-- Nombre   : sp_eliminar_jugador
-- Proposito: Eliminar un jugador del sistema verificando primero
--            que no tenga asistencias asociadas (RF-JU04).
--            Elimina en cascada manual su acudiente y los
--            registros padre en la tabla persona para evitar
--            datos huerfanos.
-- Tablas   : jugador, acudiente, persona, asistencia
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_eliminar_jugador`$$

CREATE PROCEDURE `sp_eliminar_jugador`(
    IN  param_identificacion_jugador  VARCHAR(15),
    OUT param_mensaje                 VARCHAR(500)
)
COMMENT 'Elimina un jugador verificando restricciones de asistencia y limpiando datos huerfanos.'

sp_main: BEGIN

    -- Declaración de variables (Nomenclatura del curso)
    DECLARE vn_existe_jugador    INT          DEFAULT 0;
    DECLARE vn_tiene_asistencia  INT          DEFAULT 0;
    DECLARE vv_cedula_acudiente  VARCHAR(15)  DEFAULT NULL;
    DECLARE vn_acudiente_otros   INT          DEFAULT 0;
    DECLARE vv_nombre_jugador    VARCHAR(100) DEFAULT '';

    -- Manejo de excepciones
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET param_mensaje = 'ERROR: Excepcion inesperada en base de datos. Orquestador debe revertir.';
    END;

    -- ===========================================================
    -- PASO 1 - VALIDAR PARÁMETROS IN
    -- ===========================================================
    IF TRIM(IFNULL(param_identificacion_jugador, '')) = '' THEN
        SET param_mensaje = 'ERROR: La identificacion del jugador es obligatoria.';
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 2 - VALIDACIÓN DE EXISTENCIA E INTEGRIDAD (RF-JU04)
    -- ===========================================================
    
    -- 2.1 Verificar que el jugador exista
    SELECT COUNT(*) INTO vn_existe_jugador 
      FROM jugador 
     WHERE identificacion_jugador = param_identificacion_jugador;

    IF vn_existe_jugador = 0 THEN
        SET param_mensaje = CONCAT('ERROR: No se encontro ningun jugador con la identificacion ', param_identificacion_jugador);
        LEAVE sp_main;
    END IF;

    -- 2.2 Bloquear si tiene asistencias (Regla de negocio)
    SELECT COUNT(*) INTO vn_tiene_asistencia 
      FROM asistencia 
     WHERE identificacion_jugador = param_identificacion_jugador;

    IF vn_tiene_asistencia > 0 THEN
        SET param_mensaje = CONCAT('ERROR: No se puede eliminar el jugador. Tiene ', vn_tiene_asistencia, ' registro(s) de asistencia asociados.');
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 3 - RECUPERAR DATOS ANTES DE ELIMINAR
    -- ===========================================================
    
    -- Obtenemos el nombre para el mensaje final y la cedula de su acudiente
    SELECT a.cedula_acudiente, CONCAT(p.nombre, ' ', p.apellido)
      INTO vv_cedula_acudiente, vv_nombre_jugador
      FROM jugador j
      JOIN persona p ON j.identificacion_jugador = p.identificacion
      LEFT JOIN acudiente a ON j.identificacion_jugador = a.identificacion_jugador
     WHERE j.identificacion_jugador = param_identificacion_jugador
     LIMIT 1;

    -- ===========================================================
    -- PASO 4 - INSTRUCCIONES DML (Eliminación en Cascada Manual)
    -- ===========================================================

    -- A. Eliminar al acudiente asociado (Rompe FK hacia jugador)
    DELETE FROM acudiente WHERE identificacion_jugador = param_identificacion_jugador;

    -- B. Eliminar al jugador (Rompe FK hacia persona)
    DELETE FROM jugador WHERE identificacion_jugador = param_identificacion_jugador;

    -- C. Eliminar la persona base del jugador
    DELETE FROM persona WHERE identificacion = param_identificacion_jugador;

    -- D. Validar y limpiar la persona base del acudiente
    -- Solo se elimina de 'persona' si este acudiente no representa a otros jugadores en el sistema.
    IF vv_cedula_acudiente IS NOT NULL THEN
        SELECT COUNT(*) INTO vn_acudiente_otros 
          FROM acudiente 
         WHERE cedula_acudiente = vv_cedula_acudiente;
         
        IF vn_acudiente_otros = 0 THEN
            DELETE FROM persona WHERE identificacion = vv_cedula_acudiente;
        END IF;
    END IF;

    -- ===========================================================
    -- PASO 5 - ASIGNAR RESULTADO OUT
    -- ===========================================================
    SET param_mensaje = CONCAT('OK: El jugador ', vv_nombre_jugador, ' (', param_identificacion_jugador, ') y sus registros asociados fueron eliminados del sistema.');

END$$

DELIMITER ;