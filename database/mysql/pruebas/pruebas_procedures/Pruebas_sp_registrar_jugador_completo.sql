-- ==============================================================
-- FutbolTrack - Pruebas Procedimiento Almacenado #1
-- Nombre   : Pruebas_sp_registrar_jugador_completo.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            del procedimiento sp_registrar_jugador_completo.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- --------------------------------------------------------------
-- PRUEBA 1: Registro exitoso - jugador Sub-15 (13 anios)
-- --------------------------------------------------------------
CALL sp_registrar_jugador_completo(
    '1008100001', 'Tomas Alejandro', 'Bermudez Rios',
    '2012-06-15', 'Delantero', 1,
    '55100001', 'Gloria Ines', 'Rios Pacheco',
    '3164001001', 'Madre',
    @resultado
);
SELECT @resultado AS resultado_prueba_1;

-- --------------------------------------------------------------
-- PRUEBA 2: Error - jugador ya existe (identificacion duplicada)
-- --------------------------------------------------------------
CALL sp_registrar_jugador_completo(
    '1008100001', 'Tomas Alejandro', 'Bermudez Rios',
    '2012-06-15', 'Delantero', 1,
    '55100002', 'Luis Enrique', 'Bermudez Castro',
    '3164001002', 'Padre',
    @resultado
);
SELECT @resultado AS resultado_prueba_2;

-- --------------------------------------------------------------
-- PRUEBA 3: Error - identificaciones iguales
-- --------------------------------------------------------------
CALL sp_registrar_jugador_completo(
    '1008100003', 'Kevin Stiven', 'Lozano Mora',
    '2011-09-10', 'Mediocampista', 1,
    '1008100003', 'Carlos', 'Lozano',
    '3001230000', 'Padre',
    @resultado
);
SELECT @resultado AS resultado_prueba_3;

-- --------------------------------------------------------------
-- PRUEBA 4: Error - posicion invalida
-- --------------------------------------------------------------
CALL sp_registrar_jugador_completo(
    '1008100004', 'Brayan Stiven', 'Cardenas Mora',
    '2012-02-20', 'Extremo', 1,
    '55100004', 'Rosa Maria', 'Mora Gil',
    '3154001004', 'Madre',
    @resultado
);
SELECT @resultado AS resultado_prueba_4;

-- --------------------------------------------------------------
-- PRUEBA 5: Error - categoria inexistente
-- --------------------------------------------------------------
CALL sp_registrar_jugador_completo(
    '1008100005', 'Jhoan Sebastian', 'Pedraza Torres',
    '2012-04-11', 'Defensa', 99,
    '55100005', 'Ana Milena', 'Torres Blanco',
    '3114001005', 'Madre',
    @resultado
);
SELECT @resultado AS resultado_prueba_5;

-- --------------------------------------------------------------
-- PRUEBA 6: Error - edad fuera de rango (10 anios en Sub-15)
-- --------------------------------------------------------------
CALL sp_registrar_jugador_completo(
    '1008100006', 'Samuel David', 'Quintero Parra',
    '2016-01-25', 'Portero', 1,
    '55100006', 'Claudia Ximena', 'Parra Ramos',
    '3134001006', 'Madre',
    @resultado
);
SELECT @resultado AS resultado_prueba_6;

-- --------------------------------------------------------------
-- PRUEBA 7: Solo la prueba 1 debe aparecer persistida
-- --------------------------------------------------------------
SELECT
    p.identificacion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_completo,
    CASE
        WHEN j.identificacion_jugador IS NOT NULL THEN 'jugador'
        WHEN a.cedula_acudiente       IS NOT NULL THEN 'acudiente'
        ELSE '?'
    END AS rol
FROM      persona   p
LEFT JOIN jugador   j ON p.identificacion = j.identificacion_jugador
LEFT JOIN acudiente a ON p.identificacion = a.cedula_acudiente
WHERE p.identificacion IN (
    '1008100001','1008100003','1008100004',
    '1008100005','1008100006','55100001'
)
ORDER BY p.identificacion;
