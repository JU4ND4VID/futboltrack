-- ==============================================================
/* AUTOR: Juan David Peña, Nicolas Matheus, Juan Pablo Moreno
   FECHA: Abril 2026
   DESCRIPCION: Trigger BEFORE INSERT en la tabla jugador. 
                Actúa como segunda línea de defensa para validar que la 
                edad del jugador esté dentro del rango permitido por 
                su categoría ANTES de persistir los datos.
*/
-- ==============================================================

USE `mydb`;

DELIMITER $$

DROP TRIGGER IF EXISTS `tgr_BI_jugador`$$

CREATE TRIGGER `tgr_BI_jugador`
BEFORE INSERT ON `jugador`
FOR EACH ROW
BEGIN
    -- Declaración de variables locales (Nomenclatura del curso)
    DECLARE vn_edad_jugador  INT          DEFAULT 0;
    DECLARE vn_edad_min      INT          DEFAULT 0;
    DECLARE vn_edad_max      INT          DEFAULT 0;
    DECLARE vv_cat_nombre    VARCHAR(60)  DEFAULT '';
    DECLARE vn_cat_count     INT          DEFAULT 0;

    
    -- VALIDACION 1: Fecha de nacimiento no puede ser futura
    
    IF NEW.fecha_nacimiento >= CURDATE() THEN
        SIGNAL SQLSTATE '45010'
            SET MESSAGE_TEXT = 'TRIGGER ERROR: La fecha de nacimiento no puede ser una fecha futura o el dia de hoy.';
    END IF;

    
    -- VALIDACION 2: La categoria debe existir
    
    SELECT COUNT(*), IFNULL(MIN(edad_minima), 0), IFNULL(MAX(edad_maxima), 0), IFNULL(MAX(nombre), '')
      INTO vn_cat_count, vn_edad_min, vn_edad_max, vv_cat_nombre
      FROM categoria
     WHERE id_categoria = NEW.id_categoria;

    IF vn_cat_count = 0 THEN
        SIGNAL SQLSTATE '45011'
            SET MESSAGE_TEXT = 'TRIGGER ERROR: La categoria especificada no existe. Verifique id_categoria.';
    END IF;

    -- VALIDACION 3: Edad coherente con el rango de la categoria
    -- Usa fn_calcular_edad_jugador para centralizar la logica
    
    SET vn_edad_jugador = fn_calcular_edad_jugador(NEW.fecha_nacimiento);

    IF vn_edad_jugador < vn_edad_min OR vn_edad_jugador > vn_edad_max THEN
        SIGNAL SQLSTATE '45012'
            SET MESSAGE_TEXT = CONCAT(
                'TRIGGER ERROR: El jugador tiene ', vn_edad_jugador, ' anio(s) ',
                'y no cumple el rango de la categoria "', vv_cat_nombre, '" ',
                '(', vn_edad_min, ' - ', vn_edad_max, ' anios). ',
                'INSERT cancelado.'
            );
    END IF;

    -- Si todas las validaciones pasan, el INSERT continua normalmente.
END$$

DELIMITER ;


-- ==============================================================
-- CASOS DE PRUEBA
-- Insercion directa en jugador (sin usar el SP) para demostrar
-- que el trigger actua como segunda linea de defensa.
-- Primero insertar en persona (tabla padre requerida por FK).
-- ==============================================================


-- PRUEBA 1: INSERT valido - debe pasar sin errores
-- Jugador Sub-15 (13 anios), categoria 1 (13-15 anios)

INSERT INTO persona (identificacion, nombre, apellido)
VALUES ('1009200001', 'Pipe', 'Ramirez Cano');

INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
VALUES ('1009200001', '2012-08-10', 'Defensa', 1);

SELECT 'PRUEBA 1 OK: Jugador insertado correctamente' AS resultado;
SELECT identificacion_jugador, fecha_nacimiento, posicion, id_categoria
  FROM jugador WHERE identificacion_jugador = '1009200001';


-- PRUEBA 2: INSERT invalido - fecha de nacimiento futura
-- Debe lanzar TRIGGER ERROR con SQLSTATE 45010

INSERT INTO persona (identificacion, nombre, apellido)
VALUES ('1009200002', 'Jugador', 'Futuro');

INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
VALUES ('1009200002', '2030-01-01', 'Portero', 1);


-- PRUEBA 3: INSERT invalido - categoria inexistente
-- Debe lanzar TRIGGER ERROR con SQLSTATE 45011

INSERT INTO persona (identificacion, nombre, apellido)
VALUES ('1009200003', 'Jugador', 'SinCategoria');

INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
VALUES ('1009200003', '2012-03-15', 'Delantero', 99);


-- PRUEBA 4: INSERT invalido - edad fuera del rango de categoria
-- Jugador de 10 anios en Sub-15 (requiere 13-15)
-- Debe lanzar TRIGGER ERROR con SQLSTATE 45012

INSERT INTO persona (identificacion, nombre, apellido)
VALUES ('1009200004', 'Nino', 'MuyJoven');

INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
VALUES ('1009200004', '2016-05-20', 'Mediocampista', 1);


-- PRUEBA 5: Limpieza - solo debe existir el jugador de prueba 1

SELECT
    p.identificacion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_completo,
    CASE WHEN j.identificacion_jugador IS NOT NULL THEN 'jugador insertado'
         ELSE 'solo en persona (INSERT jugador fallo - trigger funciono)'
    END AS estado
FROM persona p
LEFT JOIN jugador j ON p.identificacion = j.identificacion_jugador
WHERE p.identificacion IN ('1009200001','1009200002','1009200003','1009200004')
ORDER BY p.identificacion;