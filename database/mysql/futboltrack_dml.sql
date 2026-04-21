-- =============================================================
-- FutbolTrack – Script DML de Datos de Prueba
-- Materia   : Bases de Datos II – Universidad El Bosque
-- Integrantes: Juan David Peña, Nicolas Esteban Matheus, Juan Pablo Moreno
-- Motor      : MySQL 8.0+   Schema: mydb
-- Descripción: Datos realistas para Colombia.
--              Contraseñas almacenadas como hash bcrypt (cost 12).
--              Contraseña de prueba para todos los entrenadores: FutbolTrack2026!
-- Fecha      : Abril 2026
-- =============================================================

USE `mydb`;

-- -------------------------------------------------------------------
-- 0. Desactivar restricciones temporalmente para la carga
-- -------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------------
-- 1. CATEGORÍAS  (2 registros)
-- -------------------------------------------------------------------
INSERT INTO `categoria` (`id_categoria`, `nombre`, `edad_minima`, `edad_maxima`) VALUES
(1, 'Sub-15', 13, 15),
(2, 'Sub-17', 15, 17);

-- -------------------------------------------------------------------
-- 2. LUGARES  (3 registros)
-- -------------------------------------------------------------------
INSERT INTO `lugar` (`id_lugar`, `nombre`, `descripcion`, `direccion`) VALUES
(1,
 'Cancha Principal El Bosque',
 'Cancha de grama sintética de última generación. Dimensiones reglamentarias 105 x 68 m. Iluminación LED nocturna, camerinos y bodega de materiales. Capacidad 200 espectadores.',
 'Cra. 9 #131A-02, Usaquén, Bogotá D.C.'),
(2,
 'Cancha Auxiliar Norte',
 'Campo de tierra compactada con arcos fijos. Ideal para trabajos técnicos y físicos. Sin graderías. Contigua a la sede administrativa de la academia.',
 'Av. Boyacá #153-00, Suba, Bogotá D.C.'),
(3,
 'Centro Deportivo Compensar Álamos',
 'Complejo multideportivo con cancha de césped natural certificada FIFA. Acceso controlado, parqueadero y servicio de cafetería. Reserva con 48 horas de anticipación.',
 'Av. El Dorado #68B-85, Fontibón, Bogotá D.C.');

-- -------------------------------------------------------------------
-- 3. PERSONAS – registros padre para entrenadores, jugadores y acudientes
-- -------------------------------------------------------------------

-- Entrenadores
INSERT INTO `persona` (`identificacion`, `nombre`, `apellido`) VALUES
('1020485632', 'Carlos Andrés',   'Herrera Ospina'),
('52748901',   'Mónica Patricia', 'Ruiz Castellanos');

-- Jugadores Sub-15 (nacidos 2011-2013  →  13-15 años en 2026)
INSERT INTO `persona` (`identificacion`, `nombre`, `apellido`) VALUES
('1006748391', 'Santiago',    'Gómez Vargas'),
('1007123456', 'Daniel Andrés','Martínez López'),
('1006987654', 'Sebastián',   'Torres Ríos'),
('1007345678', 'Miguel Ángel','Rodríguez Peña'),
('1006543210', 'Juan Pablo',  'Castro Mendoza');

-- Jugadores Sub-17 (nacidos 2009-2011  →  15-17 años en 2026)
INSERT INTO `persona` (`identificacion`, `nombre`, `apellido`) VALUES
('1004567890', 'Andrés Felipe',   'Díaz Morales'),
('1005234567', 'Camilo Eduardo',  'Reyes Suárez'),
('1004890123', 'Nicolás Alberto', 'Vargas Jiménez'),
('1005678901', 'Luis Miguel',     'Herrera Buitrago'),
('1004321098', 'Alejandro',       'Páez Correa');

-- Acudientes (cédulas de ciudadanía adultos)
INSERT INTO `persona` (`identificacion`, `nombre`, `apellido`) VALUES
('52891034', 'María Elena',     'Vargas Cruz'),        -- acudiente de Santiago
('79456123', 'Roberto Carlos',  'Martínez Silva'),     -- acudiente de Daniel
('43567890', 'Claudia Patricia','Ríos Moreno'),        -- acudiente de Sebastián
('80123456', 'Jorge Luis',      'Peña Contreras'),     -- acudiente de Miguel
('51678901', 'Sandra Milena',   'Mendoza García'),     -- acudiente de Juan Pablo
('40234567', 'Patricia Elena',  'Morales Suárez'),     -- acudiente de Andrés
('71345678', 'Eduardo José',    'Suárez Blanco'),      -- acudiente de Camilo
('32456789', 'Diana Carolina',  'Jiménez Ramos'),      -- acudiente de Nicolás
('63567890', 'Fernando Alberto','Buitrago Cruz'),      -- acudiente de Luis Miguel
('21678901', 'Carmen Rosa',     'Correa Nieto');       -- acudiente de Alejandro

-- -------------------------------------------------------------------
-- 4. ENTRENADORES  (2 registros)
--    Hash bcrypt cost-12 de la contraseña: FutbolTrack2026!
-- -------------------------------------------------------------------
INSERT INTO `entrenador`
    (`cedula_entrenador`, `email`, `contrasena`, `telefono`) VALUES
('1020485632',
 'carlos.herrera@futboltrack.co',
 '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiGVCFpv3kaqmMkYLJzVQqNFzJ3q',
 '3112045678'),
('52748901',
 'monica.ruiz@futboltrack.co',
 '$2b$12$XhQRv4mZpNcTWYLdO3oJweKqUVzFGsBnJ7tMxA1iPwHlD2rE5gS6y',
 '3204567891');

-- -------------------------------------------------------------------
-- 5. JUGADORES  (10 registros)
-- -------------------------------------------------------------------
INSERT INTO `jugador`
    (`identificacion_jugador`, `fecha_nacimiento`, `posicion`, `id_categoria`) VALUES
-- Sub-15
('1006748391', '2011-03-15', 'Mediocampista', 1),
('1007123456', '2011-07-22', 'Defensa',       1),
('1006987654', '2012-01-10', 'Delantero',     1),
('1007345678', '2012-05-30', 'Portero',       1),
('1006543210', '2011-11-08', 'Delantero',     1),
-- Sub-17
('1004567890', '2009-02-14', 'Mediocampista', 2),
('1005234567', '2009-08-25', 'Defensa',       2),
('1004890123', '2010-04-03', 'Delantero',     2),
('1005678901', '2010-09-17', 'Portero',       2),
('1004321098', '2009-12-05', 'Mediocampista', 2);

-- -------------------------------------------------------------------
-- 6. ACUDIENTES  (10 registros – relación 1:1 con jugador)
-- -------------------------------------------------------------------
INSERT INTO `acudiente`
    (`cedula_acudiente`, `telefono`, `parentesco`, `identificacion_jugador`) VALUES
('52891034', '3157891234', 'Madre',        '1006748391'),
('79456123', '3009871234', 'Padre',        '1007123456'),
('43567890', '3113456789', 'Madre',        '1006987654'),
('80123456', '3187654321', 'Padre',        '1007345678'),
('51678901', '3205679012', 'Madre',        '1006543210'),
('40234567', '3118765432', 'Madre',        '1004567890'),
('71345678', '3004321098', 'Padre',        '1005234567'),
('32456789', '3152345678', 'Madre',        '1004890123'),
('63567890', '3143456789', 'Padre',        '1005678901'),
('21678901', '3167891234', 'Abuela',       '1004321098');

-- -------------------------------------------------------------------
-- 7. ENTRENAMIENTOS  (6 registros)
--    Los 4 primeros ya realizados; 2 programados en el futuro.
--    id_plan_mongodb NULL → se vinculará cuando MongoDB esté activo.
-- -------------------------------------------------------------------
INSERT INTO `entrenamiento`
    (`id_entrenamiento`, `fecha`, `hora_inicio`, `hora_fin`,
     `tipo`, `estado`, `observacion`,
     `id_lugar`, `id_categoria`, `cedula_entrenador`, `id_plan_mongodb`) VALUES

-- Realizado 1 – Sub-15 / Físico
(1, '2026-04-07', '08:00:00', '10:00:00',
 'Físico', 'realizado',
 'Se trabajaron ejercicios de resistencia aeróbica y velocidad. El grupo respondió bien al circuito. Se recomienda reforzar la técnica de carrera en los próximos ciclos.',
 1, 1, '1020485632', NULL),

-- Realizado 2 – Sub-15 / Técnico
(2, '2026-04-09', '15:00:00', '17:00:00',
 'Técnico', 'realizado',
 'Sesión enfocada en conducción y control del balón. Santiago Gómez demostró buena progresión. Juan Pablo Castro necesita refuerzo en el primer toque.',
 2, 1, '1020485632', NULL),

-- Realizado 3 – Sub-17 / Táctico
(3, '2026-04-14', '08:00:00', '10:00:00',
 'Táctico', 'realizado',
 'Trabajo de posicionamiento defensivo en bloque bajo. Se implementó el esquema 4-3-3. Andrés Díaz asumió bien el rol de mediocampista organizador.',
 1, 2, '1020485632', NULL),

-- Realizado 4 – Sub-17 / Mixto
(4, '2026-04-16', '15:00:00', '17:00:00',
 'Mixto', 'realizado',
 'Circuito físico-técnico de 45 min seguido de rondo y partido reducido. Buen ritmo colectivo. Camilo Reyes presentó molestia en tobillo derecho: derivar a fisioterapia.',
 3, 2, '52748901',   NULL),

-- Programado 5 – Sub-15 / Físico (futuro)
(5, '2026-04-28', '08:00:00', '10:00:00',
 'Físico', 'programado',
 NULL,
 2, 1, '52748901',   NULL),

-- Programado 6 – Sub-17 / Técnico (futuro)
(6, '2026-04-30', '15:00:00', '17:00:00',
 'Técnico', 'programado',
 NULL,
 1, 2, '1020485632', NULL);

-- -------------------------------------------------------------------
-- 8. ASISTENCIA  (registros para los 4 entrenamientos realizados)
--    Estado: presente / ausente / justificado
--    Lógica realista: ~80 % asistencia general, 1 ausencia, 1 justificado por sesión.
-- -------------------------------------------------------------------

-- Entrenamiento 1 – Sub-15 (5 jugadores)
INSERT INTO `asistencia`
    (`id_entrenamiento`, `identificacion_jugador`, `estado_asistencia`, `observacion`) VALUES
(1, '1006748391', 'presente',    NULL),
(1, '1007123456', 'presente',    NULL),
(1, '1006987654', 'ausente',     'No se presentó ni notificó. Se debe contactar al acudiente.'),
(1, '1007345678', 'presente',    NULL),
(1, '1006543210', 'presente',    NULL);

-- Entrenamiento 2 – Sub-15 (5 jugadores)
INSERT INTO `asistencia`
    (`id_entrenamiento`, `identificacion_jugador`, `estado_asistencia`, `observacion`) VALUES
(2, '1006748391', 'presente',    NULL),
(2, '1007123456', 'justificado', 'Certificado médico por gripa. Acudiente notificó por WhatsApp.'),
(2, '1006987654', 'presente',    NULL),
(2, '1007345678', 'presente',    NULL),
(2, '1006543210', 'presente',    NULL);

-- Entrenamiento 3 – Sub-17 (5 jugadores)
INSERT INTO `asistencia`
    (`id_entrenamiento`, `identificacion_jugador`, `estado_asistencia`, `observacion`) VALUES
(3, '1004567890', 'presente',    NULL),
(3, '1005234567', 'presente',    NULL),
(3, '1004890123', 'presente',    NULL),
(3, '1005678901', 'ausente',     'Sin notificación previa. Segunda ausencia en el mes.'),
(3, '1004321098', 'presente',    NULL);

-- Entrenamiento 4 – Sub-17 (5 jugadores)
INSERT INTO `asistencia`
    (`id_entrenamiento`, `identificacion_jugador`, `estado_asistencia`, `observacion`) VALUES
(4, '1004567890', 'presente',    NULL),
(4, '1005234567', 'presente',    NULL),
(4, '1004890123', 'justificado', 'Permiso escolar – parciales de matemáticas. Informó con anticipación.'),
(4, '1005678901', 'presente',    NULL),
(4, '1004321098', 'presente',    NULL);

-- -------------------------------------------------------------------
-- 9. Reactivar restricciones
-- -------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 1;

-- -------------------------------------------------------------------
-- 10. Verificación rápida post-inserción
-- -------------------------------------------------------------------
SELECT 'categorias'    AS tabla, COUNT(*) AS registros FROM categoria
UNION ALL
SELECT 'lugares',       COUNT(*) FROM lugar
UNION ALL
SELECT 'personas',      COUNT(*) FROM persona
UNION ALL
SELECT 'entrenadores',  COUNT(*) FROM entrenador
UNION ALL
SELECT 'jugadores',     COUNT(*) FROM jugador
UNION ALL
SELECT 'acudientes',    COUNT(*) FROM acudiente
UNION ALL
SELECT 'entrenamientos',COUNT(*) FROM entrenamiento
UNION ALL
SELECT 'asistencias',   COUNT(*) FROM asistencia;

-- Resumen de asistencia por jugador (útil para probar futuros reportes)
SELECT
    CONCAT(p.nombre, ' ', p.apellido)      AS jugador,
    c.nombre                                AS categoria,
    SUM(a.estado_asistencia = 'presente')   AS presentes,
    SUM(a.estado_asistencia = 'ausente')    AS ausentes,
    SUM(a.estado_asistencia = 'justificado')AS justificados,
    COUNT(*)                                AS total_sesiones,
    ROUND(
        SUM(a.estado_asistencia = 'presente') / COUNT(*) * 100, 1
    )                                       AS pct_asistencia
FROM asistencia a
JOIN jugador  j ON a.identificacion_jugador = j.identificacion_jugador
JOIN persona  p ON j.identificacion_jugador = p.identificacion
JOIN categoria c ON j.id_categoria = c.id_categoria
GROUP BY a.identificacion_jugador
ORDER BY c.id_categoria, pct_asistencia DESC;
