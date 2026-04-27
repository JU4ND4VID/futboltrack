-- ==============================================================
-- FutbolTrack - Función #4
-- Nombre   : fn_jugador_activo_en_categoria
-- Proposito: Verifica si un jugador especifico pertenece a una 
--            categoría determinada. Retorna 1 (Verdadero) o 0 (Falso).
--            Útil para validaciones previas de negocio en el backend.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP FUNCTION IF EXISTS `fn_jugador_activo_en_categoria`$$

CREATE FUNCTION `fn_jugador_activo_en_categoria`(
    param_identificacion_jugador VARCHAR(15),
    param_id_categoria           INT
)
RETURNS INT
READS SQL DATA
COMMENT 'Retorna 1 si el jugador pertenece a la categoría, 0 en caso contrario.'
BEGIN
    -- Declaración de variables locales (Nomenclatura del curso)
    DECLARE vn_pertenece INT DEFAULT 0;

    -- 1. Validación de parámetros de entrada
    IF param_identificacion_jugador IS NULL OR param_id_categoria IS NULL THEN
        RETURN 0;
    END IF;

    -- 2. Lógica de negocio (Conteo de coincidencia)
    SELECT COUNT(*)
      INTO vn_pertenece
      FROM jugador
     WHERE identificacion_jugador = param_identificacion_jugador
       AND id_categoria = param_id_categoria;

    -- 3. Retorno obligatorio
    -- Si el conteo es mayor a 0, la coincidencia existe (1). Si no, es falso (0).
    IF vn_pertenece > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;

END$$

DELIMITER ;