-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: mydb
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `acudiente`
--

DROP TABLE IF EXISTS `acudiente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acudiente` (
  `cedula_acudiente` varchar(15) NOT NULL COMMENT 'Clave primaria y foránea hacia PERSONA. Cédula de ciudadanía del acudiente.',
  `telefono` varchar(20) NOT NULL COMMENT 'Número de contacto principal del acudiente. Es el canal de comunicación con la academia cuando el jugador es menor de edad',
  `parentesco` varchar(30) NOT NULL COMMENT 'Relación familiar o legal del acudiente con el jugador. Ej: Padre, Madre, Tío, Hermano, Tutor legal',
  `identificacion_jugador` varchar(15) NOT NULL COMMENT 'Clave foránea hacia JUGADOR. Indica a qué jugador pertenece este acudiente. Relación uno a uno',
  PRIMARY KEY (`cedula_acudiente`),
  UNIQUE KEY `identificacion_jugador_UNIQUE` (`identificacion_jugador`),
  KEY `fk_acudiente_jugador_idx` (`identificacion_jugador`),
  CONSTRAINT `fk_acudiente_jugador` FOREIGN KEY (`identificacion_jugador`) REFERENCES `jugador` (`identificacion_jugador`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_acudiente_persona` FOREIGN KEY (`cedula_acudiente`) REFERENCES `persona` (`identificacion`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Especialización de PERSONA. Almacena el contacto responsable \nde cada jugador menor de edad registrado en la academia. \nGarantiza que siempre exista un adulto responsable vinculado \na cada jugador. Implementa la única relación 1:1 del modelo.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `acudiente`
--

LOCK TABLES `acudiente` WRITE;
/*!40000 ALTER TABLE `acudiente` DISABLE KEYS */;
INSERT INTO `acudiente` VALUES ('10578655','3225956011','Madre','185758349'),('14440493','3047362677','Tío','150864911'),('15045580','3227687060','Tío','118566572'),('16399185','3214629283','Padre','119175900'),('16409749','3219578796','Madre','114665841'),('16887758','3223166605','Padre','181030736'),('20143030','3501536214','Padre','172383095'),('20933779','3133108895','Padre','164606833'),('24736089','3103872045','Abuela','177490893'),('25417234','3219290022','Padre','132614537'),('27537375','3027526710','Madre','178961459'),('28228930','3047800313','Madre','137308985'),('30191718','3517850128','Madre','162043515'),('33063559','3185621970','Madre','159476001'),('33372013','3157876554','Madre','191887369'),('36607312','3053913196','Madre','112517517'),('38378349','3025321417','Madre','147683626'),('39340526','3177434977','Padre','151642594'),('40905340','3173235470','Madre','103356886'),('41036051','3016797138','Madre','165579548'),('43576939','3165589876','Madre','195004803'),('45102952','3153284258','Madre','190377459'),('49041568','3013674620','Madre','100435578'),('52829744','3034924292','Madre','104308421'),('53029632','3039946351','Padre','186028436'),('55473870','3129870385','Padre','129587039'),('57487375','3031936465','Madre','181756179'),('58546900','3152214493','Tío','128538251'),('61358985','3159039197','Padre','144349361'),('62091490','3163554776','Padre','175329037'),('62970508','3003889924','Madre','160597444'),('63607919','3007946861','Madre','178461803'),('64039108','3115519768','Madre','121429110'),('67098936','3123397658','Padre','138840994'),('68762647','3015298533','Madre','191306093'),('68932463','3118008132','Madre','156623995'),('69285932','3513980060','Madre','150806024'),('72817182','3059909222','Madre','116879290'),('73935066','3152254019','Madre','128754377'),('78600822','3024444304','Padre','111496211'),('81244461','3052507202','Padre','190825067'),('81370067','3161021683','Madre','132138745'),('81713878','3128752528','Madre','145176955'),('84789973','3505952173','Abuela','153551839'),('86452826','3055619651','Padre','188447167'),('91327628','3204360218','Madre','135575298'),('92304466','3504635493','Abuela','104265799'),('93035455','3024262697','Madre','123978249'),('97823232','3176211949','Padre','120514014'),('99632857','3155378570','Tutor legal','172394227');
/*!40000 ALTER TABLE `acudiente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `administrador`
--

DROP TABLE IF EXISTS `administrador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `administrador` (
  `cedula_admin` varchar(15) NOT NULL COMMENT 'PK y FK hacia persona. Cédula del administrador.',
  `email` varchar(120) NOT NULL COMMENT 'Correo único. Credencial de acceso al sistema.',
  `contrasena` varchar(255) NOT NULL COMMENT 'Hash bcrypt. Nunca texto plano.',
  `telefono` varchar(20) DEFAULT NULL COMMENT 'Contacto opcional.',
  PRIMARY KEY (`cedula_admin`),
  UNIQUE KEY `uq_admin_email` (`email`),
  CONSTRAINT `fk_admin_persona` FOREIGN KEY (`cedula_admin`) REFERENCES `persona` (`identificacion`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Especialización de PERSONA para el rol administrador.\n           Gestión completa de jugadores. Acceso de solo lectura\n           al resto del sistema. Sin restricción de categoría.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `administrador`
--

LOCK TABLES `administrador` WRITE;
/*!40000 ALTER TABLE `administrador` DISABLE KEYS */;
INSERT INTO `administrador` VALUES ('99999999','admin@futboltrack.co','$2b$12$fB9ajekPD.uWD4GZ3N3ACOrfnhtBFQkwD3/.96acNzcDxFZWEYuci','3000000000');
/*!40000 ALTER TABLE `administrador` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asistencia`
--

DROP TABLE IF EXISTS `asistencia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `asistencia` (
  `id_entrenamiento` int NOT NULL COMMENT 'Clave primaria compuesta y foránea hacia ENTRENAMIENTO. Identifica la sesión a la que corresponde el registro de asistencia',
  `identificacion_jugador` varchar(15) NOT NULL COMMENT 'Clave primaria compuesta y foránea hacia JUGADOR. Identifica el jugador cuya asistencia se está registrando',
  `estado_asistencia` enum('presente','ausente','justificado') NOT NULL COMMENT 'Estado de asistencia del jugador a la sesión. Valores: presente, ausente, justificado',
  `observacion` text COMMENT 'Motivo de ausencia o nota adicional sobre la asistencia del jugador. Campo opcional',
  PRIMARY KEY (`id_entrenamiento`,`identificacion_jugador`),
  KEY `fk_asistencia_jugador_idx` (`identificacion_jugador`),
  CONSTRAINT `fk_asistencia_entrenamiento` FOREIGN KEY (`id_entrenamiento`) REFERENCES `entrenamiento` (`id_entrenamiento`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_asistencia_jugador` FOREIGN KEY (`identificacion_jugador`) REFERENCES `jugador` (`identificacion_jugador`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Entidad asociativa que registra la asistencia de cada jugador \na cada sesión de entrenamiento. Implementa la relación N:M \nentre JUGADOR y ENTRENAMIENTO. Su clave primaria compuesta \ngarantiza que no se dupliquen registros de asistencia para \nel mismo jugador en la misma sesión.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asistencia`
--

LOCK TABLES `asistencia` WRITE;
/*!40000 ALTER TABLE `asistencia` DISABLE KEYS */;
INSERT INTO `asistencia` VALUES (1,'100435578','justificado','Lesión leve'),(1,'111496211','presente',NULL),(1,'112517517','justificado','Cita médica autorizada'),(1,'114665841','presente',NULL),(1,'116879290','presente',NULL),(1,'123978249','presente',NULL),(1,'128754377','presente',NULL),(1,'132138745','presente',NULL),(1,'132614537','presente',NULL),(1,'135575298','justificado','Cita médica autorizada'),(1,'144349361','presente',NULL),(1,'150864911','presente',NULL),(1,'153551839','presente',NULL),(1,'156623995','presente',NULL),(1,'159476001','presente',NULL),(1,'160597444','presente',NULL),(1,'164606833','presente',NULL),(1,'165579548','presente',NULL),(1,'172383095','presente',NULL),(1,'172394227','ausente','Sin justificación'),(1,'178961459','presente',NULL),(1,'185758349','justificado','Cita médica autorizada'),(1,'188447167','presente',NULL),(1,'190377459','presente',NULL),(1,'195004803','presente',NULL),(2,'100435578','presente',NULL),(2,'111496211','presente',NULL),(2,'112517517','presente',NULL),(2,'114665841','justificado','Lesión leve'),(2,'116879290','presente',NULL),(2,'123978249','presente',NULL),(2,'128754377','presente',NULL),(2,'132138745','presente',NULL),(2,'132614537','justificado','Cita médica autorizada'),(2,'135575298','presente',NULL),(2,'144349361','presente',NULL),(2,'150864911','presente',NULL),(2,'153551839','presente',NULL),(2,'156623995','presente',NULL),(2,'159476001','presente',NULL),(2,'160597444','presente',NULL),(2,'164606833','presente',NULL),(2,'165579548','presente',NULL),(2,'172383095','presente',NULL),(2,'172394227','presente',NULL),(2,'178961459','justificado','Lesión leve'),(2,'185758349','presente',NULL),(2,'188447167','justificado','Cita médica autorizada'),(2,'190377459','presente',NULL),(2,'195004803','presente',NULL),(3,'100435578','presente',NULL),(3,'111496211','presente',NULL),(3,'112517517','justificado','Cita médica autorizada'),(3,'114665841','presente',NULL),(3,'116879290','presente',NULL),(3,'123978249','presente',NULL),(3,'128754377','justificado','Lesión leve'),(3,'132138745','presente',NULL),(3,'132614537','presente',NULL),(3,'135575298','ausente','Viaje familiar'),(3,'144349361','justificado','Lesión leve'),(3,'150864911','presente',NULL),(3,'153551839','presente',NULL),(3,'156623995','presente',NULL),(3,'159476001','presente',NULL),(3,'160597444','presente',NULL),(3,'164606833','justificado','Cita médica autorizada'),(3,'165579548','presente',NULL),(3,'172383095','presente',NULL),(3,'172394227','justificado','Cita médica autorizada'),(3,'178961459','presente',NULL),(3,'185758349','presente',NULL),(3,'188447167','presente',NULL),(3,'190377459','presente',NULL),(3,'195004803','presente',NULL),(4,'103356886','presente',NULL),(4,'104265799','presente',NULL),(4,'104308421','justificado','Permiso académico'),(4,'118566572','presente',NULL),(4,'119175900','ausente','Enfermedad'),(4,'120514014','presente',NULL),(4,'121429110','ausente','Enfermedad'),(4,'128538251','presente',NULL),(4,'129587039','justificado','Cita médica autorizada'),(4,'137308985','ausente','Sin justificación'),(4,'138840994','presente',NULL),(4,'145176955','justificado','Cita médica autorizada'),(4,'147683626','presente',NULL),(4,'150806024','justificado','Permiso académico'),(4,'151642594','presente',NULL),(4,'162043515','presente',NULL),(4,'175329037','ausente','Enfermedad'),(4,'177490893','ausente','Enfermedad'),(4,'178461803','presente',NULL),(4,'181030736','presente',NULL),(4,'181756179','presente',NULL),(4,'186028436','ausente','Viaje familiar'),(4,'190825067','presente',NULL),(4,'191306093','presente',NULL),(4,'191887369','presente',NULL),(5,'103356886','presente',NULL),(5,'104265799','justificado','Lesión leve'),(5,'104308421','presente',NULL),(5,'118566572','presente',NULL),(5,'119175900','presente',NULL),(5,'120514014','justificado','Lesión leve'),(5,'121429110','ausente','Viaje familiar'),(5,'128538251','presente',NULL),(5,'129587039','presente',NULL),(5,'137308985','ausente','No contactado'),(5,'138840994','presente',NULL),(5,'145176955','presente',NULL),(5,'147683626','presente',NULL),(5,'150806024','presente',NULL),(5,'151642594','presente',NULL),(5,'162043515','presente',NULL),(5,'175329037','presente',NULL),(5,'177490893','presente',NULL),(5,'178461803','justificado','Lesión leve'),(5,'181030736','justificado','Permiso académico'),(5,'181756179','presente',NULL),(5,'186028436','presente',NULL),(5,'190825067','presente',NULL),(5,'191306093','presente',NULL),(5,'191887369','presente',NULL),(6,'103356886','presente',NULL),(6,'104265799','presente',NULL),(6,'104308421','ausente','Viaje familiar'),(6,'118566572','presente',NULL),(6,'119175900','presente',NULL),(6,'120514014','presente',NULL),(6,'121429110','presente',NULL),(6,'128538251','presente',NULL),(6,'129587039','presente',NULL),(6,'137308985','presente',NULL),(6,'138840994','presente',NULL),(6,'145176955','presente',NULL),(6,'147683626','presente',NULL),(6,'150806024','presente',NULL),(6,'151642594','presente',NULL),(6,'162043515','presente',NULL),(6,'175329037','ausente','Viaje familiar'),(6,'177490893','presente',NULL),(6,'178461803','presente',NULL),(6,'181030736','presente',NULL),(6,'181756179','presente',NULL),(6,'186028436','presente',NULL),(6,'190825067','presente',NULL),(6,'191306093','presente',NULL),(6,'191887369','presente',NULL),(8,'103356886','ausente',NULL),(8,'104265799','ausente',NULL),(8,'104308421','ausente',NULL),(8,'118566572','ausente',NULL),(8,'119175900','presente',NULL),(8,'120514014','ausente',NULL),(8,'121429110','ausente',NULL),(8,'128538251','ausente',NULL),(8,'129587039','ausente',NULL),(8,'137308985','ausente',NULL),(8,'138840994','ausente',NULL),(8,'145176955','ausente',NULL),(8,'147683626','ausente',NULL),(8,'150806024','ausente',NULL),(8,'151642594','presente',NULL),(8,'162043515','ausente',NULL),(8,'175329037','ausente',NULL),(8,'177490893','ausente',NULL),(8,'178461803','ausente',NULL),(8,'181030736','ausente',NULL),(8,'181756179','ausente',NULL),(8,'186028436','ausente',NULL),(8,'190825067','ausente',NULL),(8,'191306093','ausente',NULL),(8,'191887369','ausente',NULL),(9,'100435578','ausente',NULL),(9,'111496211','ausente',NULL),(9,'112517517','ausente',NULL),(9,'114665841','ausente',NULL),(9,'116879290','ausente',NULL),(9,'123978249','ausente',NULL),(9,'128754377','presente',NULL),(9,'132138745','ausente',NULL),(9,'132614537','ausente',NULL),(9,'135575298','ausente',NULL),(9,'144349361','presente',NULL),(9,'150864911','ausente',NULL),(9,'153551839','ausente',NULL),(9,'156623995','ausente',NULL),(9,'159476001','ausente',NULL),(9,'160597444','ausente',NULL),(9,'164606833','ausente',NULL),(9,'165579548','ausente',NULL),(9,'172383095','ausente',NULL),(9,'172394227','ausente',NULL),(9,'178961459','ausente',NULL),(9,'185758349','ausente',NULL),(9,'188447167','ausente',NULL),(9,'190377459','ausente',NULL),(9,'195004803','ausente',NULL),(10,'100435578','ausente',NULL),(10,'111496211','ausente',NULL),(10,'112517517','ausente',NULL),(10,'114665841','ausente',NULL),(10,'116879290','ausente',NULL),(10,'123978249','ausente',NULL),(10,'128754377','presente',NULL),(10,'132138745','ausente',NULL),(10,'132614537','ausente',NULL),(10,'135575298','ausente',NULL),(10,'144349361','presente',NULL),(10,'150864911','ausente',NULL),(10,'153551839','ausente',NULL),(10,'156623995','ausente',NULL),(10,'159476001','ausente',NULL),(10,'160597444','ausente',NULL),(10,'164606833','ausente',NULL),(10,'165579548','ausente',NULL),(10,'172383095','ausente',NULL),(10,'172394227','ausente',NULL),(10,'178961459','ausente',NULL),(10,'185758349','ausente',NULL),(10,'188447167','ausente',NULL),(10,'190377459','ausente',NULL),(10,'195004803','ausente',NULL),(11,'100435578','ausente',NULL),(11,'111496211','ausente',NULL),(11,'112517517','ausente',NULL),(11,'114665841','ausente',NULL),(11,'116879290','ausente',NULL),(11,'123978249','ausente',NULL),(11,'128754377','presente',NULL),(11,'132138745','ausente',NULL),(11,'132614537','ausente',NULL),(11,'135575298','ausente',NULL),(11,'144349361','ausente',NULL),(11,'150864911','ausente',NULL),(11,'153551839','ausente',NULL),(11,'156623995','ausente',NULL),(11,'159476001','ausente',NULL),(11,'160597444','ausente',NULL),(11,'164606833','ausente',NULL),(11,'165579548','ausente',NULL),(11,'172383095','ausente',NULL),(11,'172394227','ausente',NULL),(11,'178961459','ausente',NULL),(11,'185758349','presente',NULL),(11,'188447167','ausente',NULL),(11,'190377459','ausente',NULL),(11,'195004803','ausente',NULL);
/*!40000 ALTER TABLE `asistencia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `id_categoria` int NOT NULL AUTO_INCREMENT COMMENT 'Identificador único de la categoría. Auto incremental',
  `nombre` varchar(60) NOT NULL COMMENT 'Nombre de la categoría. Ej: Sub-15, Sub-17',
  `edad_minima` tinyint unsigned NOT NULL COMMENT 'Edad mínima permitida en años',
  `edad_maxima` tinyint unsigned NOT NULL COMMENT 'Edad máxima permitida en años',
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 KEY_BLOCK_SIZE=16 COMMENT='Almacena las categorías deportivas de la academia de fútbol \n(Ej: Sub-15, Sub-17). Define los rangos de edad mínima y máxima \npermitidos para clasificar a los jugadores y organizar los \nentrenamientos por grupo etario.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

LOCK TABLES `categoria` WRITE;
/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
INSERT INTO `categoria` VALUES (1,'Sub-15',13,15),(2,'Sub-17',15,17);
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entrenador`
--

DROP TABLE IF EXISTS `entrenador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entrenador` (
  `cedula_entrenador` varchar(15) NOT NULL COMMENT 'Clave primaria y foránea hacia PERSONA. Número de documento de identidad del entrenador',
  `email` varchar(120) NOT NULL COMMENT 'Correo electrónico único del entrenador. Usado como credencial de acceso al sistema',
  `contrasena` varchar(255) NOT NULL COMMENT 'Contraseña de acceso almacenada como hash bcrypt. Nunca se guarda en texto plano',
  `telefono` varchar(20) NOT NULL COMMENT 'Número de contacto principal. Campo opcional ya que los jugadores menores de edad pueden no tener teléfono propio. En ese caso el contacto se gestiona a través del acudiente',
  `id_categoria` int NOT NULL DEFAULT '1' COMMENT 'Categoría que dirige el entrenador',
  PRIMARY KEY (`cedula_entrenador`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  KEY `fk_entrenador_categoria` (`id_categoria`),
  CONSTRAINT `fk_entrenador_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`),
  CONSTRAINT `fk_entrenador_persona` FOREIGN KEY (`cedula_entrenador`) REFERENCES `persona` (`identificacion`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Especialización de PERSONA. Almacena los atributos exclusivos \ndel entrenador deportivo. Hereda identificacion, nombre, apellido de PERSONA. Es el único rol con acceso al sistema.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entrenador`
--

LOCK TABLES `entrenador` WRITE;
/*!40000 ALTER TABLE `entrenador` DISABLE KEYS */;
INSERT INTO `entrenador` VALUES ('1020485632','carlos.herrera@futboltrack.co','$2b$12$jTJ5jdGXkMLJSzuk17zsj.oAWDedTYsUzXSRAbR2SKAurevSBVpk.','3112045678',2),('52748901','monica.ruiz@futboltrack.co','$2b$12$KNtPTsw3cpi4lkUrRkYc/eGjxDousN4SuARkBLiKqGMvnm.x2kmQK','3204567891',1);
/*!40000 ALTER TABLE `entrenador` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entrenamiento`
--

DROP TABLE IF EXISTS `entrenamiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entrenamiento` (
  `id_entrenamiento` int NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria autoincremental. Identificador único de cada sesión de entrenamiento registrada en el sistema',
  `fecha` date NOT NULL COMMENT 'Fecha programada de la sesión en formato ISO YYYY-MM-DD',
  `hora_inicio` time NOT NULL COMMENT 'Hora de inicio de la sesión en formato HH:MM:SS',
  `hora_fin` time NOT NULL COMMENT 'Hora de finalización de la sesión en formato HH:MM:SS',
  `tipo` varchar(45) NOT NULL COMMENT 'Clasificación de la sesión. Valores permitidos: Físico, Táctico, Técnico, Mixto',
  `estado` enum('programado','realizado','cancelado') NOT NULL COMMENT 'Estado actual de la sesión. Valores: programado, realizado, cancelado',
  `observacion` text COMMENT 'Notas libres del entrenador registradas al finalizar la sesión. Campo opcional',
  `id_lugar` int NOT NULL COMMENT 'Clave foránea hacia LUGAR. Indica la instalación deportiva donde se realiza el entrenamiento',
  `id_categoria` int NOT NULL COMMENT 'Clave foránea hacia CATEGORIA. Indica el grupo etario al que va dirigido el entrenamiento',
  `cedula_entrenador` varchar(15) NOT NULL COMMENT 'Clave foránea hacia ENTRENADOR. Indica qué entrenador dirige la sesión',
  `id_plan_mongodb` varchar(24) DEFAULT NULL COMMENT 'Identificador del documento en MongoDB que contiene el plan detallado de la sesión. ObjectId en formato hexadecimal de 24 caracteres',
  PRIMARY KEY (`id_entrenamiento`),
  KEY `fk_entrenamiento_lugar_idx` (`id_lugar`),
  KEY `fk_entrenamiento_categoria_idx` (`id_categoria`),
  KEY `fk_entrenamiento_entrenador_idx` (`cedula_entrenador`),
  CONSTRAINT `fk_entrenamiento_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_entrenamiento_entrenador` FOREIGN KEY (`cedula_entrenador`) REFERENCES `entrenador` (`cedula_entrenador`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_entrenamiento_lugar` FOREIGN KEY (`id_lugar`) REFERENCES `lugar` (`id_lugar`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COMMENT='Entidad central del sistema. Registra cada sesión de entrenamiento \nprogramada o realizada por la academia. Actúa como puente entre \nla base de datos relacional MySQL y MongoDB a través del campo \nid_plan_mongodb, que referencia el plan detallado de la sesión \nalmacenado en formato documental.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entrenamiento`
--

LOCK TABLES `entrenamiento` WRITE;
/*!40000 ALTER TABLE `entrenamiento` DISABLE KEYS */;
INSERT INTO `entrenamiento` VALUES (1,'2026-05-08','08:00:00','10:00:00','Táctico','realizado',NULL,1,2,'1020485632',NULL),(2,'2026-05-11','15:00:00','17:00:00','Físico','realizado',NULL,3,2,'1020485632',NULL),(3,'2026-05-15','08:00:00','10:00:00','Físico','realizado',NULL,3,2,'1020485632',NULL),(4,'2026-05-05','15:00:00','17:00:00','Táctico','realizado',NULL,1,1,'52748901',NULL),(5,'2026-05-12','08:00:00','10:00:00','Físico','realizado',NULL,3,1,'52748901',NULL),(6,'2026-05-13','15:00:00','17:00:00','Mixto','realizado',NULL,3,1,'52748901',NULL),(8,'2026-05-22','20:00:00','22:00:00','Táctico','programado',NULL,1,1,'52748901',NULL),(9,'2026-05-20','21:00:00','22:00:00','Táctico','realizado',NULL,2,2,'1020485632','6a0aa12f22cdc287d7a68791'),(10,'2026-05-23','19:00:00','21:00:00','Táctico','realizado',NULL,3,2,'1020485632','6a0b55d808d9ab89d33959cf'),(11,'2026-05-21','13:00:00','15:00:00','Táctico','realizado',NULL,2,2,'1020485632','6a0b5a6608d9ab89d33959d1');
/*!40000 ALTER TABLE `entrenamiento` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tgr_AU_entrenamiento` AFTER UPDATE ON `entrenamiento` FOR EACH ROW BEGIN
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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `jugador`
--

DROP TABLE IF EXISTS `jugador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jugador` (
  `identificacion_jugador` varchar(15) NOT NULL COMMENT 'Clave primaria y foránea hacia PERSONA. Documento de identidad del jugador.',
  `fecha_nacimiento` date NOT NULL COMMENT 'Fecha de nacimiento del jugador en formato ISO YYYY-MM-DD. Permite verificar que el jugador cumple el rango de edad establecido por su categoría',
  `posicion` varchar(20) NOT NULL COMMENT 'Posición habitual del jugador en el campo. Valores permitidos: Portero, Defensa, Mediocampista, Delantero',
  `id_categoria` int NOT NULL COMMENT 'Clave foránea hacia CATEGORIA. Indica la categoría etaria a la que pertenece el jugador dentro de la academia',
  PRIMARY KEY (`identificacion_jugador`),
  KEY `fk_jugador_categoria_idx` (`id_categoria`),
  CONSTRAINT `fk_jugador_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_jugador_persona` FOREIGN KEY (`identificacion_jugador`) REFERENCES `persona` (`identificacion`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Especialización de PERSONA. Almacena los atributos \nexclusivos del jugador deportivo. No tiene teléfono propio \ndado que puede ser menor de edad. El contacto se gestiona \na través de su acudiente.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jugador`
--

LOCK TABLES `jugador` WRITE;
/*!40000 ALTER TABLE `jugador` DISABLE KEYS */;
INSERT INTO `jugador` VALUES ('100435578','2010-12-03','Defensa',2),('103356886','2011-01-01','Defensa',1),('104265799','2012-09-28','Defensa',1),('104308421','2011-08-30','Portero',1),('111496211','2008-10-26','Portero',2),('112517517','2008-06-17','Defensa',2),('114665841','2010-04-12','Mediocampista',2),('116879290','2011-05-13','Delantero',2),('118566572','2011-08-10','Delantero',1),('119175900','2012-12-12','Delantero',1),('120514014','2010-12-28','Mediocampista',1),('121429110','2010-05-31','Defensa',1),('123978249','2011-03-09','Delantero',2),('128538251','2012-02-21','Delantero',1),('128754377','2011-02-06','Delantero',2),('129587039','2012-09-23','Delantero',1),('132138745','2010-02-06','Mediocampista',2),('132614537','2011-01-11','Defensa',2),('135575298','2009-04-21','Mediocampista',2),('137308985','2012-07-04','Mediocampista',1),('138840994','2011-08-27','Delantero',1),('144349361','2008-07-21','Defensa',2),('145176955','2011-08-01','Defensa',1),('147683626','2012-06-14','Mediocampista',1),('150806024','2011-01-28','Delantero',1),('150864911','2009-04-20','Delantero',2),('151642594','2010-09-25','Mediocampista',1),('153551839','2010-02-15','Mediocampista',2),('156623995','2009-03-01','Defensa',2),('159476001','2008-10-19','Mediocampista',2),('160597444','2011-04-12','Portero',2),('162043515','2011-04-17','Mediocampista',1),('164606833','2011-02-06','Delantero',2),('165579548','2010-03-12','Defensa',2),('172383095','2009-07-25','Defensa',2),('172394227','2009-04-13','Delantero',2),('175329037','2010-07-11','Mediocampista',1),('177490893','2012-05-27','Portero',1),('178461803','2011-11-07','Mediocampista',1),('178961459','2008-06-30','Defensa',2),('181030736','2012-04-21','Delantero',1),('181756179','2010-10-11','Delantero',1),('185758349','2010-01-19','Defensa',2),('186028436','2011-11-15','Mediocampista',1),('188447167','2008-12-02','Mediocampista',2),('190377459','2008-09-05','Portero',2),('190825067','2010-12-13','Portero',1),('191306093','2010-06-10','Delantero',1),('191887369','2011-08-10','Delantero',1),('195004803','2008-10-10','Portero',2);
/*!40000 ALTER TABLE `jugador` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tgr_BI_jugador` BEFORE INSERT ON `jugador` FOR EACH ROW BEGIN
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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tgr_BU_jugador` BEFORE UPDATE ON `jugador` FOR EACH ROW BEGIN
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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `log_entrenamiento`
--

DROP TABLE IF EXISTS `log_entrenamiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_entrenamiento` (
  `id_log` int NOT NULL AUTO_INCREMENT,
  `id_entrenamiento` int NOT NULL,
  `estado_anterior` varchar(20) NOT NULL,
  `estado_nuevo` varchar(20) NOT NULL,
  `fecha_cambio` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_db` varchar(50) NOT NULL,
  PRIMARY KEY (`id_log`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COMMENT='Tabla de auditoria para cambios de estado en entrenamientos.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_entrenamiento`
--

LOCK TABLES `log_entrenamiento` WRITE;
/*!40000 ALTER TABLE `log_entrenamiento` DISABLE KEYS */;
INSERT INTO `log_entrenamiento` VALUES (1,7,'programado','realizado','2026-05-17 20:26:58','root@localhost'),(2,8,'programado','realizado','2026-05-17 20:43:29','root@localhost'),(3,8,'realizado','cancelado','2026-05-17 20:50:14','root@localhost'),(4,8,'cancelado','programado','2026-05-17 20:50:16','root@localhost'),(5,7,'realizado','cancelado','2026-05-17 21:05:05','root@localhost'),(6,9,'programado','realizado','2026-05-17 22:19:23','root@localhost'),(7,10,'programado','realizado','2026-05-18 13:00:25','root@localhost'),(8,10,'realizado','cancelado','2026-05-18 13:18:33','root@localhost'),(9,10,'cancelado','programado','2026-05-18 13:26:03','root@localhost'),(10,10,'programado','realizado','2026-05-18 13:26:14','root@localhost'),(11,11,'programado','realizado','2026-05-18 13:27:21','root@localhost');
/*!40000 ALTER TABLE `log_entrenamiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lugar`
--

DROP TABLE IF EXISTS `lugar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lugar` (
  `id_lugar` int NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria autoincremental. Identifica de forma única cada instalación deportiva registrada en el sistema',
  `nombre` varchar(100) NOT NULL COMMENT 'Nombre oficial o coloquial del lugar o cancha. Ej: Cancha Principal, Estadio El Bosque',
  `descripcion` text COMMENT 'Descripción libre del espacio físico. Incluye características como tipo de superficie, capacidad o condiciones del terreno',
  `direccion` varchar(255) NOT NULL COMMENT 'Dirección física completa del lugar incluyendo calle, barrio y ciudad para facilitar la ubicación del entrenador',
  PRIMARY KEY (`id_lugar`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COMMENT='Catálogo de instalaciones deportivas donde se llevan a cabo \nlas sesiones de entrenamiento. Permite al entrenador gestionar \ny consultar los espacios físicos disponibles, asociando cada \nsesión a un lugar específico para facilitar la planificación \ny organización logística de la academia.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lugar`
--

LOCK TABLES `lugar` WRITE;
/*!40000 ALTER TABLE `lugar` DISABLE KEYS */;
INSERT INTO `lugar` VALUES (1,'Cancha Principal El Bosque','Cancha de grama sintética de última generación. Dimensiones reglamentarias 105 x 68 m. Iluminación LED nocturna, camerinos y bodega de materiales. Capacidad 200 espectadores.','Cra. 9 #131A-02, Usaquén, Bogotá D.C.'),(2,'Cancha Auxiliar Norte','Campo de tierra compactada con arcos fijos. Ideal para trabajos técnicos y físicos. Sin graderías. Contigua a la sede administrativa de la academia.','Av. Boyacá #153-00, Suba, Bogotá D.C.'),(3,'Centro Deportivo Compensar Álamos','Complejo multideportivo con cancha de césped natural certificada FIFA. Acceso controlado, parqueadero y servicio de cafetería. Reserva con 48 horas de anticipación.','Av. El Dorado #68B-85, Fontibón, Bogotá D.C.');
/*!40000 ALTER TABLE `lugar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `persona`
--

DROP TABLE IF EXISTS `persona`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `persona` (
  `identificacion` varchar(15) NOT NULL COMMENT 'Clave primaria. Número de documento de identidad de la persona. Puede ser cédula de ciudadanía para mayores de edad o tarjeta de identidad para menores',
  `nombre` varchar(45) NOT NULL COMMENT 'Nombre o nombres de la persona tal como aparece en su documento de identidad',
  `apellido` varchar(45) NOT NULL COMMENT 'Apellido o apellidos de la persona tal como aparece en su documento de identidad',
  PRIMARY KEY (`identificacion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Entidad padre de la jerarquía de generalización. Almacena los \natributos comunes a todas las personas registradas en el sistema: \nentrenadores, jugadores y acudientes. Implementa herencia por \ntabla por tipo (Table-per-Type). La identificación puede ser \ncédula de ciudadanía o tarjeta de identidad según la edad.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `persona`
--

LOCK TABLES `persona` WRITE;
/*!40000 ALTER TABLE `persona` DISABLE KEYS */;
INSERT INTO `persona` VALUES ('100435578','Brayan','Salcedo Reyes'),('1020485632','Carlos Andrés','Herrera Ospina'),('103356886','Brayan','Torres Ramírez'),('104265799','Santiago','Martínez Sánchez'),('104308421','Nicolás','Vargas Torres'),('10578655','Pilar','Sánchez Mora'),('111496211','Brayan','Ruiz Muñoz'),('112517517','Omar','Morales Ramírez'),('114665841','David','Sánchez Sánchez'),('116879290','Sebastián','Rojas Ruiz'),('118566572','Cristian','Ruiz Martínez'),('119175900','Miguel','González Ramírez'),('120514014','Carlos','Pérez Valencia'),('121429110','Yeison','Castro Ríos'),('123978249','Cristian','Ospina López'),('128538251','Carlos','Ruiz Vargas'),('128754377','Kevin','González Reyes'),('129587039','Julián','Jiménez Torres'),('132138745','Andrés','Ramírez Salcedo'),('132614537','Esteban','Valencia Castro'),('135575298','Cristian','Morales Herrera'),('137308985','Julián','Medina Muñoz'),('138840994','Juan Pablo','Morales Ramírez'),('144349361','Juan Pablo','Díaz Ramírez'),('14440493','Ricardo','Suárez Martínez'),('145176955','Camilo','Martínez Vargas'),('147683626','Daniel','Rojas Torres'),('15045580','Fernando','Martínez Pérez'),('150806024','Juan Pablo','Suárez Flores'),('150864911','Santiago','Vargas Torres'),('151642594','Samuel','Herrera Ortiz'),('153551839','Diego','Medina Mora'),('156623995','Felipe','Torres Ortiz'),('159476001','Kevin','López Rodríguez'),('160597444','Camilo','Ramírez Ramírez'),('162043515','Samuel','Torres Ospina'),('16399185','Carlos','Jiménez Muñoz'),('16409749','María','Vargas Rodríguez'),('164606833','Daniel','Morales Vargas'),('165579548','Santiago','López Ospina'),('16887758','Jorge','Herrera Ortiz'),('172383095','Omar','Reyes Silva'),('172394227','Omar','Ospina Díaz'),('175329037','Daniel','Silva Medina'),('177490893','Daniel','Silva Martínez'),('178461803','Tomás','Salcedo Jiménez'),('178961459','Kevin','Ramírez Jiménez'),('181030736','Miguel','Valencia Rodríguez'),('181756179','Carlos','Pérez Suárez'),('185758349','Cristian','Herrera Sánchez'),('186028436','Nicolás','López Flores'),('188447167','Tomás','Mora Castro'),('190377459','Carlos','Medina López'),('190825067','Brayan','Salcedo Suárez'),('191306093','Brayan','López Rojas'),('191887369','Nicolás','Muñoz Cruz'),('195004803','Carlos','Rodríguez Ramírez'),('20143030','Hernando','Valencia Flores'),('20933779','Gustavo','Muñoz Suárez'),('24736089','Carmen','Pérez Rodríguez'),('25417234','Rodrigo','Díaz García'),('27537375','Claudia','González Salcedo'),('28228930','María','Vargas Ríos'),('30191718','Nohora','Silva Herrera'),('33063559','Patricia','López Ruiz'),('33372013','Ana','González Flores'),('36607312','Ana','Suárez Ospina'),('38378349','Elena','Rodríguez Medina'),('39340526','Jairo','Reyes Ríos'),('40905340','Patricia','Herrera Pérez'),('41036051','Diana','Cruz Morales'),('43576939','Diana','Pérez Mora'),('45102952','Beatriz','Ríos Castro'),('49041568','Pilar','Torres Castro'),('52748901','Mónica Patricia','Ruiz Castellanos'),('52829744','Patricia','Salcedo Suárez'),('53029632','Alberto','Ospina Rojas'),('55473870','Ricardo','Morales Jiménez'),('57487375','Nohora','Cruz González'),('58546900','Hernando','Morales Muñoz'),('61358985','Nelson','Salcedo Silva'),('62091490','Henry','Mora Muñoz'),('62970508','Ana','Morales Valencia'),('63607919','Claudia','Muñoz Valencia'),('64039108','Ana','Ruiz Ríos'),('67098936','Nelson','Castro Martínez'),('68762647','Elena','Martínez Salcedo'),('68932463','Elena','Flores Pérez'),('69285932','Pilar','Silva Pérez'),('72817182','Nohora','Reyes Castro'),('73935066','Carmen','Salcedo Ospina'),('78600822','Gustavo','Reyes Pérez'),('81244461','Alberto','Reyes Vargas'),('81370067','María','López Díaz'),('81713878','Liliana','Sánchez Mora'),('84789973','Liliana','Flores Mora'),('86452826','Gustavo','Reyes García'),('91327628','Elena','Medina Muñoz'),('92304466','Martha','Sánchez Castro'),('93035455','Carmen','Rojas Herrera'),('97823232','Jorge','Flores Morales'),('99632857','Jorge','Salcedo Rojas'),('99999999','Admin','FutbolTrack');
/*!40000 ALTER TABLE `persona` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'mydb'
--

--
-- Dumping routines for database 'mydb'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_calcular_edad_jugador` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_calcular_edad_jugador`(
    param_fecha_nacimiento DATE
) RETURNS int
    READS SQL DATA
    DETERMINISTIC
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_calcular_porcentaje_asistencia` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_calcular_porcentaje_asistencia`(
    param_id_jugador VARCHAR(15)
) RETURNS decimal(5,2)
    READS SQL DATA
    COMMENT 'Retorna el % de asistencia (presentes / sesiones realizadas) de un jugador.'
BEGIN
    -- Declaración de variables locales (Nomenclatura del curso)
    DECLARE vn_total_sesiones  INT DEFAULT 0;
    DECLARE vn_total_presentes INT DEFAULT 0;
    DECLARE vn_existe_jugador  INT DEFAULT 0;
    DECLARE vn_id_categoria    INT DEFAULT 0;
    
    -- Variable vdo_ para tipos Double/Decimal
    DECLARE vdo_porcentaje     DECIMAL(5,2);

    -- ===========================================================
    -- PASO 1 - VALIDACIÓN: Verificar que el jugador existe
    -- ===========================================================
    SELECT COUNT(*), IFNULL(MAX(id_categoria), 0)
      INTO vn_existe_jugador, vn_id_categoria
      FROM jugador
     WHERE identificacion_jugador = param_id_jugador;

    IF vn_existe_jugador = 0 THEN
        RETURN NULL;
    END IF;

    -- ===========================================================
    -- PASO 2 - LÓGICA: Contar sesiones totales REALIZADAS
    -- ===========================================================
    SELECT COUNT(*)
      INTO vn_total_sesiones
      FROM entrenamiento
     WHERE id_categoria = vn_id_categoria
       AND estado = 'realizado';

    -- Si no hay sesiones realizadas, no hay porcentaje que calcular (evita división por cero)
    IF vn_total_sesiones = 0 THEN
        RETURN NULL;
    END IF;

    -- ===========================================================
    -- PASO 3 - LÓGICA: Contar asistencias marcadas como 'presente'
    -- ===========================================================
    SELECT COUNT(*)
      INTO vn_total_presentes
      FROM asistencia     a
      JOIN entrenamiento  e ON a.id_entrenamiento = e.id_entrenamiento
     WHERE a.identificacion_jugador = param_id_jugador
       AND a.estado_asistencia      = 'presente'
       AND e.estado                 = 'realizado';

    -- ===========================================================
    -- PASO 4 - CÁLCULO FINAL Y RETORNO
    -- ===========================================================
    SET vdo_porcentaje = ROUND((vn_total_presentes / vn_total_sesiones) * 100, 2);
    
    RETURN vdo_porcentaje;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_contar_sesiones_categoria` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_contar_sesiones_categoria`(
    param_id_categoria INT
) RETURNS int
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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_jugador_activo_en_categoria` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_jugador_activo_en_categoria`(
    param_identificacion_jugador VARCHAR(15),
    param_id_categoria           INT
) RETURNS int
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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_actualizar_estado_entrenamiento` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_estado_entrenamiento`(
    IN  param_id_entrenamiento INT,
    IN  param_nuevo_estado     VARCHAR(45),
    OUT param_mensaje          VARCHAR(500)
)
    COMMENT 'Actualiza el estado de un entrenamiento. Sin control transaccional interno.'
sp_main: BEGIN

    -- Declaración de variables (Nomenclatura del curso)
    DECLARE vn_existe_entren   INT         DEFAULT 0;
    DECLARE vv_estado_actual   VARCHAR(20) DEFAULT '';

    -- Manejo de excepciones
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET param_mensaje = 'ERROR: Excepcion inesperada en base de datos. Orquestador debe revertir.';
    END;

    -- ===========================================================
    -- PASO 1 - VALIDAR PARÁMETROS BÁSICOS
    -- ===========================================================

    -- 1.1 Validar nulos
    IF param_id_entrenamiento IS NULL OR param_id_entrenamiento <= 0 THEN
        SET param_mensaje = 'ERROR: El ID del entrenamiento es obligatorio y debe ser positivo.';
        LEAVE sp_main;
    END IF;

    IF TRIM(IFNULL(param_nuevo_estado, '')) = '' THEN
        SET param_mensaje = 'ERROR: El nuevo estado es obligatorio.';
        LEAVE sp_main;
    END IF;

    -- 1.2 Validación de dominio del Estado
    IF param_nuevo_estado NOT IN ('programado', 'realizado', 'cancelado') THEN
        SET param_mensaje = 'ERROR: Estado inválido. Valores aceptados: programado, realizado, cancelado.';
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 2 - LÓGICA DE NEGOCIO Y VALIDACIÓN DE ESTADO PREVIO
    -- ===========================================================

    -- 2.1 Verificar que el entrenamiento exista y obtener su estado actual
    SELECT COUNT(*), IFNULL(MAX(estado), '')
      INTO vn_existe_entren, vv_estado_actual
      FROM entrenamiento
     WHERE id_entrenamiento = param_id_entrenamiento;

    IF vn_existe_entren = 0 THEN
        SET param_mensaje = CONCAT('ERROR: No existe un entrenamiento con ID ', param_id_entrenamiento, '.');
        LEAVE sp_main;
    END IF;

    -- 2.2 Verificar que haya un cambio real
    IF vv_estado_actual = param_nuevo_estado THEN
        SET param_mensaje = CONCAT('Aviso: El entrenamiento ya se encuentra en estado "', vv_estado_actual, '". No se realizaron cambios.');
        LEAVE sp_main;
    END IF;

    -- 2.3 Prevenir transiciones ilógicas (respaldo a la lógica del trigger)
    IF vv_estado_actual = 'realizado' AND param_nuevo_estado = 'programado' THEN
        SET param_mensaje = 'ERROR DE LÓGICA: Un entrenamiento que ya fue "realizado" no puede volver a estar "programado".';
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 3 - ACTUALIZACIÓN (DML)
    -- ===========================================================
    
    UPDATE entrenamiento
       SET estado = param_nuevo_estado
     WHERE id_entrenamiento = param_id_entrenamiento;

    -- ===========================================================
    -- PASO 4 - MENSAJE DE EXITO AL PARAMETRO OUT
    -- ===========================================================
    SET param_mensaje = CONCAT(
        'OK: El estado del entrenamiento ID ', param_id_entrenamiento, 
        ' fue actualizado de "', vv_estado_actual, '" a "', param_nuevo_estado, '".'
    );

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_crear_entrenamiento` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_entrenamiento`(
    IN  param_fecha             DATE,
    IN  param_hora_inicio       TIME,
    IN  param_hora_fin          TIME,
    IN  param_tipo              VARCHAR(45),
    IN  param_id_lugar          INT,
    IN  param_id_categoria      INT,
    IN  param_cedula_entrenador VARCHAR(15),
    OUT param_mensaje           VARCHAR(500)
)
BEGIN
    DECLARE v_duracion_minutos  INT;
    DECLARE v_ahora_fecha       DATE;
    DECLARE v_ahora_hora        TIME;
    DECLARE v_id_entrenamiento  INT;
    DECLARE v_count             INT DEFAULT 0;

    SET v_ahora_fecha = CURDATE();
    SET v_ahora_hora  = CURTIME();

    -- 1. Fecha no puede ser anterior a hoy
    IF param_fecha < v_ahora_fecha THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: La fecha no puede ser anterior al día actual.';
    END IF;

    -- 2. Si es hoy, hora_inicio no puede ser anterior a la hora actual
    IF param_fecha = v_ahora_fecha AND param_hora_inicio < v_ahora_hora THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: La hora de inicio no puede ser anterior a la hora actual.';
    END IF;

    -- 3. hora_inicio entre 06:00 y 22:00
    IF param_hora_inicio < '06:00:00' OR param_hora_inicio > '22:00:00' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: La hora de inicio debe estar entre 06:00 y 22:00.';
    END IF;

    -- 4. hora_fin entre 06:00 y 22:00
    IF param_hora_fin < '06:00:00' OR param_hora_fin > '22:00:00' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: La hora de fin debe estar entre 06:00 y 22:00.';
    END IF;

    -- 5. Duración mínima 1 hora, máximo 2 horas
    SET v_duracion_minutos = TIMESTAMPDIFF(MINUTE, param_hora_inicio, param_hora_fin);
    IF v_duracion_minutos < 60 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: La duración mínima del entrenamiento es 1 hora.';
    END IF;
    IF v_duracion_minutos > 120 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: La duración máxima del entrenamiento es 2 horas.';
    END IF;

    -- 6. Un entrenamiento por día por entrenador
    SELECT COUNT(*) INTO v_count
    FROM entrenamiento
    WHERE cedula_entrenador = param_cedula_entrenador
      AND fecha = param_fecha
      AND estado != 'cancelado';

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Ya tienes un entrenamiento programado para ese día.';
    END IF;

    -- 7. No cruzar horario con otro entrenador (solapamiento)
    SELECT COUNT(*) INTO v_count
    FROM entrenamiento
    WHERE fecha = param_fecha
      AND estado != 'cancelado'
      AND cedula_entrenador != param_cedula_entrenador
      AND param_hora_inicio < hora_fin
      AND param_hora_fin    > hora_inicio;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: El horario se cruza con otro entrenamiento existente.';
    END IF;

    -- 8. Lugar no disponible en ese horario
    SELECT COUNT(*) INTO v_count
    FROM entrenamiento
    WHERE fecha      = param_fecha
      AND id_lugar   = param_id_lugar
      AND estado    != 'cancelado'
      AND param_hora_inicio < hora_fin
      AND param_hora_fin    > hora_inicio;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: El lugar ya está ocupado en ese horario.';
    END IF;
    
    -- Máximo 3 entrenamientos por semana por categoría
SELECT COUNT(*) INTO v_count
FROM entrenamiento
WHERE id_categoria = param_id_categoria
  AND estado != 'cancelado'
  AND YEARWEEK(fecha, 1) = YEARWEEK(param_fecha, 1);

IF v_count >= 3 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'ERROR: Ya hay 3 entrenamientos programados para esa categoría en la semana.';
END IF;

    -- 9. Insertar entrenamiento
    INSERT INTO entrenamiento
        (fecha, hora_inicio, hora_fin, tipo, id_lugar, id_categoria, cedula_entrenador)
    VALUES
        (param_fecha, param_hora_inicio, param_hora_fin, param_tipo,
         param_id_lugar, param_id_categoria, param_cedula_entrenador);

    SET v_id_entrenamiento = LAST_INSERT_ID();

    -- 10. AUTO: insertar asistencia 'ausente' para todos los jugadores de la categoría
    INSERT INTO asistencia (id_entrenamiento, identificacion_jugador, estado_asistencia)
    SELECT v_id_entrenamiento, j.identificacion_jugador, 'ausente'
    FROM jugador j
    WHERE j.id_categoria = param_id_categoria;

    SET param_mensaje = CONCAT('OK:', v_id_entrenamiento);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_eliminar_jugador` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_jugador`(
    IN  param_identificacion_jugador  VARCHAR(15),
    OUT param_mensaje                 VARCHAR(500)
)
    COMMENT 'Elimina un jugador verificando restricciones de asistencia y limpiando datos huerfanos.'
sp_main: BEGIN

    -- Declaración de variables (Nomenclatura del curso)
    DECLARE vn_existe_jugador    INT          DEFAULT 0;
    DECLARE vn_tiene_asistencia  INT          DEFAULT 0;
    DECLARE vv_cedula_acudiente  VARCHAR(15)  DEFAULT NULL;
    DECLARE vn_acudiente_otros   INT          DEFAULT 0;
    DECLARE vv_nombre_jugador    VARCHAR(100) DEFAULT '';

    -- Manejo de excepciones
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET param_mensaje = 'ERROR: Excepcion inesperada en base de datos. Orquestador debe revertir.';
    END;

    -- ===========================================================
    -- PASO 1 - VALIDAR PARÁMETROS IN
    -- ===========================================================
    IF TRIM(IFNULL(param_identificacion_jugador, '')) = '' THEN
        SET param_mensaje = 'ERROR: La identificacion del jugador es obligatoria.';
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 2 - VALIDACIÓN DE EXISTENCIA E INTEGRIDAD (RF-JU04)
    -- ===========================================================
    
    -- 2.1 Verificar que el jugador exista
    SELECT COUNT(*) INTO vn_existe_jugador 
      FROM jugador 
     WHERE identificacion_jugador = param_identificacion_jugador;

    IF vn_existe_jugador = 0 THEN
        SET param_mensaje = CONCAT('ERROR: No se encontro ningun jugador con la identificacion ', param_identificacion_jugador);
        LEAVE sp_main;
    END IF;

    -- 2.2 Bloquear si tiene asistencias (Regla de negocio)
    SELECT COUNT(*) INTO vn_tiene_asistencia 
      FROM asistencia 
     WHERE identificacion_jugador = param_identificacion_jugador;

    IF vn_tiene_asistencia > 0 THEN
        SET param_mensaje = CONCAT('ERROR: No se puede eliminar el jugador. Tiene ', vn_tiene_asistencia, ' registro(s) de asistencia asociados.');
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 3 - RECUPERAR DATOS ANTES DE ELIMINAR
    -- ===========================================================
    
    -- Obtenemos el nombre para el mensaje final y la cedula de su acudiente
    SELECT a.cedula_acudiente, CONCAT(p.nombre, ' ', p.apellido)
      INTO vv_cedula_acudiente, vv_nombre_jugador
      FROM jugador j
      JOIN persona p ON j.identificacion_jugador = p.identificacion
      LEFT JOIN acudiente a ON j.identificacion_jugador = a.identificacion_jugador
     WHERE j.identificacion_jugador = param_identificacion_jugador
     LIMIT 1;

    -- ===========================================================
    -- PASO 4 - INSTRUCCIONES DML (Eliminación en Cascada Manual)
    -- ===========================================================

    -- A. Eliminar al acudiente asociado (Rompe FK hacia jugador)
    DELETE FROM acudiente WHERE identificacion_jugador = param_identificacion_jugador;

    -- B. Eliminar al jugador (Rompe FK hacia persona)
    DELETE FROM jugador WHERE identificacion_jugador = param_identificacion_jugador;

    -- C. Eliminar la persona base del jugador
    DELETE FROM persona WHERE identificacion = param_identificacion_jugador;

    -- D. Validar y limpiar la persona base del acudiente
    -- Solo se elimina de 'persona' si este acudiente no representa a otros jugadores en el sistema.
    IF vv_cedula_acudiente IS NOT NULL THEN
        SELECT COUNT(*) INTO vn_acudiente_otros 
          FROM acudiente 
         WHERE cedula_acudiente = vv_cedula_acudiente;
         
        IF vn_acudiente_otros = 0 THEN
            DELETE FROM persona WHERE identificacion = vv_cedula_acudiente;
        END IF;
    END IF;

    -- ===========================================================
    -- PASO 5 - ASIGNAR RESULTADO OUT
    -- ===========================================================
    SET param_mensaje = CONCAT('OK: El jugador ', vv_nombre_jugador, ' (', param_identificacion_jugador, ') y sus registros asociados fueron eliminados del sistema.');

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_registrar_asistencia_sesion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_asistencia_sesion`(
    IN  param_id_entrenamiento  INT,
    IN  param_json_asistencia   JSON,
    OUT param_mensaje           VARCHAR(500)
)
    COMMENT 'Registra asistencia masiva via JSON. Sin control transaccional interno (delegado al llamador).'
sp_main: BEGIN

    -- 1. Declaracion de Variables (Nomenclatura del curso)
    DECLARE vn_existe_entren   INT          DEFAULT 0;
    DECLARE vv_estado_entren   VARCHAR(20)  DEFAULT '';
    DECLARE vn_id_categoria    INT          DEFAULT 0;
    DECLARE vv_cat_nombre      VARCHAR(60)  DEFAULT '';

    DECLARE vn_total_jugadores INT          DEFAULT 0;
    DECLARE vn_idx             INT          DEFAULT 0;
    DECLARE vv_id_jugador      VARCHAR(15)  DEFAULT '';
    DECLARE vv_estado_asist    VARCHAR(20)  DEFAULT '';
    DECLARE vv_observacion     TEXT;
    DECLARE vn_existe_jugador  INT          DEFAULT 0;
    DECLARE vn_cat_jugador     INT          DEFAULT 0;

    DECLARE vn_presentes       INT          DEFAULT 0;
    DECLARE vn_ausentes        INT          DEFAULT 0;
    DECLARE vn_justificados    INT          DEFAULT 0;

    -- Manejo de excepciones (Equivalente al EXCEPTION WHEN OTHERS)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- ¡OJO! Eliminado el ROLLBACK interno según estándares del curso.
        SET param_mensaje = 'ERROR: Excepcion inesperada en base de datos. Orquestador debe revertir.';
    END;

    -- ===========================================================
    -- PASO 1 - VALIDAR PARAMETROS (Salidas anticipadas con LEAVE)
    -- ===========================================================

    IF param_id_entrenamiento IS NULL OR param_id_entrenamiento <= 0 THEN
        SET param_mensaje = 'ERROR: El ID del entrenamiento es obligatorio y debe ser positivo.';
        LEAVE sp_main;
    END IF;

    IF param_json_asistencia IS NULL OR JSON_LENGTH(param_json_asistencia) = 0 THEN
        SET param_mensaje = 'ERROR: El JSON de asistencia es obligatorio y no puede estar vacio.';
        LEAVE sp_main;
    END IF;

    IF JSON_TYPE(param_json_asistencia) != 'ARRAY' THEN
        SET param_mensaje = 'ERROR: El parametro JSON debe ser un array. Ejemplo: [{"id":"123","estado":"presente","obs":""}]';
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 2 - VALIDAR EL ENTRENAMIENTO
    -- ===========================================================

    SELECT COUNT(*), IFNULL(MAX(estado), ''), IFNULL(MAX(id_categoria), 0)
      INTO vn_existe_entren, vv_estado_entren, vn_id_categoria
      FROM entrenamiento
     WHERE id_entrenamiento = param_id_entrenamiento;

    IF vn_existe_entren = 0 THEN
        SET param_mensaje = CONCAT('ERROR: No existe un entrenamiento con ID ', param_id_entrenamiento, '.');
        LEAVE sp_main;
    END IF;

    IF vv_estado_entren = 'cancelado' THEN
        SET param_mensaje = CONCAT('ERROR: El entrenamiento ID ', param_id_entrenamiento, ' esta cancelado.');
        LEAVE sp_main;
    END IF;

    SELECT IFNULL(MAX(nombre), '') INTO vv_cat_nombre
      FROM categoria WHERE id_categoria = vn_id_categoria;

    -- ===========================================================
    -- PASO 3 - VALIDAR CADA JUGADOR DEL JSON
    -- ===========================================================

    SET vn_total_jugadores = JSON_LENGTH(param_json_asistencia);
    SET vn_idx = 0;

    WHILE vn_idx < vn_total_jugadores DO

        SET vv_id_jugador   = JSON_UNQUOTE(JSON_EXTRACT(param_json_asistencia, CONCAT('$[', vn_idx, '].id')));
        SET vv_estado_asist = JSON_UNQUOTE(JSON_EXTRACT(param_json_asistencia, CONCAT('$[', vn_idx, '].estado')));

        IF vv_estado_asist NOT IN ('presente', 'ausente', 'justificado') THEN
            SET param_mensaje = CONCAT('ERROR: Estado invalido "', vv_estado_asist, '" para jugador ID ', vv_id_jugador);
            LEAVE sp_main;
        END IF;

        SELECT COUNT(*), IFNULL(MAX(id_categoria), 0)
          INTO vn_existe_jugador, vn_cat_jugador
          FROM jugador
         WHERE identificacion_jugador = vv_id_jugador;

        IF vn_existe_jugador = 0 THEN
            SET param_mensaje = CONCAT('ERROR: El jugador con ID "', vv_id_jugador, '" no existe en el sistema.');
            LEAVE sp_main;
        END IF;

        IF vn_cat_jugador != vn_id_categoria THEN
            SET param_mensaje = CONCAT('ERROR: El jugador ID "', vv_id_jugador, '" no pertenece a la categoria ', vv_cat_nombre, '.');
            LEAVE sp_main;
        END IF;

        SET vn_idx = vn_idx + 1;
    END WHILE;

    -- ===========================================================
    -- PASO 4 - UPSERT ASISTENCIA + CAMBIO DE ESTADO
    -- (El COMMIT será manejado por el backend/Python)
    -- ===========================================================
    
    SET vn_idx = 0;

    WHILE vn_idx < vn_total_jugadores DO

        SET vv_id_jugador   = JSON_UNQUOTE(JSON_EXTRACT(param_json_asistencia, CONCAT('$[', vn_idx, '].id')));
        SET vv_estado_asist = JSON_UNQUOTE(JSON_EXTRACT(param_json_asistencia, CONCAT('$[', vn_idx, '].estado')));
        SET vv_observacion  = JSON_UNQUOTE(JSON_EXTRACT(param_json_asistencia, CONCAT('$[', vn_idx, '].obs')));

        IF vv_observacion = '' OR vv_observacion = 'null' THEN
            SET vv_observacion = NULL;
        END IF;

        INSERT INTO asistencia (id_entrenamiento, identificacion_jugador, estado_asistencia, observacion)
        VALUES (param_id_entrenamiento, vv_id_jugador, vv_estado_asist, vv_observacion)
        ON DUPLICATE KEY UPDATE
            estado_asistencia = VALUES(estado_asistencia),
            observacion       = VALUES(observacion);

        IF vv_estado_asist = 'presente'    THEN SET vn_presentes    = vn_presentes    + 1; END IF;
        IF vv_estado_asist = 'ausente'     THEN SET vn_ausentes     = vn_ausentes     + 1; END IF;
        IF vv_estado_asist = 'justificado' THEN SET vn_justificados = vn_justificados + 1; END IF;

        SET vn_idx = vn_idx + 1;
    END WHILE;

    UPDATE entrenamiento
       SET estado = 'realizado'
     WHERE id_entrenamiento = param_id_entrenamiento
       AND estado = 'programado';

    -- ===========================================================
    -- PASO 5 - MENSAJE DE EXITO AL PARAMETRO OUT
    -- ===========================================================
    SET param_mensaje = CONCAT(
        'OK: Asistencia registrada para entrenamiento ID ', param_id_entrenamiento,
        ' (', vv_cat_nombre, '). Total: ', vn_total_jugadores, ' jugadores. ',
        'Presentes: ', vn_presentes, ' | Ausentes: ', vn_ausentes, ' | Justificados: ', vn_justificados, '.'
    );

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_registrar_jugador_completo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_jugador_completo`(
    IN  param_identificacion_jugador  VARCHAR(15),
    IN  param_nombre_jugador          VARCHAR(45),
    IN  param_apellido_jugador        VARCHAR(45),
    IN  param_fecha_nacimiento        DATE,
    IN  param_posicion                VARCHAR(20),
    IN  param_id_categoria            INT,
    IN  param_cedula_acudiente        VARCHAR(15),
    IN  param_nombre_acudiente        VARCHAR(45),
    IN  param_apellido_acudiente      VARCHAR(45),
    IN  param_telefono_acudiente      VARCHAR(20),
    IN  param_parentesco              VARCHAR(30),
    OUT param_mensaje                 VARCHAR(500)
)
    COMMENT 'Registra jugador y acudiente. Sin control transaccional interno.'
sp_main: BEGIN

    -- Declaracion de variables (Nomenclatura del curso)
    DECLARE vn_edad_jugador    INT DEFAULT 0;
    DECLARE vn_edad_min        INT DEFAULT 0;
    DECLARE vn_edad_max        INT DEFAULT 0;
    DECLARE vv_cat_nombre      VARCHAR(60) DEFAULT '';
    DECLARE vn_cat_count       INT DEFAULT 0;
    DECLARE vn_existe_jugador  INT DEFAULT 0;
    DECLARE vn_existe_acudiente INT DEFAULT 0;

    -- Manejo de excepciones (Equivalente al EXCEPTION WHEN OTHERS de la guia)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET param_mensaje = 'ERROR: Excepcion inesperada en base de datos. Orquestador debe revertir.';
    END;

    -- ===========================================================
    -- PASO 1 - VALIDAR PARAMETROS IN (Salida anticipada con LEAVE)
    -- ===========================================================

    -- 1.1 Campos obligatorios
    IF TRIM(IFNULL(param_identificacion_jugador, '')) = '' THEN
        SET param_mensaje = 'ERROR: La identificacion del jugador es obligatoria.';
        LEAVE sp_main; -- Simula el RETURN anticipado
    END IF;

    IF TRIM(IFNULL(param_nombre_jugador, '')) = '' OR TRIM(IFNULL(param_apellido_jugador, '')) = '' THEN
        SET param_mensaje = 'ERROR: El nombre y apellido del jugador son obligatorios.';
        LEAVE sp_main;
    END IF;

    IF param_fecha_nacimiento IS NULL THEN
        SET param_mensaje = 'ERROR: La fecha de nacimiento es obligatoria.';
        LEAVE sp_main;
    END IF;

    IF TRIM(IFNULL(param_cedula_acudiente, '')) = '' THEN
        SET param_mensaje = 'ERROR: La cedula del acudiente es obligatoria.';
        LEAVE sp_main;
    END IF;

    IF TRIM(IFNULL(param_nombre_acudiente, '')) = '' OR TRIM(IFNULL(param_apellido_acudiente, '')) = '' THEN
        SET param_mensaje = 'ERROR: El nombre y apellido del acudiente son obligatorios.';
        LEAVE sp_main;
    END IF;

    IF TRIM(IFNULL(param_telefono_acudiente, '')) = '' THEN
        SET param_mensaje = 'ERROR: El telefono del acudiente es obligatorio.';
        LEAVE sp_main;
    END IF;

    -- 1.2 Identificaciones distintas
    IF param_identificacion_jugador = param_cedula_acudiente THEN
        SET param_mensaje = 'ERROR: La identificacion del jugador y la del acudiente no pueden ser iguales.';
        LEAVE sp_main;
    END IF;

    -- 1.3 Posicion valida
    IF param_posicion NOT IN ('Portero', 'Defensa', 'Mediocampista', 'Delantero') THEN
        SET param_mensaje = 'ERROR: Posicion invalida. Valores: Portero, Defensa, Mediocampista, Delantero.';
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 2 - LOGICA DE NEGOCIO (Consultas y validaciones)
    -- ===========================================================

    -- 2.1 Jugador no duplicado
    SELECT COUNT(*) INTO vn_existe_jugador FROM persona WHERE identificacion = param_identificacion_jugador;
    IF vn_existe_jugador > 0 THEN
        SET param_mensaje = 'ERROR: Ya existe una persona con esa identificacion de jugador.';
        LEAVE sp_main;
    END IF;

    -- 2.2 Acudiente no duplicado
    SELECT COUNT(*) INTO vn_existe_acudiente FROM persona WHERE identificacion = param_cedula_acudiente;
    IF vn_existe_acudiente > 0 THEN
        SET param_mensaje = 'ERROR: Ya existe una persona con esa cedula de acudiente.';
        LEAVE sp_main;
    END IF;

    -- 2.3 Categoria existe
    SELECT COUNT(*), IFNULL(MIN(edad_minima), 0), IFNULL(MAX(edad_maxima), 0), IFNULL(MAX(nombre), '')
      INTO vn_cat_count, vn_edad_min, vn_edad_max, vv_cat_nombre
      FROM categoria WHERE id_categoria = param_id_categoria;

    IF vn_cat_count = 0 THEN
        SET param_mensaje = 'ERROR: La categoria especificada no existe.';
        LEAVE sp_main;
    END IF;

    -- 2.4 Edad coherente con la categoria
    SET vn_edad_jugador = TIMESTAMPDIFF(YEAR, param_fecha_nacimiento, CURDATE());
    IF vn_edad_jugador < vn_edad_min OR vn_edad_jugador > vn_edad_max THEN
        SET param_mensaje = CONCAT('ERROR: El jugador tiene ', vn_edad_jugador, ' anio(s). ',
                                   'La categoria ', vv_cat_nombre, ' requiere entre ',
                                   vn_edad_min, ' y ', vn_edad_max, ' anios.');
        LEAVE sp_main;
    END IF;

    -- ===========================================================
    -- PASO 3 - EJECUCION DE DML (Sin COMMIT interno)
    -- ===========================================================

    INSERT INTO persona (identificacion, nombre, apellido)
    VALUES (param_identificacion_jugador, TRIM(param_nombre_jugador), TRIM(param_apellido_jugador));

    INSERT INTO jugador (identificacion_jugador, fecha_nacimiento, posicion, id_categoria)
    VALUES (param_identificacion_jugador, param_fecha_nacimiento, param_posicion, param_id_categoria);

    INSERT INTO persona (identificacion, nombre, apellido)
    VALUES (param_cedula_acudiente, TRIM(param_nombre_acudiente), TRIM(param_apellido_acudiente));

    INSERT INTO acudiente (cedula_acudiente, telefono, parentesco, identificacion_jugador)
    VALUES (param_cedula_acudiente, param_telefono_acudiente, TRIM(param_parentesco), param_identificacion_jugador);

    -- ===========================================================
    -- PASO 4 - ASIGNAR RESULTADO OUT (Exito)
    -- ===========================================================
    SET param_mensaje = CONCAT(
        'OK: Jugador "', TRIM(param_nombre_jugador), ' ', TRIM(param_apellido_jugador),
        '" (', param_identificacion_jugador, ') registrado en ', vv_cat_nombre,
        ' como ', param_posicion, '. Acudiente "',
        TRIM(param_nombre_acudiente), ' ', TRIM(param_apellido_acudiente),
        '" vinculado. Parentesco: ', TRIM(param_parentesco), '.'
    );

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-18 19:55:55
