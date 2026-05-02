-- ==============================================================
-- FutbolTrack - Pruebas Función #1
-- Nombre   : Pruebas_fn_calcular_edad_jugador.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            de la funcion fn_calcular_edad_jugador.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- --------------------------------------------------------------
-- PRUEBA 1: Edad normal (nacido 2012-06-15 -> debe dar 13 años en 2026)
-- --------------------------------------------------------------
SELECT fn_calcular_edad_jugador('2012-06-15') AS edad_esperada_13;

-- --------------------------------------------------------------
-- PRUEBA 2: Fecha NULL -> debe retornar 0 para evitar errores
-- --------------------------------------------------------------
SELECT fn_calcular_edad_jugador(NULL) AS edad_esperada_0;

-- --------------------------------------------------------------
-- PRUEBA 3: Uso de la función dentro de un SELECT masivo
-- Calcula la edad en tiempo real de todos los jugadores registrados.
-- Esto demuestra que la función cumple el estándar de usabilidad
-- dentro de sentencias SQL (DML).
-- --------------------------------------------------------------
SELECT
    CONCAT(p.nombre, ' ', p.apellido)            AS jugador,
    j.fecha_nacimiento,
    fn_calcular_edad_jugador(j.fecha_nacimiento) AS edad_actual,
    c.nombre                                     AS categoria
FROM jugador   j
JOIN persona   p ON j.identificacion_jugador = p.identificacion
JOIN categoria c ON j.id_categoria = c.id_categoria
ORDER BY c.id_categoria, edad_actual;
