-- ==============================================================
-- FutbolTrack - Pruebas Trigger #3
-- Nombre   : Pruebas_tgr_AU_entrenamiento.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            del trigger tgr_AU_entrenamiento (AFTER UPDATE).
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- ---------------------------------------------------------------
-- PRUEBA 1: UPDATE que cambia el estado
-- Usaremos el entrenamiento ID 6 (que debe estar en 'programado') 
-- y lo pasaremos a 'cancelado'.
-- ---------------------------------------------------------------
UPDATE entrenamiento 
   SET estado = 'cancelado' 
 WHERE id_entrenamiento = 6;

SELECT 'PRUEBA 1 OK: Estado del entrenamiento 6 actualizado a cancelado' AS resultado;

-- ---------------------------------------------------------------
-- PRUEBA 2: UPDATE que NO cambia el estado
-- Actualizamos otro campo (ej. la hora_fin) del mismo entrenamiento, 
-- pero manteniendo el estado igual. El trigger NO debe registrar log.
-- ---------------------------------------------------------------
UPDATE entrenamiento 
   SET hora_fin = '12:00:00' 
 WHERE id_entrenamiento = 6;

SELECT 'PRUEBA 2 OK: Hora de fin actualizada sin cambiar el estado' AS resultado;

-- ---------------------------------------------------------------
-- VERIFICACION FINAL
-- Consultamos la tabla de auditoria log_entrenamiento.
-- Solo debe aparecer el registro del cambio de la Prueba 1.
-- ---------------------------------------------------------------
SELECT id_log, 
       id_entrenamiento, 
       estado_anterior, 
       estado_nuevo, 
       fecha_cambio, 
       usuario_db 
  FROM log_entrenamiento 
 ORDER BY id_log DESC;
