-- ==============================================================
-- FutbolTrack - Pruebas Función #4
-- Nombre   : Pruebas_fn_jugador_activo_en_categoria.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            de la funcion fn_jugador_activo_en_categoria.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- --------------------------------------------------------------
-- PRUEBA 1: Jugador pertenece a la categoría consultada
-- Santiago Gómez (1006748391) es de la categoría 1 (Sub-15)
-- Debe retornar 1 (Verdadero)
-- --------------------------------------------------------------
SELECT fn_jugador_activo_en_categoria('1006748391', 1) AS pertenece_categoria_1;

-- --------------------------------------------------------------
-- PRUEBA 2: Jugador NO pertenece a la categoría consultada
-- Santiago Gómez no pertenece a la categoría 2 (Sub-17)
-- Debe retornar 0 (Falso)
-- --------------------------------------------------------------
SELECT fn_jugador_activo_en_categoria('1006748391', 2) AS pertenece_categoria_2;

-- --------------------------------------------------------------
-- PRUEBA 3: Jugador inexistente
-- Debe retornar 0 (Falso)
-- --------------------------------------------------------------
SELECT fn_jugador_activo_en_categoria('9999999999', 1) AS jugador_inexistente;

-- --------------------------------------------------------------
-- PRUEBA 4: Parámetros NULL
-- Debe retornar 0 de forma segura.
-- --------------------------------------------------------------
SELECT fn_jugador_activo_en_categoria(NULL, NULL) AS parametros_null;

-- --------------------------------------------------------------
-- PRUEBA 5: Uso en consulta masiva (Filtro dinámico)
-- Demuestra cómo usar la función para evaluar a todos los jugadores.
-- --------------------------------------------------------------
SELECT 
    p.identificacion,
    CONCAT(p.nombre, ' ', p.apellido) AS jugador,
    c.nombre AS categoria_asignada,
    fn_jugador_activo_en_categoria(j.identificacion_jugador, 1) AS pertenece_a_sub15
FROM jugador j
JOIN persona p ON j.identificacion_jugador = p.identificacion
JOIN categoria c ON j.id_categoria = c.id_categoria;