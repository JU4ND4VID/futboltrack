-- ==============================================================
-- FutbolTrack - Función #3
-- Nombre   : fn_contar_sesiones_categoria
-- Proposito: Retorna la cantidad total de sesiones de entrenamiento
--            (programadas y realizadas) asociadas a una categoria.
--            Útil para reportes de cobertura y tableros de control.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP FUNCTION IF EXISTS `fn_contar_sesiones_categoria`$$

CREATE FUNCTION `fn_contar_sesiones_categoria`(
    param_id_categoria INT
)
RETURNS INT
READS SQL DATA
COMMENT 'Retorna el total de sesiones registradas para una categoría específica.'
BEGIN
    -- Declaración de variables locales (Nomenclatura del curso)
    DECLARE vn_total_sesiones INT DEFAULT 0;

    -- 1. Validación de parámetro de entrada
    IF param_id_categoria IS NULL OR param_id_categoria <= 0 THEN
        RETURN 0;
    END IF;

    -- 2. Lógica de negocio (Conteo)
    -- Contamos todas las sesiones excepto las canceladas
    SELECT COUNT(*)
      INTO vn_total_sesiones
      FROM entrenamiento
     WHERE id_categoria = param_id_categoria
       AND estado IN ('programado', 'realizado');

    -- 3. Retorno obligatorio del valor calculado
    RETURN vn_total_sesiones;

END$$

DELIMITER ;