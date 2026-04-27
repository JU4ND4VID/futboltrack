-- ==============================================================
-- FutbolTrack - Función #2
-- Nombre   : fn_calcular_porcentaje_asistencia
-- Proposito: Calcula el porcentaje de asistencia de un jugador
--            sobre el total de sesiones realizadas de su categoria.
--            Un jugador se considera "presente" solo con estado
--            'presente'. 'justificado' o 'ausente' no suman al
--            porcentaje de asistencia efectiva.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP FUNCTION IF EXISTS `fn_calcular_porcentaje_asistencia`$$

CREATE FUNCTION `fn_calcular_porcentaje_asistencia`(
    param_id_jugador VARCHAR(15)
)
RETURNS DECIMAL(5,2)
READS SQL DATA
COMMENT 'Retorna el % de asistencia (presentes / sesiones realizadas) de un jugador.'
BEGIN
    -- Declaración de variables locales (Nomenclatura del curso)
    DECLARE vn_total_sesiones  INT DEFAULT 0;
    DECLARE vn_total_presentes INT DEFAULT 0;
    DECLARE vn_existe_jugador  INT DEFAULT 0;
    DECLARE vn_id_categoria    INT DEFAULT 0;
    
    -- Variable vdo_ para tipos Double/Decimal
    DECLARE vdo_porcentaje     DECIMAL(5,2);

    -- ===========================================================
    -- PASO 1 - VALIDACIÓN: Verificar que el jugador existe
    -- ===========================================================
    SELECT COUNT(*), IFNULL(MAX(id_categoria), 0)
      INTO vn_existe_jugador, vn_id_categoria
      FROM jugador
     WHERE identificacion_jugador = param_id_jugador;

    IF vn_existe_jugador = 0 THEN
        RETURN NULL;
    END IF;

    -- ===========================================================
    -- PASO 2 - LÓGICA: Contar sesiones totales REALIZADAS
    -- ===========================================================
    SELECT COUNT(*)
      INTO vn_total_sesiones
      FROM entrenamiento
     WHERE id_categoria = vn_id_categoria
       AND estado = 'realizado';

    -- Si no hay sesiones realizadas, no hay porcentaje que calcular (evita división por cero)
    IF vn_total_sesiones = 0 THEN
        RETURN NULL;
    END IF;

    -- ===========================================================
    -- PASO 3 - LÓGICA: Contar asistencias marcadas como 'presente'
    -- ===========================================================
    SELECT COUNT(*)
      INTO vn_total_presentes
      FROM asistencia     a
      JOIN entrenamiento  e ON a.id_entrenamiento = e.id_entrenamiento
     WHERE a.identificacion_jugador = param_id_jugador
       AND a.estado_asistencia      = 'presente'
       AND e.estado                 = 'realizado';

    -- ===========================================================
    -- PASO 4 - CÁLCULO FINAL Y RETORNO
    -- ===========================================================
    SET vdo_porcentaje = ROUND((vn_total_presentes / vn_total_sesiones) * 100, 2);
    
    RETURN vdo_porcentaje;

END$$

DELIMITER ;