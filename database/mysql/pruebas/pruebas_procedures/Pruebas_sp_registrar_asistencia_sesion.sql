-- ==============================================================
-- FutbolTrack - Pruebas Procedimiento Almacenado #2
-- Nombre   : Pruebas_sp_registrar_asistencia_sesion.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            del procedimiento sp_registrar_asistencia_sesion.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- --------------------------------------------------------------
-- PRUEBA 1: Registro exitoso - entrenamiento 5 (Sub-15, programado)
-- 5 jugadores con estados variados.
-- --------------------------------------------------------------
CALL sp_registrar_asistencia_sesion(
    5,
    '[
        {"id": "1006748391", "estado": "presente",    "obs": ""},
        {"id": "1007123456", "estado": "presente",    "obs": ""},
        {"id": "1006987654", "estado": "justificado", "obs": "Cita medica, aviso con anticipacion"},
        {"id": "1007345678", "estado": "ausente",     "obs": "Sin notificacion previa"},
        {"id": "1006543210", "estado": "presente",    "obs": ""}
    ]',
    @resultado
);
SELECT @resultado AS resultado_prueba_1;

-- Verificar que el estado del entrenamiento 5 cambio a 'realizado'
SELECT id_entrenamiento, fecha, estado 
FROM entrenamiento 
WHERE id_entrenamiento = 5;

-- Verificar registros de asistencia insertados
SELECT a.identificacion_jugador,
       CONCAT(p.nombre, ' ', p.apellido) AS jugador,
       a.estado_asistencia,
       a.observacion
  FROM asistencia a
  JOIN persona p ON a.identificacion_jugador = p.identificacion
 WHERE a.id_entrenamiento = 5;

-- --------------------------------------------------------------
-- PRUEBA 2: Re-ejecucion (idempotente) - cambia estado de un jugador
-- El SP actualiza en vez de insertar duplicado.
-- --------------------------------------------------------------
CALL sp_registrar_asistencia_sesion(
    5,
    '[
        {"id": "1006748391", "estado": "presente",    "obs": ""},
        {"id": "1007123456", "estado": "presente",    "obs": ""},
        {"id": "1006987654", "estado": "justificado", "obs": "Cita medica, aviso con anticipacion"},
        {"id": "1007345678", "estado": "justificado", "obs": "Llego tarde por transporte, acepto justificacion"},
        {"id": "1006543210", "estado": "presente",    "obs": ""}
    ]',
    @resultado
);
SELECT @resultado AS resultado_prueba_2;

-- --------------------------------------------------------------
-- PRUEBA 3: Error - entrenamiento inexistente
-- El entrenamiento 99 no existe.
-- --------------------------------------------------------------
CALL sp_registrar_asistencia_sesion(
    99,
    '[{"id": "1006748391", "estado": "presente", "obs": ""}]',
    @resultado
);
SELECT @resultado AS resultado_prueba_3;

-- --------------------------------------------------------------
-- PRUEBA 4: Error - estado de asistencia invalido
-- Estado "tarde" no es valido.
-- --------------------------------------------------------------
CALL sp_registrar_asistencia_sesion(
    6,
    '[{"id": "1004567890", "estado": "tarde", "obs": ""}]',
    @resultado
);
SELECT @resultado AS resultado_prueba_4;

-- --------------------------------------------------------------
-- PRUEBA 5: Error - jugador no pertenece a la categoria
-- Entrenamiento 6 es Sub-17; jugador 1006748391 es Sub-15.
-- --------------------------------------------------------------
CALL sp_registrar_asistencia_sesion(
    6,
    '[{"id": "1006748391", "estado": "presente", "obs": ""}]',
    @resultado
);
SELECT @resultado AS resultado_prueba_5;

-- --------------------------------------------------------------
-- PRUEBA 6: Error - JSON vacio
-- --------------------------------------------------------------
CALL sp_registrar_asistencia_sesion(
    6,
    '[]',
    @resultado
);
SELECT @resultado AS resultado_prueba_6;