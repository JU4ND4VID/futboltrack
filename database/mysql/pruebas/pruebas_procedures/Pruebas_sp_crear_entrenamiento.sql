-- ==============================================================
-- FutbolTrack - Pruebas Procedimiento Almacenado #3
-- Nombre   : Pruebas_sp_crear_entrenamiento.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            del procedimiento sp_crear_entrenamiento.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- --------------------------------------------------------------
-- PRUEBA 1: Registro exitoso - Sesion Sub-15 / Fisico
-- Todos los parametros correctos. El estado debe ser 'programado'.
-- --------------------------------------------------------------
CALL sp_crear_entrenamiento(
    '2026-05-10',    -- param_fecha
    '08:00:00',      -- param_hora_inicio
    '10:00:00',      -- param_hora_fin
    'Físico',        -- param_tipo
    1,               -- param_id_lugar (Cancha Principal)
    1,               -- param_id_categoria (Sub-15)
    '1020485632',    -- param_cedula_entrenador (Carlos Herrera)
    @resultado
);
SELECT @resultado AS resultado_prueba_1;

-- --------------------------------------------------------------
-- PRUEBA 2: Error de Logica - Hora de inicio mayor a hora de fin
-- --------------------------------------------------------------
CALL sp_crear_entrenamiento(
    '2026-05-11', 
    '11:00:00',      -- Inicia tarde
    '09:00:00',      -- Termina temprano (Incoherencia)
    'Táctico', 1, 1, '1020485632', 
    @resultado
);
SELECT @resultado AS resultado_prueba_2;

-- --------------------------------------------------------------
-- PRUEBA 3: Error de Dominio - Tipo de sesion no valido
-- --------------------------------------------------------------
CALL sp_crear_entrenamiento(
    '2026-05-12', '15:00:00', '17:00:00', 
    'Piscina',       -- Tipo no existe en la regla de negocio
    2, 2, '52748901', 
    @resultado
);
SELECT @resultado AS resultado_prueba_3;

-- --------------------------------------------------------------
-- PRUEBA 4: Error de Integridad - Entrenador no existe
-- --------------------------------------------------------------
CALL sp_crear_entrenamiento(
    '2026-05-13', '08:00:00', '10:00:00', 'Mixto', 
    3, 2, 
    '999999999',     -- Cedula no registrada en tabla entrenador
    @resultado
);
SELECT @resultado AS resultado_prueba_4;

-- --------------------------------------------------------------
-- PRUEBA 5: Error de Integridad - Lugar no existe
-- --------------------------------------------------------------
CALL sp_crear_entrenamiento(
    '2026-05-14', '08:00:00', '10:00:00', 'Técnico', 
    99,              -- ID de lugar inexistente
    1, '1020485632', 
    @resultado
);
SELECT @resultado AS resultado_prueba_5;

-- --------------------------------------------------------------
-- VERIFICACION FINAL
-- Solo el entrenamiento de la Prueba 1 debio guardarse en la BD.
-- --------------------------------------------------------------
SELECT id_entrenamiento, fecha, hora_inicio, tipo, estado
FROM entrenamiento
ORDER BY id_entrenamiento DESC
LIMIT 3;
