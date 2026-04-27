-- ==============================================================
-- FutbolTrack - Trigger #3
-- Nombre   : tgr_AU_entrenamiento
-- Tipo     : AFTER UPDATE en tabla entrenamiento
-- Proposito: Registra en una tabla de auditoria (log_entrenamiento)
--            cada vez que el estado de una sesion cambia.
-- Autor    : Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
-- Materia  : Bases de Datos II - Universidad El Bosque
-- Fecha    : Abril 2026
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP TRIGGER IF EXISTS `tgr_AU_entrenamiento`$$

CREATE TRIGGER `tgr_AU_entrenamiento`
AFTER UPDATE ON `entrenamiento`
FOR EACH ROW
BEGIN
    -- Declaración de variables (Nomenclatura del curso)
    DECLARE vv_usuario VARCHAR(50) DEFAULT '';

    -- =======================================================
    -- OPTIMIZACION: Solo auditar si el ESTADO realmente cambió
    -- =======================================================
    IF NEW.estado != OLD.estado THEN
        
        -- Obtener el usuario actual de la base de datos que hace el cambio
        SET vv_usuario = CURRENT_USER();

        -- Insertar el registro histórico en la tabla de log
        INSERT INTO log_entrenamiento (
            id_entrenamiento,
            estado_anterior,
            estado_nuevo,
            fecha_cambio,
            usuario_db
        ) VALUES (
            NEW.id_entrenamiento,
            OLD.estado,
            NEW.estado,
            NOW(),
            vv_usuario
        );

    END IF;

END$$

DELIMITER ;