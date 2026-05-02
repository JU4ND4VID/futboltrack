-- ==============================================================
-- FutbolTrack - Pruebas Procedimiento Almacenado #5
-- Nombre   : Pruebas_sp_eliminar_jugador.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            del procedimiento sp_eliminar_jugador.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- --------------------------------------------------------------
-- PREPARACIÓN: Insertar un jugador de prueba que NO tenga 
-- asistencias para poder probar el borrado exitoso.
-- --------------------------------------------------------------
CALL sp_registrar_jugador_completo(
    '1008100099', 'Jugador', 'De Prueba',
    '2012-01-01', 'Defensa', 1,
    '55100099', 'Acudiente', 'De Prueba',
    '3000000000', 'Padre',
    @resultado_prep
);
SELECT @resultado_prep AS preparacion_crear_jugador;

-- --------------------------------------------------------------
-- PRUEBA 1: Registro exitoso - Eliminar jugador sin asistencias
-- Debe eliminar al jugador, a su acudiente y a las personas base.
-- --------------------------------------------------------------
CALL sp_eliminar_jugador(
    '1008100099', 
    @resultado
);
SELECT @resultado AS resultado_prueba_1;

-- Verificar que ya no existan en ninguna tabla
SELECT identificacion, nombre FROM persona WHERE identificacion IN ('1008100099', '55100099');
SELECT identificacion_jugador FROM jugador WHERE identificacion_jugador = '1008100099';
SELECT cedula_acudiente FROM acudiente WHERE cedula_acudiente = '55100099';

-- --------------------------------------------------------------
-- PRUEBA 2: Error de Integridad - Jugador con asistencias
-- Según RF-JU04, el sistema debe advertir/bloquear si tiene 
-- asistencias registradas. Usamos a Santiago Gómez (1006748391).
-- --------------------------------------------------------------
CALL sp_eliminar_jugador(
    '1006748391', 
    @resultado
);
SELECT @resultado AS resultado_prueba_2;

-- --------------------------------------------------------------
-- PRUEBA 3: Error - Jugador no existe
-- --------------------------------------------------------------
CALL sp_eliminar_jugador(
    '999999999', 
    @resultado
);
SELECT @resultado AS resultado_prueba_3;

-- --------------------------------------------------------------
-- PRUEBA 4: Error - Parámetro nulo
-- --------------------------------------------------------------
CALL sp_eliminar_jugador(
    NULL, 
    @resultado
);
SELECT @resultado AS resultado_prueba_4;
