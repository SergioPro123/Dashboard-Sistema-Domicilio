-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 14-10-2020 a las 23:22:49
-- Versión del servidor: 10.4.14-MariaDB
-- Versión de PHP: 7.2.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `sistemadomicilio`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `aceptarServicio` (IN `idDomiciliarioVariable` INT(11), IN `idServicioVariables` INT(15), IN `horaInicioVariable` TIME)  NO SQL
BEGIN
	DECLARE idEncargadoServicio INT;
    SELECT servicios.id_encargados INTO idEncargadoServicio
    FROM servicios 
    WHERE servicios.id_servicios = idServicioVariables;
    
	CALL
addEncargadosDomiciliario(idEncargadoServicio,idDomiciliarioVariable,@idEncargados);
	CALL getIdDate(CURDATE(),horaInicioVariable,"00:00:00",@idDate);
    
	CALL getIdEstadoServicio("ASIGNADO",@idEstadoServicio);
	UPDATE servicios
    SET servicios.id_encargados = @idEncargados,
    	servicios.id_estadoServicio = @idEstadoServicio,
        servicios.id_date = @idDate
    WHERE servicios.id_servicios = idServicioVariables;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarAdmin` (IN `idAdminVariable` INT(11), IN `nombreVariable` VARCHAR(50), IN `cedulaVariable` VARCHAR(10), IN `celularVariable` VARCHAR(11), IN `pathImageVariable` VARCHAR(255), IN `estadoUsuario` VARCHAR(50))  NO SQL
BEGIN
	DECLARE idDatosPersonalesVariable INT;
    
	CALL getIdEstadoUsuario(estadoUsuario,@idEstadoUsuario);
    
    SELECT usuario.id_datosPersonales INTO idDatosPersonalesVariable FROM usuario 
    WHERE usuario.id_usuario = idAdminVariable LIMIT 1;	
    
       CALL setIdDatosPersonales(idDatosPersonalesVariable,nombreVariable,cedulaVariable,celularVariable,pathImageVariable);
    
    UPDATE usuario
    SET 
    usuario.id_estadoUsuario = @idEstadoUsuario,
    usuario.id_turno = @idTurno
    WHERE usuario.id_usuario = idAdminVariable;  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarCliente` (IN `idClienteVariable` INT(11), IN `nombreVariable` VARCHAR(40), IN `celularVariable` VARCHAR(10))  NO SQL
BEGIN

	UPDATE cliente
    SET cliente.nombre=nombreVariable,
    cliente.celular = celularVariable
    WHERE cliente.id_cliente = idClienteVariable;
	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarDomiciliario` (IN `idDomiciliarioVariable` INT(11), IN `nombreVariable` VARCHAR(50), IN `cedulaVariable` VARCHAR(10), IN `celularVariable` VARCHAR(11), IN `turnoVariable` VARCHAR(50), IN `pathImageVariable` VARCHAR(255), IN `estadoUsuario` VARCHAR(50))  NO SQL
BEGIN
	DECLARE idDatosPersonalesVariable INT;
    
	CALL getIdEstadoUsuario(estadoUsuario,@idEstadoUsuario);
    CALL getIdTurno(turnoVariable,@idTurno);
    
    	SELECT usuario.id_datosPersonales INTO idDatosPersonalesVariable FROM usuario 
    WHERE usuario.id_usuario = idDomiciliarioVariable LIMIT 1;	
    
       CALL setIdDatosPersonales(idDatosPersonalesVariable,nombreVariable,cedulaVariable,celularVariable,pathImageVariable);
    
    UPDATE usuario
    SET 
    usuario.id_estadoUsuario = @idEstadoUsuario,
    usuario.id_turno = @idTurno
    WHERE usuario.id_usuario = idDomiciliarioVariable;  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addDireccion` (IN `idClienteVariable` INT(11), IN `direccionVariable` VARCHAR(50), OUT `idDireccionVariable` INT)  NO SQL
BEGIN
INSERT INTO direcciones(direcciones.id_cliente,direcciones.direccion)
			VALUES(idClienteVariable,direccionVariable);
   SELECT LAST_INSERT_ID() into idDireccionVariable;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addEncargadosAdmin` (IN `idAdminVariable` INT(11), OUT `idEncargados` INT(15))  NO SQL
BEGIN

	INSERT INTO encargados(encargados.id_usuario_ADMIN)
    			VALUES(idAdminVariable);
    SELECT LAST_INSERT_ID() INTO idEncargados;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addEncargadosDomiciliario` (IN `idEncargadosVariable` INT(11), IN `idDomiciliarioVariable` INT(11), OUT `idEncargados` INT(15))  NO SQL
BEGIN

	DECLARE idAdmin INT;
    DECLARE existeEncargados INT;
    
    SELECT encargados.id_usuario_ADMIN INTO idAdmin
    	FROM encargados 
        WHERE 
        	encargados.id_encargados = idEncargadosVariable;
            
    
    SELECT  COUNT(encargados.id_encargados) INTO existeEncargados 
    FROM encargados 
    WHERE encargados.id_usuario_ADMIN= idAdmin
    AND   encargados.id_usuario_DOMICILIARIO = idDomiciliarioVariable; 
    
    IF existeEncargados > 0 THEN
    	SELECT encargados.id_encargados INTO idEncargados 
        FROM encargados 
    	WHERE encargados.id_usuario_ADMIN= idAdmin
    	AND   encargados.id_usuario_DOMICILIARIO = idDomiciliarioVariable;
        
        DELETE FROM encargados 
        WHERE encargados.id_encargados = idEncargadosVariable;
    ELSE
    	UPDATE encargados 
        SET encargados.id_usuario_DOMICILIARIO = idDomiciliarioVariable
        WHERE encargados.id_encargados = idEncargadosVariable ;
        
        SET idEncargados = idEncargadosVariable;
    END IF;    

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addEvidencia` (IN `id_ServiciosVariable` INT(15), IN `path_evidenciaVariable` VARCHAR(255))  NO SQL
BEGIN

INSERT INTO evidencia(evidencia.path_evidencia,evidencia.id_servicios)
			VALUES(path_evidenciaVariable,id_ServiciosVariable);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `agregarAdmin` (IN `nombreVariable` VARCHAR(50), IN `cedulaVariable` VARCHAR(10), IN `celularVariable` VARCHAR(11), IN `emailVariable` VARCHAR(50), IN `passwordVariable` VARCHAR(20), IN `pathImageVariable` VARCHAR(255), IN `estadoUsuarioVariable` VARCHAR(50))  NO SQL
BEGIN
	declare exit handler for 1062
    BEGIN
    	SIGNAL SQLSTATE '10620' SET MESSAGE_TEXT = 'Llave Duplicada';
    END;
	 CALL getIdCredenciales(emailVariable,passwordVariable,@idCredenciales);
        CALL insertDatosPersonales(nombreVariable,cedulaVariable,celularVariable,pathImageVariable,@idDatosPersonales);
        CALL getIdEstadoUsuario(estadoUsuarioVariable,@idEstadoUsuario);
        CALL getIdRol("ADMIN",@idRol);

        INSERT INTO usuario(id_rol,id_estadoUsuario,id_datosPersonales,id_credenciales) VALUES(@idRol,@idEstadoUsuario,@idDatosPersonales,@idCredenciales);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `agregarCliente` (IN `nombreVariable` VARCHAR(40), IN `celularVariable` VARCHAR(10), IN `direccionVariable` VARCHAR(50))  NO SQL
BEGIN
	DECLARE idCliente INT;
	INSERT INTO cliente(cliente.nombre,cliente.celular)
    			VALUES(nombreVariable,celularVariable);

	SELECT LAST_INSERT_ID() into idCliente;
    CALL addDireccion(idCliente,direccionVariable,@idDireccion);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `agregarDomiciliario` (IN `nombreVariable` VARCHAR(50), IN `cedulaVariable` VARCHAR(10), IN `celularVariable` VARCHAR(11), IN `turnoVariable` VARCHAR(50), IN `emailVariable` VARCHAR(50), IN `passwordVariable` VARCHAR(20), IN `pathImageVariable` VARCHAR(255), IN `estadoUsuarioVariable` VARCHAR(50))  BEGIN
	declare exit handler for 1062
    BEGIN
    	SIGNAL SQLSTATE '10620' SET MESSAGE_TEXT = 'Llave Duplicada';
    END;
	CALL getIdEstadoUsuario(estadoUsuarioVariable,@idEstadoUsuario);
	CALL insertDatosPersonales(nombreVariable,cedulaVariable,celularVariable,pathImageVariable,@idDatosPersonales);
	CALL getIdRol("USER",@idRol);
    CALL getIdTurno(turnoVariable,@idTurno);
    CALL getIdCredenciales(emailVariable,passwordVariable,@idCredenciales);
    
    INSERT INTO usuario(id_rol,id_estadoUsuario,id_datosPersonales,id_credenciales,id_turno) VALUES(@idRol,@idEstadoUsuario,@idDatosPersonales,@idCredenciales,@idTurno);
    
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `concluirServicio` (IN `idServicioVariable` INT(15), IN `horaInicioVariable` TIME, IN `HoraFinalVariable` TIME)  NO SQL
BEGIN

	CALL getIdDate(CURDATE(),horaInicioVariable,HoraFinalVariable,@idDate);
    CALL getIdEstadoServicio("COMPLETADO",@idEstadoServicio);
    
    UPDATE servicios
    SET	servicios.id_estadoServicio = @idEstadoServicio,
        servicios.id_date = @idDate
    WHERE servicios.id_servicios = idServicioVariable;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarAdmins` ()  NO SQL
BEGIN

CALL getIdRol("ADMIN",@idRol);
SELECT
    	usuario.id_usuario,
        credenciales.email,
        datospersonales.nombre,
        datospersonales.cedula,
        datospersonales.celular,
        datospersonales.pathImage,
        estadousuario.estado
    FROM usuario
   	INNER JOIN credenciales
    		ON usuario.id_credenciales = credenciales.id_credenciales
    INNER JOIN datospersonales
    		ON usuario.id_datosPersonales = datospersonales.id_datosPersonales
    INNER JOIN estadousuario
    		ON usuario.id_estadoUsuario = estadousuario.id_estadoUsuario
    WHERE usuario.id_rol = @idRol;  

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarClientes` ()  NO SQL
BEGIN

	SELECT * 
    FROM cliente;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarDirecciones` ()  NO SQL
BEGIN
	
    SELECT direcciones.id_cliente,
    		direcciones.direccion
    FROM direcciones;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarDireccionesIndividual` (IN `idClienteVariable` INT(11))  NO SQL
BEGIN

	SELECT direcciones.direccion
    FROM direcciones
    WHERE direcciones.id_cliente = idClienteVariable;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarDomiciliarios` ()  NO SQL
BEGIN
CALL getIdRol("USER",@idRol);
SELECT
    	usuario.id_usuario,
        credenciales.email,
        datospersonales.nombre,
        datospersonales.cedula,
        datospersonales.celular,
        datospersonales.pathImage,
        turno.nombre as nombreTurno,
        turno.horaInicio,
        turno.horaFinal,
        estadousuario.estado
    FROM usuario
   	INNER JOIN credenciales
    		ON usuario.id_credenciales = credenciales.id_credenciales
    INNER JOIN datospersonales
    		ON usuario.id_datosPersonales = datospersonales.id_datosPersonales
    INNER JOIN turno
    		ON usuario.id_turno = turno.id_turno
    INNER JOIN estadousuario
    		ON usuario.id_estadoUsuario = estadousuario.id_estadoUsuario
    WHERE usuario.id_rol = @idRol;  
        
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarEvidencias` ()  NO SQL
BEGIN

	SELECT
    	evidencia.id_servicios,
    	evidencia.path_evidencia
    FROM evidencia;
   

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarServicios` ()  NO SQL
BEGIN

SELECT
    myAdmin.nombre AS nombreAdmin,
    myUser.nombre AS nombreDomiciliario,
    cliente.nombre AS nombreCliente,
    estadoservicio.estado AS estadoservicio,
    direcciones.direccion AS direccion,
    tiposervicios.servicios AS tiposervicio,
    tiposervicios.valor AS valorServicio,
    servicios.adicional AS valorAdicional,
    servicios.descripcion AS descripcion,
    mydate.fecha AS Fecha,
    mydate.horaInicio AS horaInicio,
    mydate.horaFinal AS horaFinal
FROM servicios
INNER JOIN cliente
			ON servicios.id_cliente = cliente.id_cliente
INNER JOIN direcciones
			ON servicios.id_direcciones= direcciones.id_direcciones
INNER JOIN tiposervicios
			ON servicios.id_tipoServicios= tiposervicios.id_tipoServicios  
INNER JOIN estadoservicio
			ON servicios.id_estadoServicio = estadoservicio.id_estadoServicio   
INNER JOIN mydate
			ON servicios.id_date = mydate.id_date            
INNER JOIN encargados
			ON servicios.id_encargados = encargados.id_encargados
INNER JOIN usuario AS myAdminEncargado
			ON myAdminEncargado.id_usuario = encargados.id_usuario_ADMIN
LEFT JOIN usuario AS myUserEncargado
			ON myUserEncargado.id_usuario = encargados.id_usuario_DOMICILIARIO
INNER JOIN datospersonales AS myAdmin
			ON myAdmin.id_datosPersonales = myAdminEncargado.id_datosPersonales
LEFT JOIN datospersonales AS myUser
			ON myUser.id_datosPersonales = myUserEncargado.id_datosPersonales;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarServicios_SINASIGNAR` ()  NO SQL
BEGIN

SELECT
    myAdmin.nombre AS nombreAdmin,
    myUser.nombre AS nombreDomiciliario,
    cliente.nombre AS nombreCliente,
    estadoservicio.estado AS estadoservicio,
    direcciones.direccion AS direccion,
    tiposervicios.servicios AS tiposervicio,
    tiposervicios.valor AS valorServicio,
    servicios.adicional AS valorAdicional,
    servicios.descripcion AS descripcion,
    mydate.fecha AS Fecha,
    mydate.horaInicio AS horaInicio,
    mydate.horaFinal AS horaFinal
FROM servicios
INNER JOIN cliente
			ON servicios.id_cliente = cliente.id_cliente
INNER JOIN direcciones
			ON servicios.id_direcciones= direcciones.id_direcciones
INNER JOIN tiposervicios
			ON servicios.id_tipoServicios= tiposervicios.id_tipoServicios  
INNER JOIN estadoservicio
			ON servicios.id_estadoServicio = estadoservicio.id_estadoServicio   
INNER JOIN mydate
			ON servicios.id_date = mydate.id_date            
INNER JOIN encargados
			ON servicios.id_encargados = encargados.id_encargados
INNER JOIN usuario AS myAdminEncargado
			ON myAdminEncargado.id_usuario = encargados.id_usuario_ADMIN
LEFT JOIN usuario AS myUserEncargado
			ON myUserEncargado.id_usuario = encargados.id_usuario_DOMICILIARIO
INNER JOIN datospersonales AS myAdmin
			ON myAdmin.id_datosPersonales = myAdminEncargado.id_datosPersonales
LEFT JOIN datospersonales AS myUser
			ON myUser.id_datosPersonales = myUserEncargado.id_datosPersonales
WHERE estadoservicio.estado ="SIN_ASIGNAR";

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminarUsuario` (IN `idUsuarioVariable` INT(11))  NO SQL
    COMMENT 'Se cambia el estado a "ELIMINADO" al usuario mediante ID.'
BEGIN
	CALL getIdEstadoUsuario("ELIMINADO",@idEstadoUsuario);
	UPDATE usuario
    SET usuario.id_estadoUsuario = @idEstadoUsuario
    WHERE usuario.id_usuario = idUsuarioVariable;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generarServicio` (IN `idClienteVariable` INT(11), IN `idAdminVariable` INT(11), IN `direccionVariable` VARCHAR(50), IN `tipoServicioVariable` VARCHAR(50), IN `horaInicioVariable` TIME, IN `descripcionVariable` TEXT, IN `adicionalVariable` INT(11))  NO SQL
BEGIN
	CALL addEncargadosAdmin(idAdminVariable,@idEncargados);
    CALL getIdDireccion(idClienteVariable,direccionVariable,@idDireccion);
    CALL getIdTipoServicio(tipoServicioVariable,@idTipoServicio);
    CALL getIdEstadoServicio("SIN_ASIGNAR",@idEstadoServicio);
    
    INSERT 
    INTO servicios(id_cliente,id_encargados,id_direcciones,id_tipoServicios,id_estadoServicio,descripcion,adicional)
    VALUES (idClienteVariable,@idEncargados,@idDireccion,@idTipoServicio,@idEstadoServicio,descripcionVariable,adicionalVariable);
    
   


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIdCredenciales` (IN `emailVariable` VARCHAR(50), IN `passwordVariable` VARCHAR(20), OUT `idCredenciales` INT(11))  NO SQL
BEGIN
	DECLARE existeCredenciales INT;
    
   INSERT into credenciales(credenciales.email,credenciales.password) VALUES(emailVariable,passwordVariable);
        SELECT LAST_INSERT_ID() into idCredenciales;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIdDate` (IN `fechaVariable` DATE, IN `horaInicioVariable` TIME, IN `horaFinalVariable` TIME, OUT `idDate` INT(15))  NO SQL
BEGIN
	DECLARE existeDate INT;
    SELECT  COUNT(mydate.id_date) INTO existeDate 
    FROM mydate 
    WHERE mydate.fecha = fechaVariable
    AND	mydate.horaInicio = horaInicioVariable
    AND mydate.horaFinal = horaFinalVariable; 
    
    IF existeDate > 0 THEN
    	SELECT mydate.id_date INTO idDate 
        FROM mydate 
    	WHERE mydate.fecha = fechaVariable
    	AND	mydate.horaInicio = horaInicioVariable
    	AND mydate.horaFinal = horaFinalVariable; 
    ELSE
    	INSERT into 
        mydate(mydate.fecha,mydate.horaInicio,mydate.horaFinal) 			VALUES(fechaVariable,horaInicioVariable,horaFinalVariable);
        SELECT LAST_INSERT_ID() into idDate;
    END IF;    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIdDireccion` (IN `idClienteVariable` INT(11), IN `direccionVariable` VARCHAR(50), OUT `idDireccionVariable` INT(11))  NO SQL
BEGIN
	DECLARE existeDireccion INT;
    SELECT  COUNT(direcciones.id_direcciones) INTO existeDireccion 
    FROM direcciones 
    WHERE direcciones.id_cliente = idClienteVariable
    AND   direcciones.direccion = direccionVariable; 
    
    IF existeDireccion > 0 THEN
    	SELECT direcciones.id_direcciones INTO idDireccionVariable
        FROM direcciones 
        WHERE direcciones.id_cliente = idClienteVariable
        AND   direcciones.direccion = direccionVariable;
    ELSE
    	INSERT 
        into direcciones(direcciones.id_cliente,direcciones.direccion)
        VALUES(idClienteVariable,direccionVariable);
        
        SELECT LAST_INSERT_ID() into idDireccionVariable;
    END IF;    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIdEstadoServicio` (IN `estadoVariable` VARCHAR(20), OUT `idEstado` INT(1))  NO SQL
BEGIN
	DECLARE existeEstado INT;
    SELECT  COUNT(estadoservicio.id_estadoServicio) 
    INTO existeEstado FROM estadoservicio 
    WHERE estadoservicio.estado  = estadoVariable; 
    
    IF existeEstado > 0 THEN
    	SELECT estadoservicio.id_estadoServicio 
        INTO idEstado FROM estadoservicio 
        WHERE estadoservicio.estado = estadoVariable; 
    ELSE
    	SET idEstado = 1;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIdEstadoUsuario` (IN `estadoVariable` VARCHAR(20), OUT `idEstado` INT(1))  NO SQL
    COMMENT 'retorna el ID de algun estadoUsuario, si no existe retorna 1.'
BEGIN
	DECLARE existeEstado INT;
    SELECT  COUNT(estadousuario.id_estadoUsuario) INTO existeEstado FROM estadousuario WHERE estadousuario.estado = estadoVariable; 
    
    IF existeEstado > 0 THEN
    	SELECT id_estadoUsuario INTO idEstado FROM estadousuario WHERE estadousuario.estado = estadoVariable; 
    ELSE
    	SET idEstado = 1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIdRol` (IN `rolVariable` VARCHAR(20), OUT `idRol` INT(1))  NO SQL
    COMMENT 'retorna el ID de algun Rol , si no existe retorna 3 ("USER").'
BEGIN
	DECLARE existeRol INT;
    SELECT  COUNT(rol.id_rol) INTO existeRol FROM rol WHERE rol = rolVariable; 
    
    IF existeRol > 0 THEN
    	SELECT rol.id_rol INTO idRol FROM rol WHERE rol = rolVariable; 
    ELSE
    	SET idRol = 3;
    END IF;    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIdTipoServicio` (IN `tipoServicioVariable` VARCHAR(50), OUT `idTipoServicio` INT(2))  NO SQL
BEGIN
	DECLARE existeTipoServicio INT;
    
    SELECT  COUNT(tiposervicios.id_tipoServicios) 
    INTO existeTipoServicio 
    FROM tiposervicios 
    WHERE tiposervicios.servicios = tipoServicioVariable; 
    
    IF existeTipoServicio > 0 THEN
    	SELECT tiposervicios.id_tipoServicios INTO idTipoServicio 
        FROM  tiposervicios 
        WHERE tiposervicios.servicios = tipoServicioVariable; 
    ELSE
    	SET idTipoServicio = 5;
    END IF;    
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIdTurno` (IN `nombreVariable` VARCHAR(50), OUT `idTurno` INT(1))  NO SQL
    COMMENT 'retorna el ID de algun turno, si no existe retorna 1.'
BEGIN
	DECLARE existeTurno INT;
    SELECT  COUNT(turno.id_turno) INTO existeTurno FROM turno WHERE turno.nombre = nombreVariable; 
    
    IF existeTurno > 0 THEN
    	SELECT turno.id_turno INTO idTurno FROM turno WHERE turno.nombre = nombreVariable; 
    ELSE
        SET idTurno = 1;
    END IF;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertDatosPersonales` (IN `nombreVariable` VARCHAR(50), IN `cedulaVariable` VARCHAR(10), IN `celularVariable` VARCHAR(11), IN `pathImageVariable` VARCHAR(255), OUT `idDatosPersonales` INT(11))  NO SQL
    COMMENT 'Return el ID de datosPersonales pasado por parámetro o lo crea.'
BEGIN
INSERT INTO
datospersonales(datospersonales.nombre,datospersonales.cedula,datospersonales.celular,datospersonales.pathImage) VALUES(nombreVariable,cedulaVariable,celularVariable,pathImageVariable);
SELECT LAST_INSERT_ID() INTO idDatosPersonales; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `loginCredenciales` (IN `emailVariable` VARCHAR(50), IN `passwordVariable` VARCHAR(20))  NO SQL
BEGIN

	DECLARE existeUsuario INT;
    
    SELECT  credenciales.id_credenciales INTO existeUsuario 
    FROM credenciales
    WHERE credenciales.email = emailVariable
    	AND credenciales.password = passwordVariable
    LIMIT 1; 
    
    IF existeUsuario > 0 THEN
    	
    	CALL getIdEstadoUsuario("HABILITADO",@idEstadoUsuario);
        
    	SELECT
    	usuario.id_usuario,
        rol.rol,
        credenciales.email,
        datospersonales.nombre,
        datospersonales.cedula,
        datospersonales.celular,
        datospersonales.pathImage,
        turno.nombre as nombreTurno,
        turno.horaInicio,
        turno.horaFinal,
        estadousuario.estado
    FROM usuario
   	INNER JOIN credenciales
    		ON usuario.id_credenciales = credenciales.id_credenciales
    INNER JOIN datospersonales
    		ON usuario.id_datosPersonales = datospersonales.id_datosPersonales
   	LEFT JOIN turno
    		ON usuario.id_turno = turno.id_turno
    INNER JOIN estadousuario
    		ON usuario.id_estadoUsuario = estadousuario.id_estadoUsuario
    INNER JOIN rol
    		ON usuario.id_rol = rol.id_rol
    WHERE usuario.id_credenciales = existeUsuario
    	AND usuario.id_estadoUsuario = @idEstadoUsuario;  
    END IF;  

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setIdCredenciales` (IN `idCredencialesVariable` INT(11), IN `emailVariable` VARCHAR(50), IN `passwordVariable` VARCHAR(20))  NO SQL
BEGIN
	
    UPDATE credenciales
    SET
    credenciales.email = emailVariable,
    credenciales.password = passwordVariable
    WHERE
    credenciales.id_credenciales = idCredencialesVariable;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setIdDatosPersonales` (IN `idDatosPersonalesVariable` INT(11), IN `nombreVariable` VARCHAR(50), IN `cedulaVariable` VARCHAR(10), IN `celularVariable` VARCHAR(11), IN `pathImageVariable` VARCHAR(255))  NO SQL
BEGIN
	UPDATE datospersonales
    SET 
    datospersonales.nombre = nombreVariable,
    datospersonales.cedula = cedulaVariable,
    datospersonales.celular = celularVariable,
    datospersonales.pathImage = pathImageVariable
    WHERE
    datospersonales.id_datosPersonales = idDatosPersonalesVariable;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `id_cliente` int(11) NOT NULL,
  `nombre` varchar(40) NOT NULL,
  `celular` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `cliente`:
--

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`id_cliente`, `nombre`, `celular`) VALUES
(4, 'Update Cliente 1', '3192030220');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `credenciales`
--

CREATE TABLE `credenciales` (
  `id_credenciales` int(11) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `credenciales`:
--

--
-- Volcado de datos para la tabla `credenciales`
--

INSERT INTO `credenciales` (`id_credenciales`, `email`, `password`) VALUES
(22, 'PRUEBAADMIN@GMAIL.COM', 'myPassword'),
(23, '2@GMAIL.COM', 'myPassword'),
(24, '3@GMAIL.COM', 'myPassword'),
(25, '4N@GMAIL.COM', 'myPassword'),
(26, 'ADMIN_1_@GMAIL.COM', 'myPassword'),
(27, 'ADMIN_2_@GMAIL.COM', 'myPassword'),
(28, 'SUPER_ADMIN@gmail.com', '123456');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datospersonales`
--

CREATE TABLE `datospersonales` (
  `id_datosPersonales` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `cedula` varchar(10) NOT NULL,
  `celular` varchar(11) NOT NULL,
  `pathImage` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `datospersonales`:
--

--
-- Volcado de datos para la tabla `datospersonales`
--

INSERT INTO `datospersonales` (`id_datosPersonales`, `nombre`, `cedula`, `celular`, `pathImage`) VALUES
(25, 'Insert Domiciliario', '34555666', '3143143145', '/image'),
(26, 'Insert Domiciliario 2', '123456', '3143143145', '/image'),
(27, 'Insert Domiciliario 3', '632541', '3143143145', '/image'),
(28, 'Insert Domiciliario 4', '56815', '3143143145', '/image'),
(29, 'Insert ADMIN 1', '12345655', '3143143145', '/image'),
(30, 'Insert ADMIN 2', '77777776', '3143143145', '/image'),
(31, 'SUPER ADMIN', '9999999999', '11111111111', '/image');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `direcciones`
--

CREATE TABLE `direcciones` (
  `id_direcciones` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `direccion` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `direcciones`:
--   `id_cliente`
--       `cliente` -> `id_cliente`
--

--
-- Volcado de datos para la tabla `direcciones`
--

INSERT INTO `direcciones` (`id_direcciones`, `id_cliente`, `direccion`) VALUES
(4, 4, 'Calle ####'),
(5, 4, 'calle 2'),
(6, 4, 'CALLE ');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `encargados`
--

CREATE TABLE `encargados` (
  `id_encargados` int(15) NOT NULL,
  `id_usuario_ADMIN` int(11) NOT NULL,
  `id_usuario_DOMICILIARIO` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `encargados`:
--   `id_usuario_ADMIN`
--       `usuario` -> `id_usuario`
--   `id_usuario_DOMICILIARIO`
--       `usuario` -> `id_usuario`
--

--
-- Volcado de datos para la tabla `encargados`
--

INSERT INTO `encargados` (`id_encargados`, `id_usuario_ADMIN`, `id_usuario_DOMICILIARIO`) VALUES
(21, 17, 14),
(22, 17, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estadoservicio`
--

CREATE TABLE `estadoservicio` (
  `id_estadoServicio` int(1) NOT NULL,
  `estado` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `estadoservicio`:
--

--
-- Volcado de datos para la tabla `estadoservicio`
--

INSERT INTO `estadoservicio` (`id_estadoServicio`, `estado`) VALUES
(1, 'SIN_ASIGNAR'),
(2, 'ASIGNADO'),
(3, 'COMPLETADO'),
(4, 'CANCELADO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estadousuario`
--

CREATE TABLE `estadousuario` (
  `id_estadoUsuario` int(11) NOT NULL,
  `estado` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `estadousuario`:
--

--
-- Volcado de datos para la tabla `estadousuario`
--

INSERT INTO `estadousuario` (`id_estadoUsuario`, `estado`) VALUES
(1, 'HABILITADO'),
(2, 'DESHABILITADO'),
(3, 'ELIMINADO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evidencia`
--

CREATE TABLE `evidencia` (
  `id_evidencia` int(15) NOT NULL,
  `id_servicios` int(15) NOT NULL,
  `path_evidencia` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `evidencia`:
--   `id_servicios`
--       `servicios` -> `id_servicios`
--

--
-- Volcado de datos para la tabla `evidencia`
--

INSERT INTO `evidencia` (`id_evidencia`, `id_servicios`, `path_evidencia`) VALUES
(1, 3, 'image/prueba1'),
(2, 3, 'image/prueba2'),
(3, 4, 'image/prueba5'),
(4, 4, 'image/prueba6');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mydate`
--

CREATE TABLE `mydate` (
  `id_date` int(15) NOT NULL,
  `fecha` date NOT NULL,
  `horaInicio` time NOT NULL,
  `horaFinal` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `mydate`:
--

--
-- Volcado de datos para la tabla `mydate`
--

INSERT INTO `mydate` (`id_date`, `fecha`, `horaInicio`, `horaFinal`) VALUES
(12, '2020-10-12', '20:00:00', '00:00:00'),
(13, '2020-10-13', '20:00:00', '21:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `id_rol` int(1) NOT NULL,
  `rol` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `rol`:
--

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`id_rol`, `rol`) VALUES
(1, 'SUPER_ADMIN'),
(2, 'ADMIN'),
(3, 'USER');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `servicios`
--

CREATE TABLE `servicios` (
  `id_servicios` int(15) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_encargados` int(11) NOT NULL,
  `id_direcciones` int(11) NOT NULL,
  `id_tipoServicios` int(2) NOT NULL,
  `id_date` int(15) NOT NULL,
  `id_estadoServicio` int(1) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `adicional` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `servicios`:
--   `id_cliente`
--       `cliente` -> `id_cliente`
--   `id_encargados`
--       `encargados` -> `id_encargados`
--   `id_direcciones`
--       `direcciones` -> `id_direcciones`
--   `id_tipoServicios`
--       `tiposervicios` -> `id_tipoServicios`
--   `id_date`
--       `mydate` -> `id_date`
--   `id_estadoServicio`
--       `estadoservicio` -> `id_estadoServicio`
--

--
-- Volcado de datos para la tabla `servicios`
--

INSERT INTO `servicios` (`id_servicios`, `id_cliente`, `id_encargados`, `id_direcciones`, `id_tipoServicios`, `id_date`, `id_estadoServicio`, `descripcion`, `adicional`) VALUES
(3, 4, 21, 6, 2, 13, 3, 'Esto es una prueba', 5200),
(4, 4, 22, 6, 4, 12, 1, 'Esto es una prueba', 5200);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tiposervicios`
--

CREATE TABLE `tiposervicios` (
  `id_tipoServicios` int(2) NOT NULL,
  `servicios` varchar(50) NOT NULL,
  `valor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `tiposervicios`:
--

--
-- Volcado de datos para la tabla `tiposervicios`
--

INSERT INTO `tiposervicios` (`id_tipoServicios`, `servicios`, `valor`) VALUES
(1, 'Domicilio Comida', 5000),
(2, 'Vuelta Banco', 7000),
(3, 'Pagos Facturas y Servicios Publicos', 5000),
(4, 'Punto a Punto', 8000),
(5, 'Domicilio Otro', 5000);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `turno`
--

CREATE TABLE `turno` (
  `id_turno` int(1) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `horaInicio` time NOT NULL,
  `horaFinal` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `turno`:
--

--
-- Volcado de datos para la tabla `turno`
--

INSERT INTO `turno` (`id_turno`, `nombre`, `horaInicio`, `horaFinal`) VALUES
(1, 'A', '05:00:00', '16:59:59'),
(2, 'B', '17:00:00', '04:59:59');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `id_estadoUsuario` int(1) NOT NULL,
  `id_datosPersonales` int(11) NOT NULL,
  `id_credenciales` int(11) NOT NULL,
  `id_turno` int(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `usuario`:
--   `id_rol`
--       `rol` -> `id_rol`
--   `id_estadoUsuario`
--       `estadousuario` -> `id_estadoUsuario`
--   `id_credenciales`
--       `credenciales` -> `id_credenciales`
--   `id_turno`
--       `turno` -> `id_turno`
--   `id_datosPersonales`
--       `datospersonales` -> `id_datosPersonales`
--

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `id_rol`, `id_estadoUsuario`, `id_datosPersonales`, `id_credenciales`, `id_turno`) VALUES
(13, 3, 1, 25, 22, 1),
(14, 3, 1, 26, 23, 1),
(15, 3, 1, 27, 24, 1),
(16, 3, 1, 28, 25, 1),
(17, 2, 1, 29, 26, NULL),
(18, 2, 1, 30, 27, NULL),
(19, 1, 1, 31, 28, NULL);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id_cliente`);

--
-- Indices de la tabla `credenciales`
--
ALTER TABLE `credenciales`
  ADD PRIMARY KEY (`id_credenciales`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `datospersonales`
--
ALTER TABLE `datospersonales`
  ADD PRIMARY KEY (`id_datosPersonales`),
  ADD UNIQUE KEY `cedula` (`cedula`);

--
-- Indices de la tabla `direcciones`
--
ALTER TABLE `direcciones`
  ADD PRIMARY KEY (`id_direcciones`),
  ADD KEY `id_cliente` (`id_cliente`);

--
-- Indices de la tabla `encargados`
--
ALTER TABLE `encargados`
  ADD PRIMARY KEY (`id_encargados`),
  ADD KEY `id_usuario_ADMIN` (`id_usuario_ADMIN`),
  ADD KEY `id_usuario_DOMICILIARIO` (`id_usuario_DOMICILIARIO`);

--
-- Indices de la tabla `estadoservicio`
--
ALTER TABLE `estadoservicio`
  ADD PRIMARY KEY (`id_estadoServicio`);

--
-- Indices de la tabla `estadousuario`
--
ALTER TABLE `estadousuario`
  ADD PRIMARY KEY (`id_estadoUsuario`);

--
-- Indices de la tabla `evidencia`
--
ALTER TABLE `evidencia`
  ADD PRIMARY KEY (`id_evidencia`),
  ADD KEY `id_servicios` (`id_servicios`);

--
-- Indices de la tabla `mydate`
--
ALTER TABLE `mydate`
  ADD PRIMARY KEY (`id_date`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`);

--
-- Indices de la tabla `servicios`
--
ALTER TABLE `servicios`
  ADD PRIMARY KEY (`id_servicios`),
  ADD KEY `id_cliente` (`id_cliente`),
  ADD KEY `id_encargados` (`id_encargados`),
  ADD KEY `id_direcciones` (`id_direcciones`),
  ADD KEY `id_tipoServicios` (`id_tipoServicios`),
  ADD KEY `id_date` (`id_date`),
  ADD KEY `id_estadoServicio` (`id_estadoServicio`);

--
-- Indices de la tabla `tiposervicios`
--
ALTER TABLE `tiposervicios`
  ADD PRIMARY KEY (`id_tipoServicios`);

--
-- Indices de la tabla `turno`
--
ALTER TABLE `turno`
  ADD PRIMARY KEY (`id_turno`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD KEY `id_rol` (`id_rol`),
  ADD KEY `id_estadoUsuario` (`id_estadoUsuario`),
  ADD KEY `id_credenciales` (`id_credenciales`),
  ADD KEY `id_turno` (`id_turno`),
  ADD KEY `id_datosPersonales` (`id_datosPersonales`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `credenciales`
--
ALTER TABLE `credenciales`
  MODIFY `id_credenciales` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT de la tabla `datospersonales`
--
ALTER TABLE `datospersonales`
  MODIFY `id_datosPersonales` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT de la tabla `direcciones`
--
ALTER TABLE `direcciones`
  MODIFY `id_direcciones` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `encargados`
--
ALTER TABLE `encargados`
  MODIFY `id_encargados` int(15) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `estadoservicio`
--
ALTER TABLE `estadoservicio`
  MODIFY `id_estadoServicio` int(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `estadousuario`
--
ALTER TABLE `estadousuario`
  MODIFY `id_estadoUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `evidencia`
--
ALTER TABLE `evidencia`
  MODIFY `id_evidencia` int(15) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `mydate`
--
ALTER TABLE `mydate`
  MODIFY `id_date` int(15) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `servicios`
--
ALTER TABLE `servicios`
  MODIFY `id_servicios` int(15) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tiposervicios`
--
ALTER TABLE `tiposervicios`
  MODIFY `id_tipoServicios` int(2) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `turno`
--
ALTER TABLE `turno`
  MODIFY `id_turno` int(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `direcciones`
--
ALTER TABLE `direcciones`
  ADD CONSTRAINT `direcciones_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`);

--
-- Filtros para la tabla `encargados`
--
ALTER TABLE `encargados`
  ADD CONSTRAINT `encargados_ibfk_1` FOREIGN KEY (`id_usuario_ADMIN`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `encargados_ibfk_2` FOREIGN KEY (`id_usuario_DOMICILIARIO`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `evidencia`
--
ALTER TABLE `evidencia`
  ADD CONSTRAINT `evidencia_ibfk_1` FOREIGN KEY (`id_servicios`) REFERENCES `servicios` (`id_servicios`);

--
-- Filtros para la tabla `servicios`
--
ALTER TABLE `servicios`
  ADD CONSTRAINT `servicios_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`),
  ADD CONSTRAINT `servicios_ibfk_2` FOREIGN KEY (`id_encargados`) REFERENCES `encargados` (`id_encargados`),
  ADD CONSTRAINT `servicios_ibfk_3` FOREIGN KEY (`id_direcciones`) REFERENCES `direcciones` (`id_direcciones`),
  ADD CONSTRAINT `servicios_ibfk_4` FOREIGN KEY (`id_tipoServicios`) REFERENCES `tiposervicios` (`id_tipoServicios`),
  ADD CONSTRAINT `servicios_ibfk_5` FOREIGN KEY (`id_date`) REFERENCES `mydate` (`id_date`),
  ADD CONSTRAINT `servicios_ibfk_6` FOREIGN KEY (`id_estadoServicio`) REFERENCES `estadoservicio` (`id_estadoServicio`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`),
  ADD CONSTRAINT `usuario_ibfk_2` FOREIGN KEY (`id_estadoUsuario`) REFERENCES `estadousuario` (`id_estadoUsuario`),
  ADD CONSTRAINT `usuario_ibfk_4` FOREIGN KEY (`id_credenciales`) REFERENCES `credenciales` (`id_credenciales`),
  ADD CONSTRAINT `usuario_ibfk_5` FOREIGN KEY (`id_turno`) REFERENCES `turno` (`id_turno`),
  ADD CONSTRAINT `usuario_ibfk_6` FOREIGN KEY (`id_datosPersonales`) REFERENCES `datospersonales` (`id_datosPersonales`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
