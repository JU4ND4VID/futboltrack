-- ==============================================================
-- FutbolTrack - Funciones
-- Materia : Bases de Datos II - Universidad El Bosque
-- Fecha   : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

-- ==============================================================
/* AUTOR: Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
   FECHA: Abril 2026
   DESCRIPCION: Retorna la edad en años completos de un jugador
                a partir de su fecha de nacimiento.
                Usada por triggers y SPs para validar rangos.
*/
-- ==============================================================

DROP FUNCTION IF EXISTS `fn_calcular_edad_jugador`$$

CREATE FUNCTION `fn_calcular_edad_jugador`(
    param_fecha_nacimiento DATE
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    -- Si la fecha es nula retorna 0 para evitar errores en quien la llame
    IF param_fecha_nacimiento IS NULL THEN
        RETURN 0;
    END IF;

    -- TIMESTAMPDIFF con YEAR calcula años completos correctamente
    -- Ejemplo: nacido 2012-12-31, hoy 2026-04-24 -> 13 años (no 14)
    RETURN TIMESTAMPDIFF(YEAR, param_fecha_nacimiento, CURDATE());
END$$


-- ==============================================================
/* AUTOR: Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
   FECHA: Abril 2026
   DESCRIPCION: Calcula el porcentaje de asistencia de un jugador
                sobre el total de sesiones realizadas de su categoria.
                Retorna NULL si el jugador no existe o no hay sesiones.
*/
-- ==============================================================

DROP FUNCTION IF EXISTS `fn_calcular_porcentaje_asistencia`$$

CREATE FUNCTION `fn_calcular_porcentaje_asistencia`(
    param_id_jugador VARCHAR(15)
)
RETURNS DECIMAL(5,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    -- Declaración de variables usando nomenclatura del curso
    DECLARE vn_total_sesiones  INT DEFAULT 0;
    DECLARE vn_total_presentes INT DEFAULT 0;
    DECLARE vn_existe_jugador  INT DEFAULT 0;
    DECLARE vn_id_categoria    INT DEFAULT 0;
    
    -- Se declara variable 'vdo_' para el resultado decimal/doble
    DECLARE vdo_porcentaje     DECIMAL(5,2);

    -- 1. Validar que el jugador existe y obtener su categoria
    SELECT COUNT(*), IFNULL(MAX(id_categoria), 0)
      INTO vn_existe_jugador, vn_id_categoria
      FROM jugador
     WHERE identificacion_jugador = param_id_jugador;

    IF vn_existe_jugador = 0 THEN
        RETURN NULL;
    END IF;

    -- 2. Total de sesiones REALIZADAS de la categoria del jugador
    SELECT COUNT(*)
      INTO vn_total_sesiones
      FROM entrenamiento
     WHERE id_categoria = vn_id_categoria
       AND estado = 'realizado';

    IF vn_total_sesiones = 0 THEN
        RETURN NULL;
    END IF;

    -- 3. Total de registros con estado 'presente' para ese jugador
    SELECT COUNT(*)
      INTO vn_total_presentes
      FROM asistencia     a
      JOIN entrenamiento  e ON a.id_entrenamiento = e.id_entrenamiento
     WHERE a.identificacion_jugador = param_id_jugador
       AND a.estado_asistencia      = 'presente'
       AND e.estado                 = 'realizado';

    -- 4. Cálculo matemático usando la variable double (vdo_) y Return
    SET vdo_porcentaje = ROUND((vn_total_presentes / vn_total_sesiones) * 100, 2);
    
    RETURN vdo_porcentaje;

END$$

DELIMITER ;


-- ==============================================================
-- CASOS DE PRUEBA
-- ==============================================================

-- ---------------------------------------------------------------
-- PRUEBA fn_calcular_edad_jugador
-- ---------------------------------------------------------------

-- PRUEBA 1: Edad normal (nacido 2012-06-15 -> debe dar 13 años en 2026)
SELECT fn_calcular_edad_jugador('2012-06-15') AS edad_esperada_13;

-- PRUEBA 2: Fecha NULL -> debe retornar 0
SELECT fn_calcular_edad_jugador(NULL) AS edad_esperada_0;

-- PRUEBA 3: Edad de todos los jugadores registrados
SELECT
    CONCAT(p.nombre, ' ', p.apellido)    AS jugador,
    j.fecha_nacimiento,
    fn_calcular_edad_jugador(j.fecha_nacimiento) AS edad_actual,
    c.nombre                             AS categoria
FROM jugador   j
JOIN persona   p ON j.identificacion_jugador = p.identificacion
JOIN categoria c ON j.id_categoria = c.id_categoria
ORDER BY c.id_categoria, edad_actual;


-- ---------------------------------------------------------------
-- PRUEBA fn_calcular_porcentaje_asistencia
-- ---------------------------------------------------------------

-- PRUEBA 4: Jugador con asistencias registradas (Sub-15)
-- Santiago Gomez: 2 presentes de 2 sesiones realizadas -> 100%
SELECT fn_calcular_porcentaje_asistencia('1006748391') AS pct_santiago_esperado_100;

-- PRUEBA 5: Jugador con una ausencia
-- Daniel Martinez: 1 presente de 2 sesiones -> 50%
SELECT fn_calcular_porcentaje_asistencia('1007123456') AS pct_daniel_esperado_50;

-- PRUEBA 6: Jugador inexistente -> NULL
SELECT fn_calcular_porcentaje_asistencia('9999999999') AS pct_esperado_null;

-- PRUEBA 7: Reporte completo con alerta de baja asistencia (< 70%)
-- Este es el query que alimenta la vista del frontend
SELECT
    CONCAT(p.nombre, ' ', p.apellido)                        AS jugador,
    c.nombre                                                 AS categoria,
    fn_calcular_porcentaje_asistencia(j.identificacion_jugador) AS pct_asistencia,
    CASE
        WHEN fn_calcular_porcentaje_asistencia(j.identificacion_jugador) IS NULL
             THEN 'Sin sesiones'
        WHEN fn_calcular_porcentaje_asistencia(j.identificacion_jugador) < 70
             THEN 'ALERTA - Baja asistencia'
        ELSE 'OK'
    END                                                      AS alerta
FROM jugador   j
JOIN persona   p ON j.identificacion_jugador = p.identificacion
JOIN categoria c ON j.id_categoria = c.id_categoria
ORDER BY c.id_categoria, pct_asistencia ASC;