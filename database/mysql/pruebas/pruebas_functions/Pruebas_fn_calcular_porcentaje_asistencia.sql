-- ==============================================================
-- FutbolTrack - Pruebas Función #2
-- Nombre   : Pruebas_fn_calcular_porcentaje_asistencia.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            de la funcion fn_calcular_porcentaje_asistencia.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- --------------------------------------------------------------
-- PRUEBA 1: Jugador con asistencias registradas (Sub-15)
-- Santiago Gomez (1006748391): 3 presentes de 3 sesiones realizadas -> 100%
-- --------------------------------------------------------------
SELECT fn_calcular_porcentaje_asistencia('1006748391') AS pct_santiago_esperado_100;

-- --------------------------------------------------------------
-- PRUEBA 2: Jugador con una ausencia justificada/sin aviso
-- Daniel Martinez (1007123456): 2 presentes de 3 sesiones -> 66.67%
-- --------------------------------------------------------------
SELECT fn_calcular_porcentaje_asistencia('1007123456') AS pct_daniel_esperado_67;

-- --------------------------------------------------------------
-- PRUEBA 3: Jugador inexistente -> Debe retornar NULL
-- --------------------------------------------------------------
SELECT fn_calcular_porcentaje_asistencia('9999999999') AS pct_esperado_null;

-- --------------------------------------------------------------
-- PRUEBA 4: Reporte completo con alerta de baja asistencia (< 70%)
-- Este es el query que alimenta la vista del frontend en React.
-- Demuestra el uso de la función en la capa de datos (SELECT masivo).
-- --------------------------------------------------------------
SELECT
    CONCAT(p.nombre, ' ', p.apellido)                           AS jugador,
    c.nombre                                                    AS categoria,
    fn_calcular_porcentaje_asistencia(j.identificacion_jugador) AS pct_asistencia,
    CASE
        WHEN fn_calcular_porcentaje_asistencia(j.identificacion_jugador) IS NULL
             THEN 'Sin sesiones'
        WHEN fn_calcular_porcentaje_asistencia(j.identificacion_jugador) < 70
             THEN 'ALERTA - Baja asistencia'
        ELSE 'OK'
    END                                                         AS alerta
FROM jugador   j
JOIN persona   p ON j.identificacion_jugador = p.identificacion
JOIN categoria c ON j.id_categoria = c.id_categoria
ORDER BY c.id_categoria, pct_asistencia ASC;