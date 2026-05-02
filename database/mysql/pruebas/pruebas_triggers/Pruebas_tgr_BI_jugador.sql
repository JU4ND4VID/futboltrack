-- ==============================================================
-- FutbolTrack - Pruebas Trigger #1
-- Nombre   : Pruebas_tgr_BI_jugador.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            del trigger tgr_BI_jugador (BEFORE INSERT).
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- ==============================================================
-- LIMPIEZA PREVIA (Para permitir múltiples ejecuciones del script)
-- Se borran los registros de prueba de ejecuciones anteriores.
-- Primero de la tabla hija (jugador) y luego de la padre (persona).
-- ==============================================================
DELETE FROM jugador 
 WHERE identificacion_jugador IN ('1009200001', '1009200002', '1009200003', '1009200004');

DELETE FROM persona 
 WHERE identificacion IN ('1009200001', '1009200002', '1009200003', '1009200004');


-- ==============================================================
-- PREPARACION: Insercion directa en jugador (sin usar el SP) para 
-- demostrar que el trigger actua como segunda linea de defensa.
-- ==============================================================

-- ---------------------------------------------------------------
-- PRUEBA 1: INSERT valido - debe pasar sin errores
-- Jugador Sub-15 (13 anios), categoria 1 (13-15 anios)
-- ---------------------------------------------------------------
INSERT INTO persona (identificacion, nombre, apellido)
VALUES ('1009200001', 'Pipe', 'Ramirez Cano');

INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
VALUES ('1009200001', '2012-08-10', 'Defensa', 1);

SELECT 'PRUEBA 1 OK: Jugador insertado correctamente' AS resultado;

-- ---------------------------------------------------------------
-- PRUEBA 2: INSERT invalido - fecha de nacimiento futura
-- Debe lanzar TRIGGER ERROR con SQLSTATE 45010
-- ---------------------------------------------------------------
INSERT INTO persona (identificacion, nombre, apellido)
VALUES ('1009200002', 'Jugador', 'Futuro');

-- Descomentar la siguiente linea para probar (detendra la ejecucion del script en Workbench)
-- INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
-- VALUES ('1009200002', '2030-01-01', 'Portero', 1);

-- ---------------------------------------------------------------
-- PRUEBA 3: INSERT invalido - categoria inexistente
-- Debe lanzar TRIGGER ERROR con SQLSTATE 45011
-- ---------------------------------------------------------------
INSERT INTO persona (identificacion, nombre, apellido)
VALUES ('1009200003', 'Jugador', 'SinCategoria');

-- Descomentar la siguiente linea para probar (detendra la ejecucion del script)
-- INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
-- VALUES ('1009200003', '2012-03-15', 'Delantero', 99);

-- ---------------------------------------------------------------
-- PRUEBA 4: INSERT invalido - edad fuera del rango de categoria
-- Jugador de 10 anios en Sub-15 (requiere 13-15)
-- Debe lanzar TRIGGER ERROR con SQLSTATE 45012
-- ---------------------------------------------------------------
INSERT INTO persona (identificacion, nombre, apellido)
VALUES ('1009200004', 'Nino', 'MuyJoven');

-- Descomentar la siguiente linea para probar (detendra la ejecucion del script)
-- INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
-- VALUES ('1009200004', '2016-05-20', 'Mediocampista', 1);

-- ---------------------------------------------------------------
-- VERIFICACION FINAL
-- Solo el jugador de la prueba 1 debio insertarse.
-- ---------------------------------------------------------------
SELECT
    p.identificacion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_completo,
    CASE WHEN j.identificacion_jugador IS NOT NULL THEN 'Insertado OK'
         ELSE 'Solo en persona (Trigger bloqueo INSERT)'
    END AS estado
FROM persona p
LEFT JOIN jugador j ON p.identificacion = j.identificacion_jugador
WHERE p.identificacion IN ('1009200001','1009200002','1009200003','1009200004')
ORDER BY p.identificacion;