-- ==============================================================
-- FutbolTrack - Trigger #2
-- Nombre   : tgr_BU_jugador
-- Tipo     : BEFORE UPDATE en tabla jugador
-- Proposito: Intercepta cualquier UPDATE en jugador y valida
--            que la edad sea coherente con la categoria.
--            Solo dispara la logica pesada si se altero la
--            categoria o la fecha de nacimiento (optimizacion).
-- Depende  : fn_calcular_edad_jugador, tabla categoria
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP TRIGGER IF EXISTS `tgr_BU_jugador`$$

CREATE TRIGGER `tgr_BU_jugador`
BEFORE UPDATE ON `jugador`
FOR EACH ROW
BEGIN
    DECLARE vn_edad_jugador   INT          DEFAULT 0;
    DECLARE vn_edad_min       INT          DEFAULT 0;
    DECLARE vn_edad_max       INT          DEFAULT 0;
    DECLARE vv_cat_nombre     VARCHAR(60)  DEFAULT '';
    DECLARE vn_cat_count      INT          DEFAULT 0;
    
    -- Variable para guardar el string dinámico
    DECLARE vv_mensaje_error  VARCHAR(255) DEFAULT '';

    IF (NEW.fecha_nacimiento != OLD.fecha_nacimiento) OR (NEW.id_categoria != OLD.id_categoria) THEN

        IF NEW.fecha_nacimiento >= CURDATE() THEN
            SIGNAL SQLSTATE '45010'
                SET MESSAGE_TEXT = 'TRIGGER ERROR: La fecha de nacimiento no puede ser una fecha futura.';
        END IF;

        SELECT COUNT(*), IFNULL(MIN(edad_minima), 0), IFNULL(MAX(edad_maxima), 0), IFNULL(MAX(nombre), '')
          INTO vn_cat_count, vn_edad_min, vn_edad_max, vv_cat_nombre
          FROM categoria
         WHERE id_categoria = NEW.id_categoria;

        IF vn_cat_count = 0 THEN
            SIGNAL SQLSTATE '45011'
                SET MESSAGE_TEXT = 'TRIGGER ERROR: La categoria especificada no existe.';
        END IF;

        SET vn_edad_jugador = fn_calcular_edad_jugador(NEW.fecha_nacimiento);

        IF vn_edad_jugador < vn_edad_min OR vn_edad_jugador > vn_edad_max THEN
            -- Armamos el mensaje primero
            SET vv_mensaje_error = CONCAT(
                'TRIGGER ERROR: El jugador tiene ', vn_edad_jugador, ' anio(s) ',
                'y no cumple la nueva categoria "', vv_cat_nombre, '" ',
                '(', vn_edad_min, ' - ', vn_edad_max, ' anios).'
            );
            
            -- Disparamos la excepcion
            SIGNAL SQLSTATE '45012' 
                SET MESSAGE_TEXT = vv_mensaje_error;
        END IF;

    END IF;

END$$

DELIMITER ;