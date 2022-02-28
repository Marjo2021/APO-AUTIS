-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 26-02-2022 a las 18:13:38
-- Versión del servidor: 10.4.14-MariaDB
-- Versión de PHP: 7.4.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `apo_autis`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Sp_evaluar_contrasena_actual` (IN `Usuario` VARCHAR(100))  NO SQL
BEGIN
START TRANSACTION;
SELECT AES_DECRYPT(Contrasena,'SI-IO') Contrasena,
Nombre_usuario, Cod_rol
FROM tbl_usuario
WHERE
Nombre_usuario=Usuario;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Sp_evaluar_hist_contraseña` (IN `CONTRASENA` VARCHAR(50), IN `USUARIO` BIGINT)  NO SQL
BEGIN
START TRANSACTION;
SELECT * FROM tbl_historial_contrasena c WHERE c.Cod_usuario = USUARIO AND AES_DECRYPT(c.CONTRASENA,'SI-IO') = CONTRASENA;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Sp_insertar_historial_contrasena` (IN `CONTRASENA` VARCHAR(50), IN `USUARIO` BIGINT)  NO SQL
BEGIN
START TRANSACTION;
IF NOT EXISTS (SELECT * FROM tbl_usuario u WHERE u.Cod_usuario = USUARIO) THEN
SET @m='EL USUARIO QUE INGRESO NO EXISTE';
SELECT @m;
ELSE
INSERT INTO tbl_historial_contrasena(
    Cod_usuario,
    Contrasena,
    Fecha_cambio
)VALUES(
    USUARIO,
    AES_ENCRYPT(CONTRASENA,'SI-IO'),
    now()
);
END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INSERTAR_PARAMETRO` (IN `PARAMETRO` VARCHAR(30), IN `VALOR` VARCHAR(200), IN `USUARIO` VARCHAR(10))  NO SQL
BEGIN

START TRANSACTION;
    IF NOT EXISTS (SELECT * FROM tbl_usuario u WHERE u.Nombre_usuario=USUARIO) THEN
        SET @mensaje='Registro de usuario no existente';
            SELECT @mensaje;
    ELSE
    SET @VALOR1= (SELECT Cod_usuario from tbl_usuario u where  u.Nombre_usuario=USUARIO);
    SELECT @VALOR1;

    INSERT INTO tbl_parametro(Cod_usuario,
                                Parametro,
                                Valor,
                                Fecha_registro)
                        VALUES (@VALOR1,
                                 PARAMETRO,
                                 VALOR,
                                 NOW());
END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INSERT_CORREO` (IN `COD_PERSONA` BIGINT(10), IN `USUARIO` VARCHAR(10), IN `CORREO` VARCHAR(50))  NO SQL
BEGIN
    
START TRANSACTION;   

-- VALIDAR QUE EL NOMBRE DE USUARIO NO EXISTA EN LA TABLA USUARIO 
IF NOT EXISTS (SELECT * FROM tbl_usuario u WHERE u.Nombre_usuario=USUARIO) THEN
	SET @mensaje='Registro de usuario no existente';
        SELECT @mensaje;

ELSE
SET @VALOR1= (SELECT Cod_usuario from tbl_usuario u where  u.Nombre_usuario=USUARIO);
    SELECT @VALOR1;

-- HACER EL INSERT A LA TABLA CON LOS PARAMETROS Y INGRESADOS Y LAS VARIABLES DECLARADA
    INSERT INTO tbl_correo (`Cod_persona`, 
                            `Cod_usuario`, 
                            `Correo_Electronico`) 
                    VALUES  (COD_PERSONA, 
                            @VALOR1, 
                            CORREO);
END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INSERT_PERMISO` (IN `ROL` VARCHAR(15), IN `OBJETO` VARCHAR(50), IN `INSERTAR` VARCHAR(10), IN `ELIMINAR` VARCHAR(10), IN `ACTUALIZAR` VARCHAR(10), IN `CONSULTAR` VARCHAR(10))  NO SQL
BEGIN
    
START TRANSACTION;  

   -- VALIDAR QUE EL ROL EXISTA
IF NOT EXISTS (SELECT * FROM tbl_rol r WHERE r.Rol= ROL) THEN
	SET @mensaje='Registro de Rol no existente';
    SELECT @mensaje;

ELSE
    SET @VALOR1= (SELECT Cod_rol from tbl_rol r where r.Rol= ROL);
    SELECT @VALOR1;

    SET @VALOR2= (SELECT Cod_objeto from tbl_objetos o WHERE o.Nombre_objeto= OBJETO);
    SELECT @VALOR2;
    
    INSERT INTO tbl_permisos (Cod_rol,
                             Cod_objeto, 
                             Permiso_insertar, 
                             Permiso_eliminar, 
                             Permiso_actualizar, 
                             Permiso_consultar) 
                    VALUES  (@VALOR1, 
                            @VALOR2, 
                            INSERTAR, 
                            ELIMINAR, 
                            ACTUALIZAR, 
                            CONSULTAR);
END IF;    
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INSERT_PREGUNTA` (IN `Pregunta` VARCHAR(60))  NO SQL
BEGIN
START TRANSACTION;
IF EXISTS (SELECT * FROM tbl_preguntas p WHERE p.Pregunta = Pregunta) THEN
    SET @m='La pregunta que desea ingresar ya existe';
       SELECT @m;
ELSE
    INSERT INTO     tbl_preguntas (Pregunta)
            VALUES (Pregunta);
END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INSERT_RESPUESTAS_USUARIO` (IN `USUARIO` VARCHAR(10), IN `PREGUNTA` VARCHAR(60), IN `RESPUESTA` VARCHAR(50))  NO SQL
BEGIN
START TRANSACTION;

IF NOT EXISTS (SELECT * FROM tbl_usuario u WHERE u.Nombre_usuario = USUARIO) THEN
    SET @m='Registro de usuario no existente';
        SELECT @m;
ELSE
	SET @COD=(SELECT Cod_usuario FROM tbl_usuario u WHERE u.Nombre_usuario = USUARIO);
        SELECT @COD;
        
    SET @COD1=(SELECT Cod_pregunta FROM tbl_preguntas p WHERE p.Pregunta = PREGUNTA);
        SELECT @COD1;
	
    INSERT INTO tbl_pregunta_usuario (Cod_usuario, Cod_pregunta, Respuesta) VALUES (@COD,
                                                                                    @COD1,
                                                                                     RESPUESTA);
END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INSERT_ROL` (IN `ROL` VARCHAR(15), IN `DESCRIPCION` VARCHAR(60), IN `ESTATUS` VARCHAR(15), IN `USUARIO_REGISTRO` VARCHAR(10))  NO SQL
BEGIN

START TRANSACTION;

-- validamos que el rol no exista en la base de datos 
if exists(select * from tbl_rol r where r.Rol= ROL) then
SET @mensaje = 'Registro de Rol ya existente';
    SELECT @mensaje;
ELSE
-- extraer el codigo de estatus
SET @VALOR1= (SELECT Cod_estatus from tbl_estatus e where e.Estatus= ESTATUS);
    SELECT @VALOR1;

-- insertamos valores
    INSERT INTO tbl_rol (Rol, 
                         Descripcion,
                         Cod_estatus,
                         Usuario_registro,
                         Fecha_registro)
    		VALUES	(ROL,
                         DESCRIPCION,
                         @VALOR1,
                         USUARIO_REGISTRO,
                         NOW());
END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INSERT_SEDE` (IN `COD_DEPARTAMENTO` VARCHAR(5), IN `ESTATUS` VARCHAR(15), IN `NOMBRE` VARCHAR(30), IN `DIRECCION` VARCHAR(60), IN `TELEFONO` INT(15), IN `CORREO` VARCHAR(60), IN `REDES_SOCIALES` VARCHAR(60), IN `ADMIN_GENERAL` VARCHAR(50), IN `USUARIO_REGISTRO` VARCHAR(10))  NO SQL
BEGIN
    
START TRANSACTION;  

if exists(select * from tbl_sede s where s.Nombre_sede= NOMBRE AND s.Direccion_sede=DIRECCION) then
SET @mensaje = 'Registro de Sede ya existente';
    SELECT @mensaje;

ELSE

    SET @VALOR1= (SELECT Cod_estatus from tbl_estatus e WHERE e.Estatus= ESTATUS);
    SELECT @VALOR1;
    
    INSERT INTO tbl_sede 	(Cod_departamento,
                            Cod_estatus, 
                            Nombre_sede, 
                            Direccion_sede, 
                            Telefono_sede, 
                            Correo_electronico_sede,
                            Redes_sociales,
                            Administrador_general,
                            Usuario_registro) 
                    VALUES  (COD_DEPARTAMENTO, 
                            @VALOR1, 
                            NOMBRE, 
                            DIRECCION, 
                            TELEFONO, 
                            CORREO,
                            REDES_SOCIALES,
                            ADMIN_GENERAL,
                            USUARIO_REGISTRO);  
END IF;          
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INSERT_USUARIO` (IN `ROL` VARCHAR(15), IN `COD_COLABORADOR` VARCHAR(10), IN `SEDE` VARCHAR(30), IN `ESTATUS` VARCHAR(15), IN `NOMBRE` VARCHAR(10), IN `CONTRASENA` VARCHAR(60), IN `USUARIO_REGISTRO` VARCHAR(10))  NO SQL
BEGIN
    
START TRANSACTION;   

-- VALIDAR QUE EL NOMBRE DE USUARIO NO EXISTA EN LA TABLA USUARIO 
IF EXISTS (SELECT * FROM tbl_usuario u WHERE u.Nombre_usuario=NOMBRE) THEN
	SET @mensaje='Nombre de usuario ya registrado';
        SELECT @mensaje;

-- VALIDAR QUE LA CONTRASEÑA DEL USUARIO NO EXISTA EN LA TABLA USUARIO 
ELSEIF EXISTS (SELECT * FROM tbl_usuario u WHERE u.Contrasena=CONTRASENA) THEN
	SET @mensaje='Contrasena de usuario no permitida';
        SELECT @mensaje;


ELSE

-- EXTRAER EL CODIGO DEL ROL INGRESADO EN EL FORMULARIO 
    SET @VALOR1= (SELECT Cod_rol from tbl_rol r where r.Rol= ROL);
        SELECT @VALOR1;

IF COD_COLABORADOR != NULL THEN
    -- VALIDAR QUE EL COLABORADOR EXISTA EN LA TABLA COLABORADOR (BUSQUEDA POR CODIGO)
    IF NOT EXISTS (SELECT * FROM tbl_colaborador c WHERE c.Cod_colaborador= COD_COLABORADOR) THEN
        SET @mensaje='Cargo de colaborador no existente';
            SELECT @mensaje; 
    END IF;
END IF; 

-- EXTRAER EL CODIGO DE LA SEDE INGRESADA EN EL FORMULARIO 
    IF SEDE= NULL THEN
        SET @VALOR2=NULL;
            SELECT @VALOR2;
    ELSE
        SET @VALOR2= (SELECT Cod_sede from tbl_sede s WHERE s.Nombre_sede= SEDE);
            SELECT @VALOR2;       
    END IF;    

-- EXTRAER EL CODIGO DEL ESTATUS  EN EL FORMULARIO 
SET @VALOR3= (SELECT Cod_estatus from tbl_estatus e where e.Estatus= ESTATUS);
    SELECT @VALOR3;
    
-- DEFINIR FECHA DE VENCIMIENTO DE CONTRASEÑA (cambiar numero 5 por valor de la tabla parametro)
SET @VALOR4= date_add(NOW(), interval 5 day);
	SELECT @VALOR4;


 
-- HACER EL INSERT A LA TABLA CON LOS PARAMETROS Y INGRESADOS Y LAS VARIABLES DECLARADAS
    
    INSERT INTO tbl_usuario (`Cod_rol`, 
                            `Cod_colaborador`, 
                            `Cod_sede`, 
                            `Cod_estatus`, 
                            `Nombre_usuario`, 
                            `Contrasena`,
                            `Fecha_vencimiento`,
                            `Usuario_registro`,
                            `Fecha_registro`) 
                    VALUES  (@VALOR1, 
                            COD_COLABORADOR, 
                            @VALOR2, 
                            @VALOR3, 
                            NOMBRE, 
                            CONTRASENA,
                            @VALOR4,
                            USUARIO_REGISTRO,
                            NOW());
    
END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LOG_IN_OUT` (IN `USUARIO` VARCHAR(10), IN `ACCION` ENUM('IN','OUT'))  NO SQL
BEGIN
START TRANSACTION;

IF NOT EXISTS (SELECT * FROM tbl_usuario u WHERE u.Nombre_usuario = USUARIO) THEN
    SET @m='Registro de usuario no existente';
    	SELECT @m;
ELSE
    SET @COD= (SELECT Cod_usuario FROM tbl_usuario u WHERE u.Nombre_usuario = USUARIO);
    	SELECT @COD;

    IF (ACCION = 'IN') THEN
        INSERT INTO tbl_bitacora_sistema (Cod_usuario, 
                                    Hora_login, 
                                    Fecha_bitacora) 
                            VALUES  (@COD, NOW(), NOW());
        
    ELSEIF (ACCION = 'OUT') THEN
        UPDATE tbl_bitacora_sistema SET 
            Hora_logout = NOW()
        WHERE Cod_usuario=@COD AND Hora_login=Fecha_bitacora;
    END IF;
END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Sp_parametro_contrasena` (IN `USUARIO` BIGINT)  NO SQL
BEGIN
START TRANSACTION;
IF NOT EXISTS (SELECT * FROM tbl_usuario u WHERE u.Cod_usuario = USUARIO) THEN
SET @m='EL USUARIO QUE INGRESO NO EXISTE';
SELECT @m;
ELSE
UPDATE tbl_parametro p SET
p.Valor = p.Valor + 1
WHERE p.Cod_usuario = USUARIO;
END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_RESTABLECER_CONTRASEÑA_PREGUNTA` (IN `CONTRASENA` VARCHAR(60), IN `USUARIO` VARCHAR(10), IN `PREGUNTA_INGRESADA` VARCHAR(60), IN `RESPUESTA_INGRESADA` VARCHAR(50))  NO SQL
BEGIN
START TRANSACTION;

IF NOT EXISTS (SELECT * FROM VIEW_PREGUNTA_USUARIO v WHERE v.NOMBRE_USUARIO = USUARIO) THEN
    SET @m='Registro de usuario no existente';
        SELECT @m;
ELSE
        IF EXISTS (SELECT * FROM VIEW_PREGUNTA_USUARIO 
                                WHERE NOMBRE_USUARIO = USUARIO 
                                AND PREGUNTA = PREGUNTA_INGRESADA 
                                AND RESPUESTA = RESPUESTA_INGRESADA) THEN

            UPDATE tbl_usuario SET
                Contrasena = CONTRASENA,
                Usuario_modificacion =  USUARIO,
                Fecha_modificacion =  NOW()
            WHERE Nombre_usuario = USUARIO;

         ELSE
             SET @m='Restablecimiento de contraseña fallido, datos de seguridad invalidos';
            SELECT @m;   
        END IF;
END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEARCH_PERMISOS` (IN `ROL` VARCHAR(15))  NO SQL
BEGIN

START TRANSACTION;

-- validamos que el rol exista en la base de datos 
if not exists(select * from VIEW_PERMISOS p where p.Rol= ROL) then
    Set @mensaje = 'Registro de Rol no existente';
    SELECT @mensaje;

ELSE
    SET @VALOR1= (SELECT Cod_rol from tbl_rol r where r.Rol= ROL);
    SELECT @VALOR1;

-- extraer datos
    SELECT p.Cod_permiso, r.rol, o.Nombre_objeto ,p.Permiso_insertar, p.Permiso_eliminar, p.Permiso_actualizar, p.Permiso_consultar 
    FROM tbl_permisos AS p
    INNER JOIN tbl_rol AS r ON p.Cod_rol = r.Cod_rol
    INNER JOIN tbl_objetos AS o ON p.Cod_objeto = o.Cod_objeto
    WHERE p.Cod_rol=@VALOR1;
END IF;

COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEARCH_ROL` (IN `ROL` VARCHAR(15))  NO SQL
BEGIN

START TRANSACTION;

-- validamos que el rol exista en la base de datos 
if not exists(select * from VIEW_ROLES r where r.Rol= ROL) then
    Set @mensaje = 'Registro de Rol no existente';
    SELECT @mensaje;

ELSE
     
-- extraer datos
	SELECT r.Cod_rol, r.Rol, r.Descripcion, e.Estatus 
	FROM tbl_rol r
    INNER JOIN tbl_estatus e ON e.Cod_estatus=r.Cod_estatus
	WHERE r.Rol= ROL;
END IF;

COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPDATE_PERMISO` (IN `ROL` VARCHAR(50), IN `OBJETO` VARCHAR(50), IN `INSERTAR` VARCHAR(10), IN `ELIMINAR` VARCHAR(10), IN `ACTUALIZAR` VARCHAR(10), IN `CONSULTAR` VARCHAR(10))  NO SQL
BEGIN
    
START TRANSACTION;

SET @VALOR1= (SELECT Cod_rol from tbl_rol r where r.Rol= ROL);
    SELECT @VALOR1;
SET @VALOR2= (SELECT Cod_objeto from tbl_objetos o where o.Nombre_objeto= OBJETO);
    SELECT @VALOR2;

-- VALIDAR QUE EL ROL EXISTA
IF NOT EXISTS (SELECT * FROM tbl_permisos p WHERE p.Cod_rol= @VALOR1 AND p.Cod_objeto=@VALOR2 ) THEN
	SET @mensaje='Registro de permiso no existente';
    SELECT @mensaje;
ELSE

    UPDATE tbl_permisos SET 
        `Permiso_insertar`= INSERTAR, 
        `Permiso_eliminar`= ELIMINAR, 
        `Permiso_actualizar`= ACTUALIZAR,
        `Permiso_consultar`= CONSULTAR
    WHERE Cod_rol=@VALOR1;
 
END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPDATE_ROL` (IN `ROL` VARCHAR(15), IN `DESCRIPCION` VARCHAR(60), IN `ESTATUS` VARCHAR(15), IN `USUARIO_REGISTRO` VARCHAR(10))  NO SQL
BEGIN

START TRANSACTION;

-- validamos que el rol exista en la base de datos 
if not exists(select * from tbl_rol r where r.Rol= ROL) then
SET @mensaje = 'Registro de Rol no existente';
    SELECT @mensaje;

ELSE
-- extraer el codigo de estatus
SET @VALOR1= (SELECT Cod_estatus from tbl_estatus e where e.Estatus= ESTATUS);
    SELECT @VALOR1;
    
-- extraer el codigo de rol
SET @VALOR2= (SELECT Cod_rol from tbl_rol r where r.Rol= ROL);
    SELECT @VALOR2;

-- insertamos valores
    UPDATE tbl_rol SET	 
    	Cod_estatus= @VALOR1,
        Descripcion= DESCRIPCION,
        Usuario_modificacion= USUARIO_REGISTRO,
        Fecha_modificacion= NOW()
	WHERE Cod_rol= @VALOR2;
         
END IF;

COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPDATE_USUARIO` (IN `ROL` VARCHAR(15), IN `ESTATUS` VARCHAR(15), IN `NOMBRE` VARCHAR(10), IN `USUARIO_MODIFICACION` VARCHAR(10))  NO SQL
BEGIN
    
START TRANSACTION;   

-- VALIDAR QUE EL NOMBRE DE USUARIO NO EXISTA EN LA TABLA USUARIO 

SET @VALOR2= (SELECT Cod_usuario from tbl_usuario u where  u.Nombre_usuario=NOMBRE);
    SELECT @VALOR2;

IF EXISTS (SELECT * FROM tbl_usuario u WHERE u.Nombre_usuario=NOMBRE AND Cod_usuario!=@VALOR2) THEN
	SET @mensaje='Datos de nombre de usuario o correo electronico duplicados';
    SELECT @mensaje;

-- DEFINIMOS VARIABLES PARA EXTRAER LOS CODIGOS DE LOS CAMPOS ROL, SEDE, COLABORADOR Y ESTATUS
ELSE
-- EXTRAER EL CODIGO DEL ROL INGRESADO EN EL FORMULARIO 
    SET @VALOR1= (SELECT Cod_rol from tbl_rol r where r.Rol= ROL);
    SELECT @VALOR1;

-- EXTRAER EL CODIGO DEL ESTATUS  EN EL FORMULARIO 
SET @VALOR3= (SELECT Cod_estatus from tbl_estatus e where e.Estatus= ESTATUS);
    SELECT @VALOR3;
    
    
-- DEFINIR FECHA DE VENCIMIENTO DE CONTRASEÑA
/*SET @VALOR4= date_add(NOW(), interval 5 day);
	SELECT @VALOR4;*/
 
-- HACER EL INSERT A LA TABLA CON LOS PARAMETROS Y INGRESADOS Y LAS VARIABLES DECLARADAS
    
    UPDATE tbl_usuario SET 	
			`Cod_rol`= @VALOR1,  
            `Cod_estatus` =  @VALOR3, 
            `Nombre_usuario` = NOMBRE, 
            `Usuario_modificacion` =  USUARIO_MODIFICACION,
            `Fecha_modificacion`=  NOW()
			WHERE Nombre_usuario= NOMBRE;
    
END IF;
COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_asignacion_terapeuta`
--

CREATE TABLE `tbl_asignacion_terapeuta` (
  `Cod_asignacion` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla asignacion terapeuta',
  `Cod_colaborador` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA COLABORADOR',
  `Cod_tipo_especialidad` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA ESPECIALIDAD',
  `horas_asignadas` bigint(10) NOT NULL COMMENT 'HORAS PROGRAMADAS PARA LAS TERAPIAS',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL ULTIMO USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE REALIZO LA ULTIMA MODIFICACION'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_bitacora_sistema`
--

CREATE TABLE `tbl_bitacora_sistema` (
  `Cod_bitacora` bigint(10) NOT NULL COMMENT 'LLAVE PRIMARIA DE LA TABLA',
  `Cod_usuario` bigint(10) NOT NULL COMMENT 'CODIGO DEL USUARIO',
  `Tabla` varchar(30) DEFAULT NULL COMMENT 'TABLA EN LA QUE SE HIZO EL EVENTO',
  `Cod_registro` bigint(10) DEFAULT NULL COMMENT 'CODIGO DEL REGISTRO QUE SE ACTUALIZO INSERTO O ELIMINO',
  `Campo` varchar(30) DEFAULT NULL COMMENT 'CAMPOS DONDE SE HIZO EL CAMBIO, INSERCION O ELIMINACION',
  `Actividad` varchar(200) DEFAULT NULL COMMENT 'ACTIVIDAD QUE SE HIZO SOBRE LA TABLA',
  `Val_anterior` varchar(200) DEFAULT NULL COMMENT 'VALOR ANTERIOR DEL CAMPO',
  `Val_actual` varchar(200) DEFAULT NULL COMMENT 'VALOR NUEVO DEL CAMPO',
  `hora_login` datetime DEFAULT NULL COMMENT 'FECHA QUE EL USUARIO ENTRO AL SISTEMA',
  `hora_logout` datetime DEFAULT NULL COMMENT 'FECHA QUE EL USUARIO SALIO DEL SISTEMA',
  `Fecha_bitacora` datetime DEFAULT NULL COMMENT 'FECHA DE LA INSERSION ELIMINACION O ACTUALIZACION DE LA TABLA'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_colaborador`
--

CREATE TABLE `tbl_colaborador` (
  `Cod_colaborador` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla colaborador',
  `Cod_persona` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA PERSONA',
  `Cod_sede` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA SEDE',
  `Cod_departamento_laboral` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA DEPARTAMENTO LABORAL',
  `Cargo_principal` varchar(60) NOT NULL COMMENT 'NOMBRE DEL CARGO DEL COLABORADOR',
  `Descripcion_funciones` varchar(200) DEFAULT NULL COMMENT 'DESCRIPCION DE FUNCIONES DEL COLABORADOR ',
  `Fecha_contratacion` date NOT NULL COMMENT 'FECHA DE CONTRATACION DE COLABORADOR',
  `Fecha_despido` datetime DEFAULT NULL COMMENT 'FECHA DE DESPIDO DE COLABORADOR',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL ULTIMO USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE REALIZO LA ULTIMA MODIFICACION'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_correo`
--

CREATE TABLE `tbl_correo` (
  `Cod_correo` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA CORREO ELECTRONICO',
  `Cod_persona` bigint(10) DEFAULT NULL,
  `Cod_usuario` bigint(10) DEFAULT NULL,
  `Correo_Electronico` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_departamento`
--

CREATE TABLE `tbl_departamento` (
  `Cod_departamento` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA DEPARTAMENTOS',
  `Departamento` varchar(50) NOT NULL COMMENT 'NOMBRE DEL DEPARTAMENTO DONDE RESIDE UNA PERSONA O SEDE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_departamento`
--

INSERT INTO `tbl_departamento` (`Cod_departamento`, `Departamento`) VALUES
(1, 'ATLÁNTIDA'),
(2, 'COLÓN'),
(3, 'COMAYAGUA'),
(4, 'COPÁN'),
(5, 'CORTÉS'),
(6, 'CHOLUTECA'),
(7, 'EL PARAÍSO'),
(8, 'FRANCISCO MORAZÁN'),
(9, 'GRACIAS A DIOS'),
(10, 'INTIBÚCA'),
(11, 'ISLAS DE LA BAHÍA'),
(12, 'LA PAZ'),
(13, 'LEMPIRA'),
(14, 'OCOTEPEQUE'),
(15, 'OLANCHO'),
(16, 'SANTA BÁRBARA'),
(17, 'VALLE'),
(18, 'YORO'),
(19, 'ATLÁNTIDA'),
(20, 'COLÓN'),
(21, 'COMAYAGUA'),
(22, 'COPÁN'),
(23, 'CORTÉS'),
(24, 'CHOLUTECA'),
(25, 'EL PARAÍSO'),
(26, 'FRANCISCO MORAZÁN'),
(27, 'GRACIAS A DIOS'),
(28, 'INTIBÚCA'),
(29, 'ISLAS DE LA BAHÍA'),
(30, 'LA PAZ'),
(31, 'LEMPIRA'),
(32, 'OCOTEPEQUE'),
(33, 'OLANCHO'),
(34, 'SANTA BÁRBARA'),
(35, 'VALLE'),
(36, 'YORO'),
(37, 'ATLÁNTIDA'),
(38, 'COLÓN'),
(39, 'COMAYAGUA'),
(40, 'COPÁN'),
(41, 'CORTÉS'),
(42, 'CHOLUTECA'),
(43, 'EL PARAÍSO'),
(44, 'FRANCISCO MORAZÁN'),
(45, 'GRACIAS A DIOS'),
(46, 'INTIBÚCA'),
(47, 'ISLAS DE LA BAHÍA'),
(48, 'LA PAZ'),
(49, 'LEMPIRA'),
(50, 'OCOTEPEQUE'),
(51, 'OLANCHO'),
(52, 'SANTA BÁRBARA'),
(53, 'VALLE'),
(54, 'YORO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_departamento_laboral`
--

CREATE TABLE `tbl_departamento_laboral` (
  `Cod_departamento_laboral` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA DEPARTAMENTOS LABORALES',
  `Departamento_laboral` varchar(50) NOT NULL COMMENT 'ENUMERA LOS DEPARTAMENTOS LABORALES LA INSTITUCION'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_departamento_laboral`
--

INSERT INTO `tbl_departamento_laboral` (`Cod_departamento_laboral`, `Departamento_laboral`) VALUES
(1, 'ADMINISTRATIVO'),
(2, 'PSICOLOGÍA'),
(3, 'ACADÉMICO'),
(4, 'ADMINISTRATIVO'),
(5, 'PSICOLOGÍA'),
(6, 'ACADÉMICO'),
(7, 'ADMINISTRATIVO'),
(8, 'PSICOLOGÍA'),
(9, 'ACADÉMICO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_diagnostico_evaluacion`
--

CREATE TABLE `tbl_diagnostico_evaluacion` (
  `Cod_diagnostico` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla diagnostico evaluacion',
  `Cod_persona` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA PERSONA',
  `Diagnostico_general` varchar(250) NOT NULL COMMENT 'DIAGNOSTICO GENERAL DE LA EVALUACION',
  `Doc_informe_diagnostico` varchar(5) NOT NULL COMMENT 'ARCHIVO DIGITAL DEL DOCUMENTO DE EVALUACION DIAGNOSTICADA',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL ULTIMO USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE REALIZO LA ULTIMA MODIFICACION'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_estado_civil`
--

CREATE TABLE `tbl_estado_civil` (
  `Cod_estado_civil` bigint(10) NOT NULL COMMENT 'AUTO INCRMENTO DE LLAVE PRIMARIA TABLA ESTADO CIVIL',
  `Estado_civil` varchar(20) NOT NULL COMMENT 'ENUMERA LOS ESTADOS CIVILES DE UNA PERSONA'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_estado_civil`
--

INSERT INTO `tbl_estado_civil` (`Cod_estado_civil`, `Estado_civil`) VALUES
(1, 'SOLTERO (A)'),
(2, 'CASADO (A)'),
(3, 'VIUDO (A)'),
(4, 'UNIÓN LIBRE'),
(5, 'DIVORCIADO (A)'),
(6, 'SOLTERO (A)'),
(7, 'CASADO (A)'),
(8, 'VIUDO (A)'),
(9, 'UNIÓN LIBRE'),
(10, 'DIVORCIADO (A)'),
(11, 'SOLTERO (A)'),
(12, 'CASADO (A)'),
(13, 'VIUDO (A)'),
(14, 'UNIÓN LIBRE'),
(15, 'DIVORCIADO (A)');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_estado_nutricional`
--

CREATE TABLE `tbl_estado_nutricional` (
  `Cod_estado_nutricional` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA ESTADO NUTRICIONAL',
  `Estado_nutricional` varchar(50) NOT NULL COMMENT 'ENUMERA EL ESTADO NUTRICIONAL QUE PRESENTA DE UNA PERSONA'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_estado_nutricional`
--

INSERT INTO `tbl_estado_nutricional` (`Cod_estado_nutricional`, `Estado_nutricional`) VALUES
(1, 'SOBRE PESO'),
(2, 'OBESIDAD'),
(3, 'DELGADEZ'),
(4, 'DESNUTRICIÓN'),
(5, 'SOBRE PESO'),
(6, 'OBESIDAD'),
(7, 'DELGADEZ'),
(8, 'DESNUTRICIÓN'),
(9, 'SOBRE PESO'),
(10, 'OBESIDAD'),
(11, 'DELGADEZ'),
(12, 'DESNUTRICIÓN');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_estatus`
--

CREATE TABLE `tbl_estatus` (
  `Cod_estatus` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA ESTATUS',
  `Estatus` varchar(20) NOT NULL COMMENT 'DESCRIBE LOS ESTATUS DE UN USUARIO, PERSONA, SEDE O EVALUACIÒN'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_estatus`
--

INSERT INTO `tbl_estatus` (`Cod_estatus`, `Estatus`) VALUES
(1, 'ACTIVO'),
(2, 'INACTIVO'),
(3, 'HABILITADO'),
(4, 'DESHABILITADO'),
(5, 'BLOQUEADO'),
(6, 'ACTIVO'),
(7, 'INACTIVO'),
(8, 'HABILITADO'),
(9, 'DESHABILITADO'),
(10, 'BLOQUEADO'),
(11, 'ACTIVO'),
(12, 'INACTIVO'),
(13, 'HABILITADO'),
(14, 'DESHABILITADO'),
(15, 'BLOQUEADO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_familiar_encargado`
--

CREATE TABLE `tbl_familiar_encargado` (
  `Cod_familiar` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA FAMILIAR ENCARGADO',
  `Cod_persona` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA PERSONA',
  `Cod_parentesco` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA PARENTESCO',
  `Cod_nivel_academico` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA NIVEL ACADEMICO',
  `Ocupacion_actual` varchar(50) NOT NULL COMMENT 'OCUPACION ACTUAL DEL FAMILAR ENCARGADO',
  `Labor_actual` varchar(50) NOT NULL COMMENT 'ENFERMDADES CRONICAS',
  `Enfermedades_cronicas` varchar(2) NOT NULL COMMENT 'ENFERMDADES CRONICAS',
  `Descripcion_enfermedades_cronicas` varchar(200) DEFAULT NULL COMMENT 'DESCRIPCION DE ENFERMEDADES CRONICAS',
  `Ingreso_promedio_personal` decimal(6,0) NOT NULL COMMENT 'EL INGRESO PROMEDIO PERSONAL',
  `Miembros_familia` varchar(10) NOT NULL COMMENT 'MIEMBROS DE LA FAMILIA',
  `Ingreso_promedio_familiar` decimal(6,0) NOT NULL COMMENT 'INGRESO PROMEDIO FAMILAR',
  `Monto_ingreso` decimal(6,0) DEFAULT NULL COMMENT 'MONTO DEL INGRESO',
  `Ingreso_semanal` decimal(6,0) DEFAULT NULL COMMENT 'INGRESO SEMANAL FAMILAR',
  `Ingreso_mensual` decimal(6,0) DEFAULT NULL COMMENT 'INGRESO MENSUAL FAMILAR'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_ficha_general`
--

CREATE TABLE `tbl_ficha_general` (
  `Cod_ficha_general` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla ficha general',
  `Cod_persona` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA PERSONA',
  `Carnet_discapacidad` varchar(2) NOT NULL COMMENT 'INDICA SI EL BENEFICIARIO TIENE CARNET DE DISCAPACIDAD',
  `Documento_carnet_discapacidad` text NOT NULL COMMENT 'ARCHIVO DIGITAL DE CARNET DE DISCAPACIDAD',
  `Acceso_computadora` varchar(2) NOT NULL COMMENT 'EL BENEFICIARIO CUENTA CON ACCESO A UNA COMPUTADORA O TABLET',
  `Acceso_internet` varchar(2) NOT NULL COMMENT 'EL BENEFICIARIO CUENTA CON ACCESO A INTERNET',
  `Bono_discapacidad` varchar(2) NOT NULL COMMENT 'EL BENEFICIARIO CUENTA CON EL BENEFICIO DE BONO DE DISCAPACIDAD',
  `Instituto_procedencia` varchar(20) DEFAULT NULL COMMENT 'INDICA EL INSTITUTO DEL QUE VIENE EL BENEFICIARIO',
  `Permanencia_institucion` varchar(20) DEFAULT NULL COMMENT 'LOS AÑOS DE PERMANENCIA DEL BENEFICIARIO EN EL INSTITUTO DE PROCEDENCIA',
  `Nivel_academico` varchar(20) DEFAULT NULL COMMENT 'NIVEL ACADEMICO OBTENIDO POR EL BENEFICIARIO',
  `Telefono_instituto` int(15) DEFAULT NULL COMMENT 'NUMERO DE TELEFONO FIJO O CELULAR DEL INSTITUTO DE PROCEDENCIA',
  `Correo_instituto` varchar(50) DEFAULT NULL COMMENT 'CORREO ELECTRONICO DEL INSTITUTO DE PROCEDENCIA DEL BENEFICIARIO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_ficha_inclusion`
--

CREATE TABLE `tbl_ficha_inclusion` (
  `Cod_ficha_inclusion` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA FICHA INCLUSION',
  `Cod_persona` bigint(10) NOT NULL COMMENT 'LLAVE FORNAEA DE LA TABLA PERSONA',
  `Cod_tipo_inclusion` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA INCLUSION',
  `Cod_tipo_institucion` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA TIPO INSTITUCION',
  `Nombre_institucion_empresa` varchar(30) NOT NULL COMMENT 'NOMBRE  DE LA INTISTUCION O EMPRESA',
  `Direccion_institucion` varchar(50) NOT NULL COMMENT 'DIRECCION DE LA INSTUTCION',
  `Telefono_institucion` int(15) NOT NULL COMMENT 'TELEFONO DE LA INSTITUCION',
  `Correo_electronico_institucion` varchar(30) DEFAULT NULL COMMENT 'CORREO DE LA INSTITUCION',
  `Fecha_ingreso` datetime NOT NULL COMMENT 'FECHA INGRESO',
  `Grado_academico` varchar(20) DEFAULT NULL COMMENT 'EL GRADO ACADEMICO',
  `Tiempo_seguimiento_inclusivo` varchar(20) DEFAULT NULL COMMENT 'TIEMPO DE SEGUIMIENTO INCLUSIVO',
  `Cargo_desempeñar` varchar(30) DEFAULT NULL COMMENT 'CARGO A DESEMPEÑAR',
  `Fecha_matricula` datetime DEFAULT NULL COMMENT 'FECHA DE LA MATRICULA',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE MODIFICO EL REGISTRO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_ficha_institucional`
--

CREATE TABLE `tbl_ficha_institucional` (
  `Cod_ficha_institucional` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla ficha institucional',
  `Cod_persona` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA PERSONA',
  `Cod_modalidad_atencion` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA MODALIDAD ATENCION',
  `Cod_modalidad_servicio` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA MODALIDAD SERVICIO',
  `Fecha_ingreso` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE INGRESO A APO-AUTIS',
  `Evaluacion_diagnostica_interna` varchar(2) NOT NULL COMMENT 'INDICA SI CUENTA CON UNA EVALUACION DIAGNOSTICA POR APO-AUTIS',
  `Fecha_evaluacion_interna` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE REALIZO LA EVALUACION EN APO-AUTIS',
  `Evaluacion_diagnostica_externa` varchar(2) DEFAULT NULL COMMENT 'INDICA SI CUENTA CON UNA EVALUACION DIAGNOSTICA POR OTRA INSTITUCION',
  `Fecha_evaluacion_externa` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE REALIZO LA EVALUACION EN APO-AUTIS',
  `Doc_evaluacion_externa` varchar(5) DEFAULT NULL COMMENT 'ARCHIVO DIGITAL DEL DOCUMENTO DE EVALUACION',
  `Edad_evaluacion` varchar(20) DEFAULT NULL COMMENT 'INDICA EL TIEMPO DEL DIAGNOSTICO OBTENIDO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_ficha_salud`
--

CREATE TABLE `tbl_ficha_salud` (
  `Cod_ficha_salud` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla ficha general',
  `Cod_persona` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA PERSONA',
  `Cod_estado_nutricional` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA ESTADO NUTRICIONAL',
  `Agudeza_visual` varchar(2) NOT NULL COMMENT 'INDICA LA AGUDEZA VISUAL DEL BENEFICIARIO',
  `Agudeza_auditiva` varchar(2) NOT NULL COMMENT 'INDICA LA AGUDEZA AUDITIVA DEL BENEFICIARIO',
  `Condicion_oral_deficiente` varchar(2) NOT NULL COMMENT 'INDICA LA CONDICION ORAL DEFICIENTE O NO DEL BENEFICIARIO',
  `Esquema_vacunacion` varchar(2) NOT NULL COMMENT 'INDICA EL ESQUEMA DE VACUNACION DEL BENEFICIARIO',
  `Anemia` varchar(2) DEFAULT NULL COMMENT 'INDICA SI EL BENEFICIARIO PRESENTA SIGNOS DE ANEMIA',
  `Alergia` varchar(2) DEFAULT NULL COMMENT 'INDICA SI EL BENEFICIARIO CUENTA CON ALERGIAS',
  `Descripcion_alergias` varchar(250) DEFAULT NULL COMMENT 'DESCRIPCION DE LA CONDICION ALERGICA DEL BENEFICIARIO',
  `Enfermedad_cronica` varchar(2) DEFAULT NULL COMMENT 'INDICA SI EL BENEFICIARIO PRESENTA ENFERMEDADES CRONICAS',
  `Descripcion_enf_cronica` varchar(250) DEFAULT NULL COMMENT 'DESCRIPCION DE ENFERMEDADES CRONICAS DEL BENEFICIARIO',
  `Seguimiento_medico` varchar(250) DEFAULT NULL COMMENT 'DESCRIBE EL SEGUIMIENTO MEDICO QUE TIENE EL BENEFICIARIO',
  `Medicacion` varchar(2) DEFAULT NULL COMMENT 'INDICA SI EL BENEFICIARIO CUENTA CON MEDICACION',
  `Nombre_medicamento` varchar(250) DEFAULT NULL COMMENT 'NOMBRE DE LOS MEDICAMENTOS QUE INGIERE EL BENEFICIARIO',
  `Dosis` varchar(250) DEFAULT NULL COMMENT 'DOSIS DE LOS MEDICAMENTOS QUE INGIERE EL BENEFICIARIO',
  `Tiempo_ingesta_medicacion` varchar(250) DEFAULT NULL COMMENT 'INDICA EL TIEMPO PARA INGERIR LA MEDICACION',
  `Seguimiento_terapia_alternativa` varchar(250) DEFAULT NULL COMMENT 'SEGUIMIENTOS MEDICOS A LOS QUE ASISTE EL BENEFICIARIO',
  `Tipo_terapia_alternativa` varchar(250) DEFAULT NULL COMMENT 'TERAPIAS ALTERNATIVAS QUE RECIBE EL BENEFICIARIO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_genero`
--

CREATE TABLE `tbl_genero` (
  `Cod_genero` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA GENEROS',
  `Genero` varchar(10) NOT NULL COMMENT 'ENUMERA LOS GENEROS DIPONIBLES PARA LA PERSONA'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_genero`
--

INSERT INTO `tbl_genero` (`Cod_genero`, `Genero`) VALUES
(1, 'FEMENINO'),
(2, 'MASCULINO'),
(3, 'FEMENINO'),
(4, 'MASCULINO'),
(5, 'FEMENINO'),
(6, 'MASCULINO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_historial_contrasena`
--

CREATE TABLE `tbl_historial_contrasena` (
  `Cod_historial` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA HISTORIAL CONTRASEÑAS',
  `Cod_usuario` bigint(10) NOT NULL COMMENT 'INDICA EL USUARIO PROPIETARIO DE LA CONTRASEÑA',
  `Contrasena` varchar(100) NOT NULL COMMENT 'CONTRASEÑA RESTABLECIDA POR O PARA EL USUARIO REGISTRADO',
  `Fecha_cambio` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZÓ EL REGISTRO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_informe_academico`
--

CREATE TABLE `tbl_informe_academico` (
  `Cod_informe_academico` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA INFORME ACADEMICO',
  `Cod_matricula` bigint(10) NOT NULL COMMENT 'INDICA EL CÓDIGO DE LA MATRICULA',
  `Cod_persona` bigint(10) NOT NULL COMMENT 'INDICA LOS DATOS PERSONALES DEL BENEFICIARIO',
  `Doc_informe_academico` text DEFAULT NULL COMMENT 'ARCHIVO DIGITAL DE INFORME ACADEMICO POR TERAPEUTA DE APO AUTIS',
  `Doc_planificacion_terapia` text DEFAULT NULL COMMENT 'ARCHIVO DIGITAL DE INFORME PLANIFICACION TERAPIA POR TERAPEUTA DE APO AUTIS',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE MODIFICO EL REGISTRO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_matricula`
--

CREATE TABLE `tbl_matricula` (
  `Cod_matricula` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA MATRICULAS',
  `Cod_asignacion` bigint(10) NOT NULL COMMENT 'INDICA EL CODIGO DE ASIGNACION DE TERAPEUTA PARA CADA MATRICULA',
  `Cod_persona` bigint(10) NOT NULL COMMENT 'INDICA LOS DATOS PERSONALES DEL BENEFICIARIO',
  `Cod_ficha_inclusion` bigint(10) DEFAULT NULL COMMENT 'INDICA EL CODIGO DE MATRICULA DE UNA INCLUSION, OPCIONAL',
  `Horas_asignadas_beneficiario` bigint(10) DEFAULT NULL COMMENT 'HORAS DE TERAPIA ASIGNADAS AL BENEFICIARIO',
  `Observacion_terapia` varchar(300) DEFAULT NULL COMMENT 'COMENTARIO O DESCRIPCION SOBRE LA TERRAPIA',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE MODIFICO EL REGISTRO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_modalidad_atencion`
--

CREATE TABLE `tbl_modalidad_atencion` (
  `Cod_modalidad_atencion` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA MODALIDAD DE ATENCIÓN',
  `Modalidad_atencion` varchar(10) NOT NULL COMMENT 'ENUMERA LAS MODALIDADES DE ATENCION DISPONIBLESQUE OFRECE LA INSTITUCION'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_modalidad_atencion`
--

INSERT INTO `tbl_modalidad_atencion` (`Cod_modalidad_atencion`, `Modalidad_atencion`) VALUES
(1, 'GRUPAL'),
(2, 'INDIVIDUAL'),
(3, 'A DISTANCI'),
(4, 'OTRO'),
(5, 'GRUPAL'),
(6, 'INDIVIDUAL'),
(7, 'A DISTANCI'),
(8, 'OTRO'),
(9, 'GRUPAL'),
(10, 'INDIVIDUAL'),
(11, 'A DISTANCI'),
(12, 'OTRO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_modalidad_servicio`
--

CREATE TABLE `tbl_modalidad_servicio` (
  `Cod_modalidad_servicio` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA MODALIDAD DE SERVICIO',
  `Modalidad_servicio` varchar(20) NOT NULL COMMENT 'ENUMERA LAS MODALIDADES DE SERVICIO DISPONIBLESQUE OFRECE LA INSTITUCION'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_modalidad_servicio`
--

INSERT INTO `tbl_modalidad_servicio` (`Cod_modalidad_servicio`, `Modalidad_servicio`) VALUES
(1, 'PRE VOCACIONAL'),
(2, 'VOCACIONAL'),
(3, 'A DOMICILIO'),
(4, 'INCLUSIÓN ESCOLAR'),
(5, 'EDUCACIÓN FÍSICA'),
(6, 'PRE VOCACIONAL'),
(7, 'VOCACIONAL'),
(8, 'A DOMICILIO'),
(9, 'INCLUSIÓN ESCOLAR'),
(10, 'EDUCACIÓN FÍSICA'),
(11, 'PRE VOCACIONAL'),
(12, 'VOCACIONAL'),
(13, 'A DOMICILIO'),
(14, 'INCLUSIÓN ESCOLAR'),
(15, 'EDUCACIÓN FÍSICA');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_ms_bitacora`
--

CREATE TABLE `tbl_ms_bitacora` (
  `Cod_bitacora` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA BITACORA',
  `Fecha` datetime NOT NULL COMMENT 'FECHA DEL EVENTO',
  `Cod_usuario` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA USUARIO',
  `Cod_objeto` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA OBJETO, MUESTRA LA PANTALLA DONE SE NAVEGO',
  `Accion` varchar(30) NOT NULL COMMENT 'TIPO DE ACCION DEL EVENTO',
  `Descripcion` varchar(200) DEFAULT NULL COMMENT 'INFORMACION DETALLADA DEL REGISTRO O ACTIVIDAD QUE SE DIO EL EVENTO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_nacionalidad`
--

CREATE TABLE `tbl_nacionalidad` (
  `Cod_nacionalidad` varchar(5) NOT NULL COMMENT 'LLAVE PRIMARIA TABLA NACIONALIDADES',
  `Nacionalidad` varchar(35) NOT NULL COMMENT 'ENUMERA LA NACIONALIDAD DE LAS PERSONAS'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_nacionalidad`
--

INSERT INTO `tbl_nacionalidad` (`Cod_nacionalidad`, `Nacionalidad`) VALUES
('CR', 'COSTA RICA'),
('GT', 'GUATEMALA'),
('HN', 'HONDURAS');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_nivel_academico`
--

CREATE TABLE `tbl_nivel_academico` (
  `Cod_nivel_academico` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA NIVEL ACADEMICO',
  `Nivel_academico` varchar(25) NOT NULL COMMENT 'ENUMERA LOS NIVELES ACADEMICOS DE UNA PERSONA'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_nivel_academico`
--

INSERT INTO `tbl_nivel_academico` (`Cod_nivel_academico`, `Nivel_academico`) VALUES
(1, 'PRIMARIA COMPLETA'),
(2, 'PRIMARIA INCOMPLETA'),
(3, 'SECUNDARIA COMPLETA'),
(4, 'SECUNDARIA INCOMPLETA'),
(5, 'UNIVERSIDAD COMPLETA'),
(6, 'UNIVERSIDAD INCOMPLETA');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_objetos`
--

CREATE TABLE `tbl_objetos` (
  `Cod_objeto` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA OBJETOS',
  `Nombre_objeto` varchar(50) NOT NULL COMMENT 'NOMBRE DEL OBJETO O MODULO',
  `Descripcion_objeto` varchar(200) NOT NULL COMMENT 'DESCRIPCIÓN DEL OBJETO O MODULO',
  `Tipo_objeto` varchar(50) NOT NULL COMMENT 'TIPO DE OBJETO O MODULO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_objetos`
--

INSERT INTO `tbl_objetos` (`Cod_objeto`, `Nombre_objeto`, `Descripcion_objeto`, `Tipo_objeto`) VALUES
(1, 'PANTALLA DE LOGIN', 'Ingresar al sistema y Salir del sistema', 'Acceso al sistema'),
(2, 'PANTALLA DE REGISTRO USUARIO', 'Ingresar un nuevo usuario y modificar sus datos', 'Registro del sistema');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_parametro`
--

CREATE TABLE `tbl_parametro` (
  `Cod_parametro` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA PARAMETRO',
  `Cod_usuario` bigint(10) NOT NULL COMMENT 'CODIGO DEL USUARIO QUE REALIZO EL REGISTRO',
  `Parametro` varchar(30) NOT NULL COMMENT 'NOMBRE DEL PARAMETRO',
  `Valor` varchar(200) DEFAULT NULL COMMENT 'NUEVO VALOR QUE LE ASIGNAMOS AL PARAMETRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE MODIFICO EL REGISTRO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_parentesco`
--

CREATE TABLE `tbl_parentesco` (
  `Cod_parentesco` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA PARENTESCO',
  `Parentesco` varchar(30) NOT NULL COMMENT 'ENUMERA LOS PARENTESCO ACEPTADOS DE UNA PERSONA'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_parentesco`
--

INSERT INTO `tbl_parentesco` (`Cod_parentesco`, `Parentesco`) VALUES
(1, 'MADRE'),
(2, 'PADRE'),
(3, 'MADRE RESPONSABLE'),
(4, 'PADRE RESPONSABLE'),
(5, 'RESPONSABLE');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_permisos`
--

CREATE TABLE `tbl_permisos` (
  `Cod_permiso` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla permisos',
  `Cod_rol` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA ROLES',
  `Cod_objeto` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA OBJETOS',
  `Permiso_insertar` varbinary(2) NOT NULL COMMENT 'PERMISO PARA INSERTAR REGISTROS',
  `Permiso_eliminar` varbinary(2) NOT NULL COMMENT 'PERMISO PARA ELIMINAR REGISTROS',
  `Permiso_actualizar` varbinary(2) NOT NULL COMMENT 'PERMISO PARA ACTUALIZAR REGISTROS',
  `Permiso_consultar` varbinary(2) NOT NULL COMMENT 'PERMISO PARA VER  REGISTROS'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_persona`
--

CREATE TABLE `tbl_persona` (
  `Cod_persona` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla persona',
  `Cod_tipo_persona` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA TIPO DE PERSONA ',
  `Cod_genero` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA GENERO',
  `Cod_nacionalidad` varchar(5) DEFAULT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA NACIONALIDAD',
  `Cod_estado_civil` bigint(10) DEFAULT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA ESTADO CIVIL',
  `Cod_departamento` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA DEPARTAMENTO',
  `Cod_estatus` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA  ESTATUS',
  `Nombre` varchar(30) NOT NULL COMMENT 'NOMBRE DE LA PERSONA',
  `Apellido` varchar(30) NOT NULL COMMENT 'APELLIDO DE LA PERSONA',
  `No_identidad` varchar(25) NOT NULL COMMENT 'NUMERO DE IDENTIDAD DE LA PERSONA O PASAPORTE',
  `Documento_id` text DEFAULT NULL COMMENT 'DOCUMENTO DE PARTIDA DE NACIMIENTO, IDENTIDAD O PASAPORTE DE LA PERSONA',
  `Lugar_nacimiento` varchar(60) NOT NULL COMMENT 'LUGAR DE NACIMIENTO DE LA PERSONA',
  `Fecha_nacimiento` date NOT NULL COMMENT 'FECHA DE NACIMIENTO DE LA PERSONA',
  `Residencia_actual` varchar(60) NOT NULL COMMENT 'DIRECCION DE LA PERSONA ',
  `Telefono_fijo` int(15) DEFAULT NULL COMMENT 'TELEFONO FIJO DE LA PERSONA ',
  `Telefono_celular` int(15) NOT NULL COMMENT 'TELEFONO CELULAR DE LA PERSONA ',
  `Fotografia` text DEFAULT NULL COMMENT 'FOTOGRAFIA DE LA PERSONA ',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL ULTIMO USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE REALIZO LA ULTIMA MODIFICACION'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_preguntas`
--

CREATE TABLE `tbl_preguntas` (
  `Cod_pregunta` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA PREGUNTAS PARA EL USUARIO',
  `Pregunta` varchar(60) NOT NULL COMMENT 'PREGUNTA DE SEGURIDAD DISPONIBLE PARA LOS USUARIOS'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_preguntas`
--

INSERT INTO `tbl_preguntas` (`Cod_pregunta`, `Pregunta`) VALUES
(1, 'Color favorito'),
(2, 'Personaje animado favorito'),
(3, 'Animal favorito'),
(4, 'Nombre de su maestra de primaria más querida');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_pregunta_usuario`
--

CREATE TABLE `tbl_pregunta_usuario` (
  `Cod_pregunta_usuario` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla pregunta_usuario',
  `Cod_usuario` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA  USUARIO',
  `Cod_pregunta` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA  PREGUNTAS',
  `Respuesta` varchar(50) NOT NULL COMMENT 'RESPUESTA DE  SEGURIDAD DEL USUARIO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_pregunta_usuario`
--

INSERT INTO `tbl_pregunta_usuario` (`Cod_pregunta_usuario`, `Cod_usuario`, `Cod_pregunta`, `Respuesta`) VALUES
(1, 2, 1, 'NEGRO'),
(3, 2, 4, 'JASMINA'),
(4, 2, 2, 'Mabel Pines'),
(5, 3, 2, 'Bob Esponja');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_registro_servicio_social`
--

CREATE TABLE `tbl_registro_servicio_social` (
  `Cod_registro_servicio_social` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla registro servicio social',
  `Cod_colaborador` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA COLABORADOR',
  `Cod_servicio_social` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA SERVICIO SOCIAL',
  `Documento_listado_participante` text NOT NULL COMMENT 'LISTADO DE PARTICIPANTES DE LAS ACTIVIDADES SERVICIO SOCIAL',
  `Fecha_realizacion` datetime DEFAULT NULL COMMENT 'FECHA QUE SE RELIZO LA ACTIVIDAD',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL ULTIMO USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE REALIZO LA ULTIMA MODIFICACION'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_rol`
--

CREATE TABLE `tbl_rol` (
  `Cod_rol` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA ROLES',
  `Rol` varchar(15) NOT NULL COMMENT 'NOMBRE DEL ROL',
  `Cod_estatus` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA  ESTATUS',
  `Descripcion` varchar(60) NOT NULL COMMENT 'DESCRIPCION DEL ROL',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE MODIFICO EL REGISTRO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_rol`
--

INSERT INTO `tbl_rol` (`Cod_rol`, `Rol`, `Cod_estatus`, `Descripcion`, `Usuario_registro`, `Fecha_registro`, `Usuario_modificacion`, `Fecha_modificacion`) VALUES
(1, 'ADMINISTRADOR', 1, 'GESTIONA LOS USUARIOS, PERMSOS Y OBJETOS DE LA BASE DE DATOS', 'ADMIN', '2022-02-24 00:41:36', NULL, NULL),
(2, 'SECRETARIAL', 1, 'GESTIONA EL INGRESO Y MODIFICACIÓN DE DATOS DE LAS PERSONAS', 'ADMIN', '2022-02-24 00:41:37', 'ADMIN', '2022-02-24 00:43:14'),
(3, 'INVITADO', 1, 'ROL PARA USUARIOS AUTO REGISTRADOS', 'ADMIN', '2022-02-24 01:45:27', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_sede`
--

CREATE TABLE `tbl_sede` (
  `Cod_sede` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla sede',
  `Cod_departamento` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA DEPARTAMENTO',
  `Cod_estatus` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA  ESTATUS',
  `Nombre_sede` varchar(30) NOT NULL COMMENT 'NOMBRE DE SEDE AUTORIZADO POR LA INSTUTICION',
  `Direccion_sede` varchar(60) NOT NULL COMMENT 'DIRECCION DE LA SEDE ',
  `Telefono_sede` int(15) NOT NULL COMMENT 'TELEFONO DE LA SEDE ',
  `Correo_electronico_sede` varchar(60) NOT NULL COMMENT 'CORREO ELECTRONICO  DE LA SEDE ',
  `Redes_sociales` varchar(60) DEFAULT NULL COMMENT 'REDES SOCIALES DE LA SEDE ',
  `Administrador_general` varchar(50) DEFAULT NULL COMMENT 'NOMBRE DEL ADMINISTRADOR DE LA SEDE ',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL ULTIMO USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE REALIZO LA ULTIMA MODIFICACION'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_sede`
--

INSERT INTO `tbl_sede` (`Cod_sede`, `Cod_departamento`, `Cod_estatus`, `Nombre_sede`, `Direccion_sede`, `Telefono_sede`, `Correo_electronico_sede`, `Redes_sociales`, `Administrador_general`, `Usuario_registro`, `Fecha_registro`, `Usuario_modificacion`, `Fecha_modificacion`) VALUES
(1, 8, 1, 'APO-AUTIS TEGUCIGALPA', 'COLONIA ALAMEDA, 11VA Y 12VA CALLE, CONTIGUO A CENTRO COERCI', 2147483647, 'apoautis1997@yahoo.com', NULL, 'LIC. DORIS ARCHAGA', 'ADMIN', '0000-00-00 00:00:00', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_servicio_social`
--

CREATE TABLE `tbl_servicio_social` (
  `Cod_servicio_social` bigint(10) NOT NULL COMMENT 'llave primaria de la tabla servicio social',
  `Cod_estatus` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA  DE LA TABLA  ESTATUS',
  `Nombre_servicio_social` varchar(25) NOT NULL COMMENT 'NOMBRE DEL REGISTRO SOCIAL',
  `Descripcion_servicio_social` text DEFAULT NULL COMMENT 'DESCRIPCION DEL SERVICIO SOCIAL ',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL ULTIMO USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE REALIZO LA ULTIMA MODIFICACION'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_solicitud_evaluacion`
--

CREATE TABLE `tbl_solicitud_evaluacion` (
  `Cod_solicitud_evaluacion` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA SOLICITUD EVALUACION',
  `Cod_departamento` bigint(10) NOT NULL COMMENT 'LLAVE FORNAEA DE LA TABLA DEPARTAMENTO',
  `Cod_sede` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA SEDE',
  `Cod_tipo_evaluacion` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA TIPO EVALUACION',
  `Cod_parentesco` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA PARENTESCO',
  `Cod_estatus` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA ESTATUS',
  `Nombre_beneficiario` varchar(30) NOT NULL COMMENT 'NOMBRE DEL BENEFICIARIO DE LA INTISTUCION',
  `Edad_beneficiario` varchar(20) NOT NULL COMMENT 'EDAD DEL BENEFICIARIO',
  `Direccion_actual` varchar(50) NOT NULL COMMENT 'DIRECCION ACTUAL DEL BENEFICIARIO',
  `Nombre_responsable` varchar(70) NOT NULL COMMENT 'NOMBRE DEL RESPONSABLE DEL BENEFICIARIO',
  `Telefono_fijo` int(15) NOT NULL COMMENT 'TELEFNO FIJO DEL BENEFICIARIO',
  `Telefono_celular` int(15) NOT NULL COMMENT 'TELEFONO MOVIL DEL BENEFICIARIO',
  `Correo_electronico` varchar(30) NOT NULL COMMENT 'CORREO ELECTRONICO DEL BENEFICIARIO',
  `Fecha_solicitud` datetime NOT NULL COMMENT 'MONTO DEL INGRESO',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE MODIFICO EL REGISTRO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_tipo_especialidad`
--

CREATE TABLE `tbl_tipo_especialidad` (
  `Cod_tipo_especialidad` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA TIPOS DE ESPECILIDAD',
  `Tipo_especialidad` varchar(20) NOT NULL COMMENT 'NOMBRE DEL TIPO ESPECIALIDAD QUE OFRECE LA INSTITUCION',
  `Descripcion_especialidad` varchar(60) NOT NULL COMMENT 'DESCRIPCIÓN DE LOS TIPOS DE ESPECIALIDAD QUE OFRECE LA INSTITUCION',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE MODIFICO EL REGISTRO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_tipo_evaluacion`
--

CREATE TABLE `tbl_tipo_evaluacion` (
  `Cod_tipo_evaluacion` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIAICE TABLA TIPO DE EVALUACIONES',
  `Tipo_evaluacion` varchar(30) NOT NULL COMMENT 'ENUMERA TIPOS DE EVALUCION DISPONIBLES QUE OFRECE LA INSTITUCION'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_tipo_inclusion`
--

CREATE TABLE `tbl_tipo_inclusion` (
  `Cod_tipo_inclusion` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA TIPO DE INCLUSIONES',
  `Tipo_inclusion` varchar(30) NOT NULL COMMENT 'ENUMERA LOS TIPOS DE INCLUSION ACEPTADOS'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_tipo_institucion`
--

CREATE TABLE `tbl_tipo_institucion` (
  `Cod_tipo_institucion` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA TIPO DE INSTITUCIÓN',
  `Tipo_institucion` varchar(30) NOT NULL COMMENT 'ENUMERA LOS TIPOS DE INSTITUCION ACEPTADOS'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_tipo_persona`
--

CREATE TABLE `tbl_tipo_persona` (
  `Cod_tipo_persona` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA TIPO DE PERSONA',
  `Tipo_persona` varchar(30) NOT NULL COMMENT 'ENUMERA LOS TIPOS DE PERSONAS ACEPTADAS'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_tipo_persona`
--

INSERT INTO `tbl_tipo_persona` (`Cod_tipo_persona`, `Tipo_persona`) VALUES
(1, 'COLABORADOR'),
(2, 'BENEFICIARIO'),
(3, 'MIEMBRO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_usuario`
--

CREATE TABLE `tbl_usuario` (
  `Cod_usuario` bigint(10) NOT NULL COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA USUARIOS',
  `Cod_rol` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA ROL',
  `Cod_colaborador` bigint(10) DEFAULT NULL COMMENT 'LLAVE FORANEA DE LA TABLA COLABORADOR',
  `Cod_sede` bigint(10) DEFAULT NULL COMMENT 'LLAVE FORANEA DE LA TABLA SEDE',
  `Cod_estatus` bigint(10) NOT NULL COMMENT 'LLAVE FORANEA DE LA TABLA ESTATUS',
  `Nombre_usuario` varchar(20) NOT NULL COMMENT 'NOMBRE DEL USUARIO A REGISTRARSE',
  `Contrasena` varbinary(260) NOT NULL COMMENT ' CONTRASEÑA DEL USUARIO A REGISTRARSE',
  `Fecha_vencimiento` datetime NOT NULL COMMENT 'FECHA DE VENCIMIENTO DE LA CONTRASEÑA DEL USUARIO',
  `Usuario_registro` varchar(10) NOT NULL COMMENT 'NOMBRE DEL USUARIO QUE REALIZO EL REGISTRO',
  `Fecha_registro` datetime NOT NULL COMMENT 'FECHA EN LA QUE SE REALIZO EL REGISTRO',
  `Usuario_modificacion` varchar(10) DEFAULT NULL COMMENT 'NOMBRE DEL USUARIO QUE MODIFICO EL REGISTRO',
  `Fecha_modificacion` datetime DEFAULT NULL COMMENT 'FECHA EN LA QUE SE MODIFICO EL REGISTRO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbl_usuario`
--

INSERT INTO `tbl_usuario` (`Cod_usuario`, `Cod_rol`, `Cod_colaborador`, `Cod_sede`, `Cod_estatus`, `Nombre_usuario`, `Contrasena`, `Fecha_vencimiento`, `Usuario_registro`, `Fecha_registro`, `Usuario_modificacion`, `Fecha_modificacion`) VALUES
(1, 1, NULL, 1, 3, 'MASTER', 0x4d61737465725f313233, '2022-03-01 01:02:16', 'ADMIN', '2022-02-24 01:02:16', NULL, NULL),
(2, 2, NULL, 1, 3, 'DANIA', 0x44616e69615f313233, '2022-03-01 01:33:18', 'ADMIN', '2022-02-24 01:33:18', NULL, NULL),
(3, 3, NULL, NULL, 3, 'ALEXLOPEZ', 0x5aa79eb456b6250616d79e8795516bc7, '2022-03-01 01:46:21', 'ADMIN', '2022-02-24 01:46:21', 'ALEXLOPEZ', '2022-02-24 11:13:30'),
(4, 1, NULL, NULL, 3, 'ADMIN', 0x2dd6b296b55fc93120ee13bf1f9b127d, '2022-03-01 03:18:00', 'ADMIN', '2022-02-24 03:18:00', NULL, NULL),
(5, 1, NULL, 1, 1, 'ENRIQUE', 0xb26e846c6a1b476368c106bad7a674bd, '2022-04-02 15:29:34', 'Admin', '2022-02-24 15:29:34', 'Admin', '2022-02-24 15:29:34');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `view_parametros`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `view_parametros` (
`COD_PARAMETRO` bigint(10)
,`PARAMETRO` varchar(30)
,`VALOR` varchar(200)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `view_parametros`
--
DROP TABLE IF EXISTS `view_parametros`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_parametros`  AS  select `tbl_parametro`.`Cod_parametro` AS `COD_PARAMETRO`,`tbl_parametro`.`Parametro` AS `PARAMETRO`,`tbl_parametro`.`Valor` AS `VALOR` from `tbl_parametro` ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `tbl_asignacion_terapeuta`
--
ALTER TABLE `tbl_asignacion_terapeuta`
  ADD PRIMARY KEY (`Cod_asignacion`),
  ADD KEY `FK_COD_COLABORADOR_AT` (`Cod_colaborador`),
  ADD KEY `FK_COD_TIPO_ESPECIALIDAD_AT` (`Cod_tipo_especialidad`);

--
-- Indices de la tabla `tbl_bitacora_sistema`
--
ALTER TABLE `tbl_bitacora_sistema`
  ADD PRIMARY KEY (`Cod_bitacora`),
  ADD KEY `FK_COD_USUARIO_BS` (`Cod_usuario`);

--
-- Indices de la tabla `tbl_colaborador`
--
ALTER TABLE `tbl_colaborador`
  ADD PRIMARY KEY (`Cod_colaborador`),
  ADD KEY `FK_COD_PERSONA_C` (`Cod_persona`),
  ADD KEY `FK_COD_SEDE_C` (`Cod_sede`),
  ADD KEY `FK_COD_DEPARTAMENTO_LABORAL_C` (`Cod_departamento_laboral`);

--
-- Indices de la tabla `tbl_correo`
--
ALTER TABLE `tbl_correo`
  ADD PRIMARY KEY (`Cod_correo`),
  ADD KEY `FK_COD_PERSONA_CO` (`Cod_persona`),
  ADD KEY `FK_COD_USUARIO_CO` (`Cod_usuario`);

--
-- Indices de la tabla `tbl_departamento`
--
ALTER TABLE `tbl_departamento`
  ADD PRIMARY KEY (`Cod_departamento`);

--
-- Indices de la tabla `tbl_departamento_laboral`
--
ALTER TABLE `tbl_departamento_laboral`
  ADD PRIMARY KEY (`Cod_departamento_laboral`);

--
-- Indices de la tabla `tbl_diagnostico_evaluacion`
--
ALTER TABLE `tbl_diagnostico_evaluacion`
  ADD PRIMARY KEY (`Cod_diagnostico`),
  ADD KEY `FK_COD_PERSONA_DE` (`Cod_persona`);

--
-- Indices de la tabla `tbl_estado_civil`
--
ALTER TABLE `tbl_estado_civil`
  ADD PRIMARY KEY (`Cod_estado_civil`);

--
-- Indices de la tabla `tbl_estado_nutricional`
--
ALTER TABLE `tbl_estado_nutricional`
  ADD PRIMARY KEY (`Cod_estado_nutricional`);

--
-- Indices de la tabla `tbl_estatus`
--
ALTER TABLE `tbl_estatus`
  ADD PRIMARY KEY (`Cod_estatus`);

--
-- Indices de la tabla `tbl_familiar_encargado`
--
ALTER TABLE `tbl_familiar_encargado`
  ADD PRIMARY KEY (`Cod_familiar`),
  ADD KEY `FK_COD_PERSONA_FE` (`Cod_persona`),
  ADD KEY `FK_COD_PARENTESCO_FE` (`Cod_parentesco`),
  ADD KEY `FK_COD_NIVEL_ACADEMICO_FE` (`Cod_nivel_academico`);

--
-- Indices de la tabla `tbl_ficha_general`
--
ALTER TABLE `tbl_ficha_general`
  ADD PRIMARY KEY (`Cod_ficha_general`),
  ADD KEY `FK_COD_PERSONA_FG` (`Cod_persona`);

--
-- Indices de la tabla `tbl_ficha_inclusion`
--
ALTER TABLE `tbl_ficha_inclusion`
  ADD PRIMARY KEY (`Cod_ficha_inclusion`),
  ADD KEY `FK_COD_PERSONA_FI` (`Cod_persona`),
  ADD KEY `FK_COD_TIPO_INCLUSION_FI` (`Cod_tipo_inclusion`),
  ADD KEY `FK_COD_TIPO_INSTITUCION_FI` (`Cod_tipo_institucion`);

--
-- Indices de la tabla `tbl_ficha_institucional`
--
ALTER TABLE `tbl_ficha_institucional`
  ADD PRIMARY KEY (`Cod_ficha_institucional`),
  ADD KEY `FK_COD_PERSONA_FIN` (`Cod_persona`),
  ADD KEY `FK_COD_MODALIDAD_ATENCION_FIN` (`Cod_modalidad_atencion`),
  ADD KEY `FK_COD_MODALIDAD_SERVICIO_FIN` (`Cod_modalidad_servicio`);

--
-- Indices de la tabla `tbl_ficha_salud`
--
ALTER TABLE `tbl_ficha_salud`
  ADD PRIMARY KEY (`Cod_ficha_salud`),
  ADD KEY `FK_COD_PERSONA_FS` (`Cod_persona`),
  ADD KEY `FK_COD_ESTADO_NUTRICIONAL_FS` (`Cod_estado_nutricional`);

--
-- Indices de la tabla `tbl_genero`
--
ALTER TABLE `tbl_genero`
  ADD PRIMARY KEY (`Cod_genero`);

--
-- Indices de la tabla `tbl_historial_contrasena`
--
ALTER TABLE `tbl_historial_contrasena`
  ADD PRIMARY KEY (`Cod_historial`),
  ADD UNIQUE KEY `UN_CONTRASENA` (`Contrasena`),
  ADD KEY `FK_COD_USUARIO_HC` (`Cod_usuario`);

--
-- Indices de la tabla `tbl_informe_academico`
--
ALTER TABLE `tbl_informe_academico`
  ADD PRIMARY KEY (`Cod_informe_academico`),
  ADD KEY `FK_COD_MATRICULA_IA` (`Cod_matricula`),
  ADD KEY `FK_COD_PERSONA_IA` (`Cod_persona`);

--
-- Indices de la tabla `tbl_matricula`
--
ALTER TABLE `tbl_matricula`
  ADD PRIMARY KEY (`Cod_matricula`),
  ADD KEY `FK_COD_ASIGNACION_M` (`Cod_asignacion`),
  ADD KEY `FK_COD_PERSONA_M` (`Cod_persona`),
  ADD KEY `FK_COD_FICHA_INCLUSION_M` (`Cod_ficha_inclusion`);

--
-- Indices de la tabla `tbl_modalidad_atencion`
--
ALTER TABLE `tbl_modalidad_atencion`
  ADD PRIMARY KEY (`Cod_modalidad_atencion`);

--
-- Indices de la tabla `tbl_modalidad_servicio`
--
ALTER TABLE `tbl_modalidad_servicio`
  ADD PRIMARY KEY (`Cod_modalidad_servicio`);

--
-- Indices de la tabla `tbl_ms_bitacora`
--
ALTER TABLE `tbl_ms_bitacora`
  ADD PRIMARY KEY (`Cod_bitacora`),
  ADD KEY `FK_COD_USUARIO_MSB` (`Cod_usuario`),
  ADD KEY `FK_COD_OBJETO_MSB` (`Cod_objeto`);

--
-- Indices de la tabla `tbl_nacionalidad`
--
ALTER TABLE `tbl_nacionalidad`
  ADD PRIMARY KEY (`Cod_nacionalidad`);

--
-- Indices de la tabla `tbl_nivel_academico`
--
ALTER TABLE `tbl_nivel_academico`
  ADD PRIMARY KEY (`Cod_nivel_academico`);

--
-- Indices de la tabla `tbl_objetos`
--
ALTER TABLE `tbl_objetos`
  ADD PRIMARY KEY (`Cod_objeto`);

--
-- Indices de la tabla `tbl_parametro`
--
ALTER TABLE `tbl_parametro`
  ADD PRIMARY KEY (`Cod_parametro`),
  ADD KEY `FK_COD_USUARIO_PA` (`Cod_usuario`);

--
-- Indices de la tabla `tbl_parentesco`
--
ALTER TABLE `tbl_parentesco`
  ADD PRIMARY KEY (`Cod_parentesco`);

--
-- Indices de la tabla `tbl_permisos`
--
ALTER TABLE `tbl_permisos`
  ADD PRIMARY KEY (`Cod_permiso`),
  ADD KEY `FK_COD_ROLES_P` (`Cod_rol`),
  ADD KEY `FK_COD_OBJETOS_P` (`Cod_objeto`);

--
-- Indices de la tabla `tbl_persona`
--
ALTER TABLE `tbl_persona`
  ADD PRIMARY KEY (`Cod_persona`),
  ADD KEY `FK_COD_TIPO_PERSONA_P` (`Cod_tipo_persona`),
  ADD KEY `FK_COD_GENERO_P` (`Cod_genero`),
  ADD KEY `FK_COD_NACIONALIDAD_P` (`Cod_nacionalidad`),
  ADD KEY `FK_COD_ESTADO_CIVIL_P` (`Cod_estado_civil`),
  ADD KEY `FK_COD_DEPARTAMENTO_P` (`Cod_departamento`),
  ADD KEY `FK_COD_ESTATUS_P` (`Cod_estatus`);

--
-- Indices de la tabla `tbl_preguntas`
--
ALTER TABLE `tbl_preguntas`
  ADD PRIMARY KEY (`Cod_pregunta`);

--
-- Indices de la tabla `tbl_pregunta_usuario`
--
ALTER TABLE `tbl_pregunta_usuario`
  ADD PRIMARY KEY (`Cod_pregunta_usuario`),
  ADD KEY `FK_COD_USUARIO_PU` (`Cod_usuario`),
  ADD KEY `FK_COD_PREGUNTA_PU` (`Cod_pregunta`);

--
-- Indices de la tabla `tbl_registro_servicio_social`
--
ALTER TABLE `tbl_registro_servicio_social`
  ADD PRIMARY KEY (`Cod_registro_servicio_social`),
  ADD KEY `FK_COD_COLABORADOR_RSS` (`Cod_colaborador`),
  ADD KEY `FK_COD_SERVICIO_SOCIAL_RSS` (`Cod_servicio_social`);

--
-- Indices de la tabla `tbl_rol`
--
ALTER TABLE `tbl_rol`
  ADD PRIMARY KEY (`Cod_rol`),
  ADD KEY `FK_COD_ESTATUS_R` (`Cod_estatus`);

--
-- Indices de la tabla `tbl_sede`
--
ALTER TABLE `tbl_sede`
  ADD PRIMARY KEY (`Cod_sede`),
  ADD KEY `FK_COD_DEPARTAMENTO_S` (`Cod_departamento`),
  ADD KEY `FK_COD_ESTATUS_S` (`Cod_estatus`);

--
-- Indices de la tabla `tbl_servicio_social`
--
ALTER TABLE `tbl_servicio_social`
  ADD PRIMARY KEY (`Cod_servicio_social`),
  ADD KEY `FK_COD_ESTATUS_SS` (`Cod_estatus`);

--
-- Indices de la tabla `tbl_solicitud_evaluacion`
--
ALTER TABLE `tbl_solicitud_evaluacion`
  ADD PRIMARY KEY (`Cod_solicitud_evaluacion`),
  ADD KEY `FK_COD_DEPARTAMENTO_SE` (`Cod_departamento`),
  ADD KEY `FK_COD_SEDE_SE` (`Cod_sede`),
  ADD KEY `FK_COD_TIPO_EVALUCION_SE` (`Cod_tipo_evaluacion`),
  ADD KEY `FK_COD_PARENTESCO_SE` (`Cod_parentesco`),
  ADD KEY `FK_COD_ESTATUS_SE` (`Cod_estatus`);

--
-- Indices de la tabla `tbl_tipo_especialidad`
--
ALTER TABLE `tbl_tipo_especialidad`
  ADD PRIMARY KEY (`Cod_tipo_especialidad`);

--
-- Indices de la tabla `tbl_tipo_evaluacion`
--
ALTER TABLE `tbl_tipo_evaluacion`
  ADD PRIMARY KEY (`Cod_tipo_evaluacion`);

--
-- Indices de la tabla `tbl_tipo_inclusion`
--
ALTER TABLE `tbl_tipo_inclusion`
  ADD PRIMARY KEY (`Cod_tipo_inclusion`);

--
-- Indices de la tabla `tbl_tipo_institucion`
--
ALTER TABLE `tbl_tipo_institucion`
  ADD PRIMARY KEY (`Cod_tipo_institucion`);

--
-- Indices de la tabla `tbl_tipo_persona`
--
ALTER TABLE `tbl_tipo_persona`
  ADD PRIMARY KEY (`Cod_tipo_persona`);

--
-- Indices de la tabla `tbl_usuario`
--
ALTER TABLE `tbl_usuario`
  ADD PRIMARY KEY (`Cod_usuario`),
  ADD KEY `FK_COD_ROL_U` (`Cod_rol`),
  ADD KEY `FK_COD_COLABORADOR_U` (`Cod_colaborador`),
  ADD KEY `FK_COD_SEDE_U` (`Cod_sede`),
  ADD KEY `FK_COD_ESTATUS_U` (`Cod_estatus`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `tbl_asignacion_terapeuta`
--
ALTER TABLE `tbl_asignacion_terapeuta`
  MODIFY `Cod_asignacion` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla asignacion terapeuta';

--
-- AUTO_INCREMENT de la tabla `tbl_bitacora_sistema`
--
ALTER TABLE `tbl_bitacora_sistema`
  MODIFY `Cod_bitacora` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'LLAVE PRIMARIA DE LA TABLA', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `tbl_colaborador`
--
ALTER TABLE `tbl_colaborador`
  MODIFY `Cod_colaborador` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla colaborador';

--
-- AUTO_INCREMENT de la tabla `tbl_correo`
--
ALTER TABLE `tbl_correo`
  MODIFY `Cod_correo` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA CORREO ELECTRONICO';

--
-- AUTO_INCREMENT de la tabla `tbl_departamento`
--
ALTER TABLE `tbl_departamento`
  MODIFY `Cod_departamento` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA DEPARTAMENTOS', AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT de la tabla `tbl_departamento_laboral`
--
ALTER TABLE `tbl_departamento_laboral`
  MODIFY `Cod_departamento_laboral` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA DEPARTAMENTOS LABORALES', AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `tbl_diagnostico_evaluacion`
--
ALTER TABLE `tbl_diagnostico_evaluacion`
  MODIFY `Cod_diagnostico` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla diagnostico evaluacion';

--
-- AUTO_INCREMENT de la tabla `tbl_estado_civil`
--
ALTER TABLE `tbl_estado_civil`
  MODIFY `Cod_estado_civil` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCRMENTO DE LLAVE PRIMARIA TABLA ESTADO CIVIL', AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `tbl_estado_nutricional`
--
ALTER TABLE `tbl_estado_nutricional`
  MODIFY `Cod_estado_nutricional` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA ESTADO NUTRICIONAL', AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `tbl_estatus`
--
ALTER TABLE `tbl_estatus`
  MODIFY `Cod_estatus` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA ESTATUS', AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `tbl_familiar_encargado`
--
ALTER TABLE `tbl_familiar_encargado`
  MODIFY `Cod_familiar` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA FAMILIAR ENCARGADO';

--
-- AUTO_INCREMENT de la tabla `tbl_ficha_general`
--
ALTER TABLE `tbl_ficha_general`
  MODIFY `Cod_ficha_general` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla ficha general';

--
-- AUTO_INCREMENT de la tabla `tbl_ficha_inclusion`
--
ALTER TABLE `tbl_ficha_inclusion`
  MODIFY `Cod_ficha_inclusion` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA FICHA INCLUSION';

--
-- AUTO_INCREMENT de la tabla `tbl_ficha_institucional`
--
ALTER TABLE `tbl_ficha_institucional`
  MODIFY `Cod_ficha_institucional` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla ficha institucional';

--
-- AUTO_INCREMENT de la tabla `tbl_ficha_salud`
--
ALTER TABLE `tbl_ficha_salud`
  MODIFY `Cod_ficha_salud` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla ficha general';

--
-- AUTO_INCREMENT de la tabla `tbl_genero`
--
ALTER TABLE `tbl_genero`
  MODIFY `Cod_genero` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA GENEROS', AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `tbl_historial_contrasena`
--
ALTER TABLE `tbl_historial_contrasena`
  MODIFY `Cod_historial` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA HISTORIAL CONTRASEÑAS';

--
-- AUTO_INCREMENT de la tabla `tbl_informe_academico`
--
ALTER TABLE `tbl_informe_academico`
  MODIFY `Cod_informe_academico` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA INFORME ACADEMICO';

--
-- AUTO_INCREMENT de la tabla `tbl_matricula`
--
ALTER TABLE `tbl_matricula`
  MODIFY `Cod_matricula` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA MATRICULAS';

--
-- AUTO_INCREMENT de la tabla `tbl_modalidad_atencion`
--
ALTER TABLE `tbl_modalidad_atencion`
  MODIFY `Cod_modalidad_atencion` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA MODALIDAD DE ATENCIÓN', AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `tbl_modalidad_servicio`
--
ALTER TABLE `tbl_modalidad_servicio`
  MODIFY `Cod_modalidad_servicio` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA MODALIDAD DE SERVICIO', AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `tbl_ms_bitacora`
--
ALTER TABLE `tbl_ms_bitacora`
  MODIFY `Cod_bitacora` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA BITACORA';

--
-- AUTO_INCREMENT de la tabla `tbl_nivel_academico`
--
ALTER TABLE `tbl_nivel_academico`
  MODIFY `Cod_nivel_academico` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA NIVEL ACADEMICO', AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `tbl_objetos`
--
ALTER TABLE `tbl_objetos`
  MODIFY `Cod_objeto` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA OBJETOS', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tbl_parametro`
--
ALTER TABLE `tbl_parametro`
  MODIFY `Cod_parametro` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA PARAMETRO';

--
-- AUTO_INCREMENT de la tabla `tbl_parentesco`
--
ALTER TABLE `tbl_parentesco`
  MODIFY `Cod_parentesco` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA PARENTESCO', AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `tbl_permisos`
--
ALTER TABLE `tbl_permisos`
  MODIFY `Cod_permiso` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla permisos', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `tbl_persona`
--
ALTER TABLE `tbl_persona`
  MODIFY `Cod_persona` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla persona';

--
-- AUTO_INCREMENT de la tabla `tbl_preguntas`
--
ALTER TABLE `tbl_preguntas`
  MODIFY `Cod_pregunta` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA PREGUNTAS PARA EL USUARIO', AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tbl_pregunta_usuario`
--
ALTER TABLE `tbl_pregunta_usuario`
  MODIFY `Cod_pregunta_usuario` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla pregunta_usuario', AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `tbl_registro_servicio_social`
--
ALTER TABLE `tbl_registro_servicio_social`
  MODIFY `Cod_registro_servicio_social` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla registro servicio social';

--
-- AUTO_INCREMENT de la tabla `tbl_rol`
--
ALTER TABLE `tbl_rol`
  MODIFY `Cod_rol` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA ROLES', AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tbl_sede`
--
ALTER TABLE `tbl_sede`
  MODIFY `Cod_sede` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla sede', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `tbl_servicio_social`
--
ALTER TABLE `tbl_servicio_social`
  MODIFY `Cod_servicio_social` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'llave primaria de la tabla servicio social';

--
-- AUTO_INCREMENT de la tabla `tbl_solicitud_evaluacion`
--
ALTER TABLE `tbl_solicitud_evaluacion`
  MODIFY `Cod_solicitud_evaluacion` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA SOLICITUD EVALUACION';

--
-- AUTO_INCREMENT de la tabla `tbl_tipo_especialidad`
--
ALTER TABLE `tbl_tipo_especialidad`
  MODIFY `Cod_tipo_especialidad` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA TIPOS DE ESPECILIDAD';

--
-- AUTO_INCREMENT de la tabla `tbl_tipo_evaluacion`
--
ALTER TABLE `tbl_tipo_evaluacion`
  MODIFY `Cod_tipo_evaluacion` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIAICE TABLA TIPO DE EVALUACIONES';

--
-- AUTO_INCREMENT de la tabla `tbl_tipo_inclusion`
--
ALTER TABLE `tbl_tipo_inclusion`
  MODIFY `Cod_tipo_inclusion` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA TIPO DE INCLUSIONES';

--
-- AUTO_INCREMENT de la tabla `tbl_tipo_institucion`
--
ALTER TABLE `tbl_tipo_institucion`
  MODIFY `Cod_tipo_institucion` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA TIPO DE INSTITUCIÓN';

--
-- AUTO_INCREMENT de la tabla `tbl_tipo_persona`
--
ALTER TABLE `tbl_tipo_persona`
  MODIFY `Cod_tipo_persona` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA TIPO DE PERSONA', AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tbl_usuario`
--
ALTER TABLE `tbl_usuario`
  MODIFY `Cod_usuario` bigint(10) NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENTO DE LLAVE PRIMARIA TABLA USUARIOS', AUTO_INCREMENT=6;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `tbl_asignacion_terapeuta`
--
ALTER TABLE `tbl_asignacion_terapeuta`
  ADD CONSTRAINT `FK_COD_COLABORADOR_AT` FOREIGN KEY (`Cod_colaborador`) REFERENCES `tbl_colaborador` (`Cod_colaborador`),
  ADD CONSTRAINT `FK_COD_TIPO_ESPECIALIDAD_AT` FOREIGN KEY (`Cod_tipo_especialidad`) REFERENCES `tbl_tipo_especialidad` (`Cod_tipo_especialidad`);

--
-- Filtros para la tabla `tbl_bitacora_sistema`
--
ALTER TABLE `tbl_bitacora_sistema`
  ADD CONSTRAINT `FK_COD_USUARIO_BS` FOREIGN KEY (`Cod_usuario`) REFERENCES `tbl_usuario` (`Cod_usuario`);

--
-- Filtros para la tabla `tbl_colaborador`
--
ALTER TABLE `tbl_colaborador`
  ADD CONSTRAINT `FK_COD_DEPARTAMENTO_LABORAL_C` FOREIGN KEY (`Cod_departamento_laboral`) REFERENCES `tbl_departamento_laboral` (`Cod_departamento_laboral`),
  ADD CONSTRAINT `FK_COD_PERSONA_C` FOREIGN KEY (`Cod_persona`) REFERENCES `tbl_persona` (`Cod_persona`),
  ADD CONSTRAINT `FK_COD_SEDE_C` FOREIGN KEY (`Cod_sede`) REFERENCES `tbl_sede` (`Cod_sede`);

--
-- Filtros para la tabla `tbl_correo`
--
ALTER TABLE `tbl_correo`
  ADD CONSTRAINT `FK_COD_PERSONA_CO` FOREIGN KEY (`Cod_persona`) REFERENCES `tbl_persona` (`Cod_persona`),
  ADD CONSTRAINT `FK_COD_USUARIO_CO` FOREIGN KEY (`Cod_usuario`) REFERENCES `tbl_usuario` (`Cod_usuario`);

--
-- Filtros para la tabla `tbl_diagnostico_evaluacion`
--
ALTER TABLE `tbl_diagnostico_evaluacion`
  ADD CONSTRAINT `FK_COD_PERSONA_DE` FOREIGN KEY (`Cod_persona`) REFERENCES `tbl_persona` (`Cod_persona`);

--
-- Filtros para la tabla `tbl_familiar_encargado`
--
ALTER TABLE `tbl_familiar_encargado`
  ADD CONSTRAINT `FK_COD_NIVEL_ACADEMICO_FE` FOREIGN KEY (`Cod_nivel_academico`) REFERENCES `tbl_nivel_academico` (`Cod_nivel_academico`),
  ADD CONSTRAINT `FK_COD_PARENTESCO_FE` FOREIGN KEY (`Cod_parentesco`) REFERENCES `tbl_parentesco` (`Cod_parentesco`),
  ADD CONSTRAINT `FK_COD_PERSONA_FE` FOREIGN KEY (`Cod_persona`) REFERENCES `tbl_persona` (`Cod_persona`);

--
-- Filtros para la tabla `tbl_ficha_general`
--
ALTER TABLE `tbl_ficha_general`
  ADD CONSTRAINT `FK_COD_PERSONA_FG` FOREIGN KEY (`Cod_persona`) REFERENCES `tbl_persona` (`Cod_persona`);

--
-- Filtros para la tabla `tbl_ficha_inclusion`
--
ALTER TABLE `tbl_ficha_inclusion`
  ADD CONSTRAINT `FK_COD_PERSONA_FI` FOREIGN KEY (`Cod_persona`) REFERENCES `tbl_persona` (`Cod_persona`),
  ADD CONSTRAINT `FK_COD_TIPO_INCLUSION_FI` FOREIGN KEY (`Cod_tipo_inclusion`) REFERENCES `tbl_tipo_inclusion` (`Cod_tipo_inclusion`),
  ADD CONSTRAINT `FK_COD_TIPO_INSTITUCION_FI` FOREIGN KEY (`Cod_tipo_institucion`) REFERENCES `tbl_tipo_institucion` (`Cod_tipo_institucion`);

--
-- Filtros para la tabla `tbl_ficha_institucional`
--
ALTER TABLE `tbl_ficha_institucional`
  ADD CONSTRAINT `FK_COD_MODALIDAD_ATENCION_FIN` FOREIGN KEY (`Cod_modalidad_atencion`) REFERENCES `tbl_modalidad_atencion` (`Cod_modalidad_atencion`),
  ADD CONSTRAINT `FK_COD_MODALIDAD_SERVICIO_FIN` FOREIGN KEY (`Cod_modalidad_servicio`) REFERENCES `tbl_modalidad_servicio` (`Cod_modalidad_servicio`),
  ADD CONSTRAINT `FK_COD_PERSONA_FIN` FOREIGN KEY (`Cod_persona`) REFERENCES `tbl_persona` (`Cod_persona`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `tbl_ficha_salud`
--
ALTER TABLE `tbl_ficha_salud`
  ADD CONSTRAINT `FK_COD_ESTADO_NUTRICIONAL_FS` FOREIGN KEY (`Cod_estado_nutricional`) REFERENCES `tbl_estado_nutricional` (`Cod_estado_nutricional`),
  ADD CONSTRAINT `FK_COD_PERSONA_FS` FOREIGN KEY (`Cod_persona`) REFERENCES `tbl_persona` (`Cod_persona`);

--
-- Filtros para la tabla `tbl_historial_contrasena`
--
ALTER TABLE `tbl_historial_contrasena`
  ADD CONSTRAINT `FK_COD_USUARIO_HC` FOREIGN KEY (`Cod_usuario`) REFERENCES `tbl_usuario` (`Cod_usuario`);

--
-- Filtros para la tabla `tbl_informe_academico`
--
ALTER TABLE `tbl_informe_academico`
  ADD CONSTRAINT `FK_COD_MATRICULA_IA` FOREIGN KEY (`Cod_matricula`) REFERENCES `tbl_matricula` (`Cod_matricula`),
  ADD CONSTRAINT `FK_COD_PERSONA_IA` FOREIGN KEY (`Cod_persona`) REFERENCES `tbl_persona` (`Cod_persona`);

--
-- Filtros para la tabla `tbl_matricula`
--
ALTER TABLE `tbl_matricula`
  ADD CONSTRAINT `FK_COD_ASIGNACION_M` FOREIGN KEY (`Cod_asignacion`) REFERENCES `tbl_asignacion_terapeuta` (`Cod_asignacion`),
  ADD CONSTRAINT `FK_COD_FICHA_INCLUSION_M` FOREIGN KEY (`Cod_ficha_inclusion`) REFERENCES `tbl_ficha_inclusion` (`Cod_ficha_inclusion`),
  ADD CONSTRAINT `FK_COD_PERSONA_M` FOREIGN KEY (`Cod_persona`) REFERENCES `tbl_persona` (`Cod_persona`);

--
-- Filtros para la tabla `tbl_ms_bitacora`
--
ALTER TABLE `tbl_ms_bitacora`
  ADD CONSTRAINT `FK_COD_OBJETO_MSB` FOREIGN KEY (`Cod_objeto`) REFERENCES `tbl_objetos` (`Cod_objeto`),
  ADD CONSTRAINT `FK_COD_USUARIO_MSB` FOREIGN KEY (`Cod_usuario`) REFERENCES `tbl_usuario` (`Cod_usuario`);

--
-- Filtros para la tabla `tbl_parametro`
--
ALTER TABLE `tbl_parametro`
  ADD CONSTRAINT `FK_COD_USUARIO_PA` FOREIGN KEY (`Cod_usuario`) REFERENCES `tbl_usuario` (`Cod_usuario`);

--
-- Filtros para la tabla `tbl_permisos`
--
ALTER TABLE `tbl_permisos`
  ADD CONSTRAINT `FK_COD_OBJETOS_P` FOREIGN KEY (`Cod_objeto`) REFERENCES `tbl_objetos` (`Cod_objeto`),
  ADD CONSTRAINT `FK_COD_ROLES_P` FOREIGN KEY (`Cod_rol`) REFERENCES `tbl_rol` (`Cod_rol`);

--
-- Filtros para la tabla `tbl_persona`
--
ALTER TABLE `tbl_persona`
  ADD CONSTRAINT `FK_COD_DEPARTAMENTO_P` FOREIGN KEY (`Cod_departamento`) REFERENCES `tbl_departamento` (`Cod_departamento`),
  ADD CONSTRAINT `FK_COD_ESTADO_CIVIL_P` FOREIGN KEY (`Cod_estado_civil`) REFERENCES `tbl_estado_civil` (`Cod_estado_civil`),
  ADD CONSTRAINT `FK_COD_ESTATUS_P` FOREIGN KEY (`Cod_estatus`) REFERENCES `tbl_estatus` (`Cod_estatus`),
  ADD CONSTRAINT `FK_COD_GENERO_P` FOREIGN KEY (`Cod_genero`) REFERENCES `tbl_genero` (`Cod_genero`),
  ADD CONSTRAINT `FK_COD_NACIONALIDAD_P` FOREIGN KEY (`Cod_nacionalidad`) REFERENCES `tbl_nacionalidad` (`Cod_nacionalidad`),
  ADD CONSTRAINT `FK_COD_TIPO_PERSONA_P` FOREIGN KEY (`Cod_tipo_persona`) REFERENCES `tbl_tipo_persona` (`Cod_tipo_persona`);

--
-- Filtros para la tabla `tbl_pregunta_usuario`
--
ALTER TABLE `tbl_pregunta_usuario`
  ADD CONSTRAINT `FK_COD_PREGUNTA_PU` FOREIGN KEY (`Cod_pregunta`) REFERENCES `tbl_preguntas` (`Cod_pregunta`),
  ADD CONSTRAINT `FK_COD_USUARIO_PU` FOREIGN KEY (`Cod_usuario`) REFERENCES `tbl_usuario` (`Cod_usuario`);

--
-- Filtros para la tabla `tbl_registro_servicio_social`
--
ALTER TABLE `tbl_registro_servicio_social`
  ADD CONSTRAINT `FK_COD_COLABORADOR_RSS` FOREIGN KEY (`Cod_colaborador`) REFERENCES `tbl_colaborador` (`Cod_colaborador`),
  ADD CONSTRAINT `FK_COD_SERVICIO_SOCIAL_RSS` FOREIGN KEY (`Cod_servicio_social`) REFERENCES `tbl_servicio_social` (`Cod_servicio_social`);

--
-- Filtros para la tabla `tbl_rol`
--
ALTER TABLE `tbl_rol`
  ADD CONSTRAINT `FK_COD_ESTATUS_R` FOREIGN KEY (`Cod_estatus`) REFERENCES `tbl_estatus` (`Cod_estatus`);

--
-- Filtros para la tabla `tbl_sede`
--
ALTER TABLE `tbl_sede`
  ADD CONSTRAINT `FK_COD_DEPARTAMENTO_S` FOREIGN KEY (`Cod_departamento`) REFERENCES `tbl_departamento` (`Cod_departamento`),
  ADD CONSTRAINT `FK_COD_ESTATUS_S` FOREIGN KEY (`Cod_estatus`) REFERENCES `tbl_estatus` (`Cod_estatus`);

--
-- Filtros para la tabla `tbl_servicio_social`
--
ALTER TABLE `tbl_servicio_social`
  ADD CONSTRAINT `FK_COD_ESTATUS_SS` FOREIGN KEY (`Cod_estatus`) REFERENCES `tbl_estatus` (`Cod_estatus`);

--
-- Filtros para la tabla `tbl_solicitud_evaluacion`
--
ALTER TABLE `tbl_solicitud_evaluacion`
  ADD CONSTRAINT `FK_COD_DEPARTAMENTO_SE` FOREIGN KEY (`Cod_departamento`) REFERENCES `tbl_departamento` (`Cod_departamento`),
  ADD CONSTRAINT `FK_COD_ESTATUS_SE` FOREIGN KEY (`Cod_estatus`) REFERENCES `tbl_estatus` (`Cod_estatus`),
  ADD CONSTRAINT `FK_COD_PARENTESCO_SE` FOREIGN KEY (`Cod_parentesco`) REFERENCES `tbl_parentesco` (`Cod_parentesco`),
  ADD CONSTRAINT `FK_COD_SEDE_SE` FOREIGN KEY (`Cod_sede`) REFERENCES `tbl_sede` (`Cod_sede`),
  ADD CONSTRAINT `FK_COD_TIPO_EVALUCION_SE` FOREIGN KEY (`Cod_tipo_evaluacion`) REFERENCES `tbl_tipo_evaluacion` (`Cod_tipo_evaluacion`);

--
-- Filtros para la tabla `tbl_usuario`
--
ALTER TABLE `tbl_usuario`
  ADD CONSTRAINT `FK_COD_COLABORADOR_U` FOREIGN KEY (`Cod_colaborador`) REFERENCES `tbl_colaborador` (`Cod_colaborador`),
  ADD CONSTRAINT `FK_COD_ESTATUS_U` FOREIGN KEY (`Cod_estatus`) REFERENCES `tbl_estatus` (`Cod_estatus`),
  ADD CONSTRAINT `FK_COD_ROL_U` FOREIGN KEY (`Cod_rol`) REFERENCES `tbl_rol` (`Cod_rol`),
  ADD CONSTRAINT `FK_COD_SEDE_U` FOREIGN KEY (`Cod_sede`) REFERENCES `tbl_sede` (`Cod_sede`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
