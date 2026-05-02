-- ==============================================================
-- FutbolTrack - Pruebas Función #3
-- Nombre   : Pruebas_fn_contar_sesiones_categoria.sql
-- Proposito: Archivo separado para ejecutar los casos de prueba
--            de la funcion fn_contar_sesiones_categoria.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

-- --------------------------------------------------------------
-- PRUEBA 1: Categoría con sesiones registradas
-- Categoría 1 (Sub-15) tiene varias sesiones en la base de datos.
-- --------------------------------------------------------------
SELECT fn_contar_sesiones_categoria(1) AS total_sesiones_cat_1;

-- --------------------------------------------------------------
-- PRUEBA 2: Categoría con sesiones registradas
-- Categoría 2 (Sub-17) tiene varias sesiones en la base de datos.
-- --------------------------------------------------------------
SELECT fn_contar_sesiones_categoria(2) AS total_sesiones_cat_2;

-- --------------------------------------------------------------
-- PRUEBA 3: Categoría inexistente
-- Al no existir la categoría 99, debe retornar 0.
-- --------------------------------------------------------------
SELECT fn_contar_sesiones_categoria(99) AS total_sesiones_cat_99;

-- --------------------------------------------------------------
-- PRUEBA 4: Parámetro NULL
-- Debe retornar 0 de forma segura.
-- --------------------------------------------------------------
SELECT fn_contar_sesiones_categoria(NULL) AS total_sesiones_null;

-- --------------------------------------------------------------
-- PRUEBA 5: Uso de la función en un SELECT masivo
-- Útil para un reporte gerencial de la academia.
-- --------------------------------------------------------------
SELECT 
    c.id_categoria,
    c.nombre AS categoria,
    fn_contar_sesiones_categoria(c.id_categoria) AS total_entrenamientos_registrados
FROM categoria c
ORDER BY total_entrenamientos_registrados DESC;
