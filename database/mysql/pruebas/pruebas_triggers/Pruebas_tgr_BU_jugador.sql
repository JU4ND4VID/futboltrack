-- ==============================================================
-- FutbolTrack - Pruebas Trigger #2
-- Nombre   : Pruebas_tgr_BU_jugador.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            del trigger tgr_BU_jugador (BEFORE UPDATE).
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- ==============================================================
-- PREPARACION: Insertar un jugador valido para realizar las
-- pruebas de actualizacion. (13 anios, Sub-15)
-- ==============================================================
INSERT INTO persona (identificacion, nombre, apellido)
VALUES ('1009200005', 'Lucas', 'Update');

INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
VALUES ('1009200005', '2012-05-10', 'Defensa', 1);

-- ---------------------------------------------------------------
-- PRUEBA 1: UPDATE valido - Cambio de posicion
-- No afecta la fecha ni la categoria, debe pasar sin activar 
-- errores de edad.
-- ---------------------------------------------------------------
UPDATE jugador 
   SET posicion = 'Portero' 
 WHERE identificacion_jugador = '1009200005';

SELECT 'PRUEBA 1 OK: Posicion actualizada correctamente' AS resultado;

-- ---------------------------------------------------------------
-- PRUEBA 2: UPDATE invalido - Cambio a categoria no apta
-- Lucas tiene 13 anios. Si lo intentamos pasar a Sub-11 (id=3, 
-- rango 9-11 anios), el trigger debe bloquearlo.
-- SQLSTATE esperado: 45012
-- ---------------------------------------------------------------
-- Descomentar la siguiente linea para probar (detendra la ejecucion del script)
-- UPDATE jugador 
--    SET id_categoria = 3 
--  WHERE identificacion_jugador = '1009200005';

-- ---------------------------------------------------------------
-- PRUEBA 3: UPDATE invalido - Modificar fecha de nacimiento
-- Si por error se cambia su fecha de nacimiento haciendolo de 
-- 9 anios (2017), ya no cumple con Sub-15.
-- SQLSTATE esperado: 45012
-- ---------------------------------------------------------------
-- Descomentar la siguiente linea para probar (detendra la ejecucion del script)
-- UPDATE jugador 
--    SET fecha_nacimiento = '2017-01-01' 
--  WHERE identificacion_jugador = '1009200005';

-- ---------------------------------------------------------------
-- VERIFICACION FINAL
-- Verificamos que los datos del jugador siguen intactos (salvo la
-- posicion que si fue un cambio valido).
-- ---------------------------------------------------------------
SELECT identificacion_jugador, fecha_nacimiento, posicion, id_categoria
  FROM jugador 
 WHERE identificacion_jugador = '1009200005';
