-- ==============================================================
-- FutbolTrack - Pruebas Procedimiento Almacenado #4
-- Nombre   : Pruebas_sp_actualizar_estado_entrenamiento.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            del procedimiento sp_actualizar_estado_entrenamiento.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- --------------------------------------------------------------
-- PRUEBA 1: Actualización exitosa - Cambiar a 'cancelado'
-- --------------------------------------------------------------
CALL sp_actualizar_estado_entrenamiento(
    7,              -- param_id_entrenamiento (creado en pruebas anteriores)
    'cancelado',    -- param_nuevo_estado
    @resultado
);
SELECT @resultado AS resultado_prueba_1;

-- Verificar cambio
SELECT id_entrenamiento, estado FROM entrenamiento WHERE id_entrenamiento = 7;

-- --------------------------------------------------------------
-- PRUEBA 2: Error de Lógica - Transición no permitida
-- Intentar pasar de 'realizado' a 'programado' (Sesión 5 ya está realizada)
-- --------------------------------------------------------------
CALL sp_actualizar_estado_entrenamiento(
    5, 
    'programado', 
    @resultado
);
SELECT @resultado AS resultado_prueba_2;

-- --------------------------------------------------------------
-- PRUEBA 3: Error de Dominio - Estado inexistente
-- --------------------------------------------------------------
CALL sp_actualizar_estado_entrenamiento(
    7, 
    'aplazado',     -- No está en el ENUM ('programado', 'realizado', 'cancelado')
    @resultado
);
SELECT @resultado AS resultado_prueba_3;

-- --------------------------------------------------------------
-- PRUEBA 4: Error - Entrenamiento no existe
-- --------------------------------------------------------------
CALL sp_actualizar_estado_entrenamiento(
    999, 
    'realizado', 
    @resultado
);
SELECT @resultado AS resultado_prueba_4;

-- --------------------------------------------------------------
-- PRUEBA 5: Error - Parámetros nulos
-- --------------------------------------------------------------
CALL sp_actualizar_estado_entrenamiento(
    NULL, 
    NULL, 
    @resultado
);
SELECT @resultado AS resultado_prueba_5;
