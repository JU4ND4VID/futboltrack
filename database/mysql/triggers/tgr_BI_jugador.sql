-- ==============================================================
-- FutbolTrack - Trigger #1
-- Nombre   : tgr_BI_jugador
-- Tipo     : BEFORE INSERT en tabla jugador
-- Proposito: Intercepta cualquier INSERT en jugador y valida
--            que la edad del jugador este dentro del rango
--            permitido por su categoria ANTES de persistir.
--            Actua como segunda linea de defensa.
-- Depende  : fn_calcular_edad_jugador, tabla categoria
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP TRIGGER IF EXISTS `tgr_BI_jugador`$$

CREATE TRIGGER `tgr_BI_jugador`
BEFORE INSERT ON `jugador`
FOR EACH ROW
BEGIN
    -- Declaración de variables locales
    DECLARE vn_edad_jugador   INT          DEFAULT 0;
    DECLARE vn_edad_min       INT          DEFAULT 0;
    DECLARE vn_edad_max       INT          DEFAULT 0;
    DECLARE vv_cat_nombre     VARCHAR(60)  DEFAULT '';
    DECLARE vn_cat_count      INT          DEFAULT 0;
    
    -- Variable para almacenar el mensaje concatenado antes del SIGNAL
    DECLARE vv_mensaje_error  VARCHAR(255) DEFAULT '';

    -- -------------------------------------------------------
    -- VALIDACION 1: Fecha de nacimiento no puede ser futura
    -- -------------------------------------------------------
    IF NEW.fecha_nacimiento >= CURDATE() THEN
        SIGNAL SQLSTATE '45010'
            SET MESSAGE_TEXT = 'TRIGGER ERROR: La fecha de nacimiento no puede ser una fecha futura.';
    END IF;

    -- -------------------------------------------------------
    -- VALIDACION 2: La categoria debe existir
    -- -------------------------------------------------------
    SELECT COUNT(*), IFNULL(MIN(edad_minima), 0), IFNULL(MAX(edad_maxima), 0), IFNULL(MAX(nombre), '')
      INTO vn_cat_count, vn_edad_min, vn_edad_max, vv_cat_nombre
      FROM categoria
     WHERE id_categoria = NEW.id_categoria;

    IF vn_cat_count = 0 THEN
        SIGNAL SQLSTATE '45011'
            SET MESSAGE_TEXT = 'TRIGGER ERROR: La categoria especificada no existe.';
    END IF;

    -- -------------------------------------------------------
    -- VALIDACION 3: Edad coherente con el rango de la categoria
    -- -------------------------------------------------------
    SET vn_edad_jugador = fn_calcular_edad_jugador(NEW.fecha_nacimiento);

    IF vn_edad_jugador < vn_edad_min OR vn_edad_jugador > vn_edad_max THEN
        -- Armamos el mensaje primero en la variable
        SET vv_mensaje_error = CONCAT(
            'TRIGGER ERROR: El jugador tiene ', vn_edad_jugador, ' anio(s) ',
            'y no cumple la categoria "', vv_cat_nombre, '" ',
            '(', vn_edad_min, ' - ', vn_edad_max, ' anios).'
        );
        
        -- Lanzamos el error usando la variable
        SIGNAL SQLSTATE '45012' 
            SET MESSAGE_TEXT = vv_mensaje_error;
    END IF;

END$$

DELIMITER ;