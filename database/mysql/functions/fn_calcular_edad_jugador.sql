-- ==============================================================
-- FutbolTrack - Función #1
-- Nombre   : fn_calcular_edad_jugador
-- Proposito: Retorna la edad en años completos de un jugador
--            a partir de su fecha de nacimiento.
--            Usada por triggers y SPs para validar rangos.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP FUNCTION IF EXISTS `fn_calcular_edad_jugador`$$

CREATE FUNCTION `fn_calcular_edad_jugador`(
    param_fecha_nacimiento DATE
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
COMMENT 'Retorna la edad en años completos dado una fecha de nacimiento.'
BEGIN
    -- Declaración de variables locales (Nomenclatura del curso)
    DECLARE vn_edad INT DEFAULT 0;

    -- 1. Validación de parámetro de entrada
    IF param_fecha_nacimiento IS NULL THEN
        RETURN 0;
    END IF;

    -- 2. Lógica de negocio (Cálculo de años completos)
    SET vn_edad = TIMESTAMPDIFF(YEAR, param_fecha_nacimiento, CURDATE());

    -- 3. Retorno obligatorio del valor calculado
    RETURN vn_edad;
END$$

DELIMITER ;