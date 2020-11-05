-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 06-11-2020 a las 00:05:43
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `aceptarServicio` (IN `idServicioVariable` INT(15), IN `idDomiciliarioVariable` INT(11))  NO SQL
BEGIN
	DECLARE idEncargadoServicio INT;
   	DECLARE fechaServicio DATE;
    
    SELECT servicios.id_encargados INTO idEncargadoServicio
    FROM servicios 
    WHERE servicios.id_servicios = idServicioVariable;
    
	CALL
addEncargadosDomiciliario(idEncargadoServicio,idDomiciliarioVariable,@idEncargados);
	
    SELECT mydate.fecha
    INTO fechaServicio
    FROM servicios
    INNER JOIN mydate
       ON servicios.id_date = mydate.id_date
    WHERE servicios.id_servicios = idServicioVariable;
    
    CALL getIdDate(fechaServicio,DATE_FORMAT(NOW( ),"%H:%i:%S"),"00:00:00",@idDate);
    
	CALL getIdEstadoServicio("ASIGNADO",@idEstadoServicio);
UPDATE servicios
    SET servicios.id_encargados = @idEncargados,
    	servicios.id_estadoServicio = @idEstadoServicio,
        servicios.id_date = @idDate
    WHERE servicios.id_servicios = idServicioVariable;

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarCliente` (IN `idClienteVariable` INT(11), IN `nombreVariable` VARCHAR(40), IN `celularVariable` VARCHAR(10), IN `direccionVariable` VARCHAR(50))  NO SQL
BEGIN
	 CALL getIdDireccion(idClienteVariable,direccionVariable,@idDireccion);
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarTipoServicios` (IN `idTipoServicios` INT(11), IN `nombreVariable` VARCHAR(50), IN `precioVariable` INT(11))  NO SQL
BEGIN

	DECLARE existeRelacionServicios INT;
    DECLARE existeTipoServicio INT;
    
    SELECT
	COUNT(servicios.id_servicios) INTO existeRelacionServicios 
    FROM servicios
    WHERE servicios.id_tipoServicios = idTipoServicios;
    
    -- preguntamos si este tipo de servicio a editar tiene relacion
    -- con la tabla `servicios`, si es asi entonces procedemos a 
    -- editarla completamente. De lo contrario este registo se cambiara
    -- de estado a "ELIMINADO", con el objetivo de no borrar el historial 
    -- en la tabla "SERVICIOS" y procedemos a crear una nuevo registro 
    -- con estos datos.
    
    IF existeRelacionServicios > 0 THEN
    
    	CALL getIdEstadoTipoServicios("ELIMINADO",@idEstadoTipoServicios);
        
        UPDATE tiposervicios
        SET tiposervicios.id_estadoTipoServicios = @idEstadoTipoServicios
        WHERE tiposervicios.id_tipoServicios = idTipoServicios;
        
        CALL agregarTipoServicios(nombreVariable,precioVariable);
        
    ELSE
    	
        SELECT  COUNT(tiposervicios.id_tipoServicios) 
        INTO existeTipoServicio 
        FROM tiposervicios 
        WHERE tiposervicios.servicios = nombreVariable
            AND tiposervicios.valor = precioVariable;

        IF existeTipoServicio > 0 THEN
        	CALL getIdEstadoTipoServicios("DISPONIBLE",@idEstadoTipoServicios);
        
            SELECT tiposervicios.id_tipoServicios
            INTO existeTipoServicio 
            FROM tiposervicios 
            WHERE tiposervicios.servicios = nombreVariable
                AND tiposervicios.valor = precioVariable
            LIMIT 1;
            
            UPDATE tiposervicios
            SET 
            tiposervicios.id_estadoTipoServicios = @idEstadoTipoServicios
            WHERE tiposervicios.id_tipoServicios = existeTipoServicio;
            
        
            DELETE 
            FROM tiposervicios
            WHERE tiposervicios.id_tipoServicios = idTipoServicios;
            
        ELSE
            UPDATE tiposervicios
            SET tiposervicios.servicios = nombreVariable,
                tiposervicios.valor = precioVariable
            WHERE tiposervicios.id_tipoServicios = idTipoServicios;
        END IF; 
        
    END IF;

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `agregarTipoServicios` (IN `tipoServicioVariable` VARCHAR(50), IN `valorVariable` INT(11))  NO SQL
BEGIN
	DECLARE existeTipoServicio INT;
    
    SELECT  COUNT(tiposervicios.id_tipoServicios) 
    INTO existeTipoServicio 
    FROM tiposervicios 
    WHERE tiposervicios.servicios = tipoServicioVariable
    	AND tiposervicios.valor = valorVariable; 
    
    IF existeTipoServicio > 0 THEN
    
   		 CALL getIdEstadoTipoServicios("DISPONIBLE",@idEstadoTipoServicios);
    
     	SELECT  COUNT(tiposervicios.id_tipoServicios) 
    	INTO existeTipoServicio 
    	FROM tiposervicios 
    	WHERE tiposervicios.servicios = tipoServicioVariable
    	AND tiposervicios.valor = valorVariable
        AND tiposervicios.id_estadoTipoServicios = @idEstadoTipoServicios;
        
        IF  existeTipoServicio < 1 THEN

        	CALL getIdTipoServicio(tipoServicioVariable,valorVariable,@idTipoServicio);
        	
            UPDATE tiposervicios
            SET tiposervicios.id_estadoTipoServicios =  @idEstadoTipoServicios
            WHERE tiposervicios.id_tipoServicios = @idTipoServicio;
        	
        END IF;
        
    	
    ELSE
    	CALL getIdEstadoTipoServicios("DISPONIBLE",@idEstadoTipoServicios);
        
    	INSERT 
        into tiposervicios(id_estadoTipoServicios, servicios, valor) 
       VALUES(@idEstadoTipoServicios,tipoServicioVariable,valorVariable);
        
    END IF;    
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancelarServicio` (IN `idServicioVariable` INT(15))  NO SQL
BEGIN
	CALL getIdEstadoServicio("CANCELADO",@idEstadoServicio);
    
	UPDATE servicios
    SET servicios.id_estadoServicio = @idEstadoServicio
    WHERE servicios.id_servicios = idServicioVariable;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `concluirServicio` (IN `idServicioVariable` INT(15))  NO SQL
BEGIN
	DECLARE fechaServicio DATE;
    DECLARE horaInicioServicio TIME;
    DECLARE horaFinalServicio TIME;
    
     SELECT mydate.fecha
    INTO fechaServicio
    FROM servicios
    INNER JOIN mydate
       ON servicios.id_date = mydate.id_date
    WHERE servicios.id_servicios = idServicioVariable;
    
     SELECT mydate.horaInicio
    INTO horaInicioServicio
    FROM servicios
    INNER JOIN mydate
       ON servicios.id_date = mydate.id_date
    WHERE servicios.id_servicios = idServicioVariable;
    
	CALL getIdDate(fechaServicio,horaInicioServicio,DATE_FORMAT(NOW( ),"%H:%i:%S"),@idDate);
    CALL getIdEstadoServicio("COMPLETADO",@idEstadoServicio);
    
    UPDATE servicios
    SET	servicios.id_estadoServicio = @idEstadoServicio,
        servicios.id_date = @idDate
    WHERE servicios.id_servicios = idServicioVariable;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarAdmins` ()  NO SQL
BEGIN
CALL getIdRol("ADMIN",@idRol);
CALL getIdEstadoUsuario("ELIMINADO",@idEstadoUsuario);
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
    WHERE usuario.id_rol = @idRol
    	AND	usuario.id_estadoUsuario != @idEstadoUsuario;  

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarClientes` ()  NO SQL
BEGIN

    SELECT 
        cliente.nombre,
        cliente.celular,
        COUNT(servicios.id_servicios) as serviciosBrindados,
        cliente.id_cliente
    FROM
        cliente
    LEFT JOIN servicios
                ON cliente.id_cliente = servicios.id_cliente AND servicios.id_estadoServicio = 3
    GROUP BY cliente.id_cliente;

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
CALL getIdEstadoUsuario("ELIMINADO",@idEstadoUsuario);
SELECT	
		datospersonales.nombre,
        credenciales.email,
        datospersonales.cedula,
        datospersonales.celular,
        turno.nombre as nombreTurno,
        estadousuario.estado,
        datospersonales.pathImage,
        usuario.id_usuario
    FROM usuario
   	INNER JOIN credenciales
    		ON usuario.id_credenciales = credenciales.id_credenciales
    INNER JOIN datospersonales
    		ON usuario.id_datosPersonales = datospersonales.id_datosPersonales
    INNER JOIN turno
    		ON usuario.id_turno = turno.id_turno
    INNER JOIN estadousuario
    		ON usuario.id_estadoUsuario = estadousuario.id_estadoUsuario
    WHERE usuario.id_rol = @idRol 
		AND	usuario.id_estadoUsuario != @idEstadoUsuario;  
        
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarEstadisticasGananciaMes` ()  NO SQL
BEGIN
SET lc_time_names = 'es_CO';
SELECT
    DATE_FORMAT(mydate.fecha,"%a") AS dia,
    SUM(tiposervicios.valor+servicios.adicional) as gananciaServicios
FROM servicios 
INNER JOIN mydate
			ON servicios.id_date = mydate.id_date   
INNER JOIN tiposervicios
			ON servicios.id_tipoServicios = tiposervicios.id_tipoServicios
WHERE servicios.id_estadoServicio = 3 AND  mydate.fecha BETWEEN DATE_FORMAT(now(),'%Y-%m-01')  AND LAST_DAY(DATE_FORMAT(now(),'%Y-%m-01'))
GROUP BY DATE_FORMAT(mydate.fecha,"%a");
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarEstadisticasVentasMes` ()  NO SQL
BEGIN
SET lc_time_names = 'es_CO';
SELECT
    MonthName(mydate.fecha) AS mes,
    COUNT(servicios.id_servicios) as cantidadServicios
FROM servicios 
INNER JOIN mydate
			ON servicios.id_date = mydate.id_date   
WHERE servicios.id_estadoServicio = 3 AND year(mydate.fecha) = year(curdate())
GROUP BY MonthName(mydate.fecha)
LIMIT 6;

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
    mydate.horaFinal AS horaFinal,
    cliente.celular as celularCliente
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarServiciosCliente` (IN `idClienteVariable` INT)  NO SQL
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
    mydate.horaFinal AS horaFinal,
    cliente.celular as celularCliente
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
        WHERE cliente.id_cliente = idClienteVariable;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarServiciosDia` (IN `fechaVariable` DATE)  NO SQL
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
    mydate.horaFinal AS horaFinal,
    cliente.celular as celularCliente
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
        WHERE mydate.fecha = fechaVariable;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarServiciosDomiciliario` (IN `idDomiciliarioVariable` INT(11), IN `desdeVariable` DATE, IN `hastaVariable` DATE)  NO SQL
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
    mydate.horaFinal AS horaFinal,
    cliente.celular as celularCliente
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
            WHERE myUserEncargado.id_usuario= idDomiciliarioVariable
            AND mydate.fecha BETWEEN CAST(desdeVariable AS DATE) AND CAST(hastaVariable AS DATE);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarServiciosTemporal` (IN `desdeVariable` DATE, IN `hastaVariable` DATE)  NO SQL
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
    mydate.horaFinal AS horaFinal,
    cliente.celular as celularCliente
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
       WHERE mydate.fecha
       BETWEEN CAST(desdeVariable AS DATE) AND CAST(hastaVariable AS DATE); 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarServicios_ASIGNADO` ()  NO SQL
BEGIN

SELECT
	servicios.id_servicios,
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
    mydate.horaFinal AS horaFinal,
    cliente.celular as celularCliente,
    myAdmin.pathImage as pathImageAdmin,
    encargados.id_usuario_DOMICILIARIO as id_domiciliario
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
WHERE estadoservicio.estado ="ASIGNADO";

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarServicios_enPROCESO` ()  NO SQL
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
    mydate.horaFinal AS horaFinal,
    cliente.celular as celularCliente,
    myAdmin.pathImage as pathImageAdmin
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
WHERE estadoservicio.estado ="SIN_ASIGNAR"
	OR estadoservicio.estado ="ASIGNADO";

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarServicios_SINASIGNAR` ()  NO SQL
BEGIN

SELECT
	servicios.id_servicios,
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
    mydate.horaFinal AS horaFinal,
    cliente.celular as celularCliente,
    myAdmin.pathImage as pathImageAdmin
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarTipoServicios` ()  NO SQL
BEGIN

    CALL getIdEstadoTipoServicios("DISPONIBLE",@idEstadoTipoServicios);
    SELECT
        *
    FROM tiposervicios
    WHERE tiposervicios.id_estadoTipoServicios = @idEstadoTipoServicios;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarTopDomiciliariosMes` ()  NO SQL
BEGIN

SELECT
    datospersonales.nombre as nombre,
    datospersonales.pathImage as pathImage,
    credenciales.email AS correo,
    COUNT(servicios.id_servicios) AS totalServicios,
    SUM(tiposervicios.valor+servicios.adicional) as totalGanancias
FROM servicios 
INNER JOIN mydate
			ON servicios.id_date = mydate.id_date   
INNER JOIN tiposervicios
			ON servicios.id_tipoServicios = tiposervicios.id_tipoServicios
INNER JOIN encargados
			ON servicios.id_encargados = encargados.id_encargados
INNER JOIN usuario as domiciliario
			on encargados.id_usuario_DOMICILIARIO = domiciliario.id_usuario
INNER JOIN datospersonales
			on datospersonales.id_datosPersonales = domiciliario.id_datosPersonales
INNER JOIN credenciales
			ON credenciales.id_credenciales = domiciliario.id_credenciales
WHERE servicios.id_estadoServicio = 3 AND  mydate.fecha BETWEEN DATE_FORMAT(now(),'%Y-%m-01')  AND LAST_DAY(DATE_FORMAT(now(),'%Y-%m-01'))
GROUP BY  credenciales.email
ORDER BY SUM(tiposervicios.valor+servicios.adicional) DESC
LIMIT 4;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminarTipoServicios` (IN `idTipoServiciosVariable` INT(2))  NO SQL
BEGIN

	 CALL getIdEstadoTipoServicios("ELIMINADO",@idEstadoTipoServicios);
   	UPDATE tiposervicios
    SET tiposervicios.id_estadoTipoServicios = @idEstadoTipoServicios
    WHERE tiposervicios.id_tipoServicios = idTipoServiciosVariable;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminarUsuario` (IN `idUsuarioVariable` INT(11))  NO SQL
    COMMENT 'Se cambia el estado a "ELIMINADO" al usuario mediante ID.'
BEGIN
	CALL getIdEstadoUsuario("ELIMINADO",@idEstadoUsuario);
	UPDATE usuario
    SET usuario.id_estadoUsuario = @idEstadoUsuario
    WHERE usuario.id_usuario = idUsuarioVariable;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generarServicio` (IN `idClienteVariable` INT(11), IN `idAdminVariable` INT(11), IN `direccionVariable` VARCHAR(50), IN `tipoServicioVariable` VARCHAR(50), IN `valorVariable` INT(11), IN `descripcionVariable` TEXT, IN `adicionalVariable` INT(11))  NO SQL
BEGIN
	CALL addEncargadosAdmin(idAdminVariable,@idEncargados);
    CALL getIdDireccion(idClienteVariable,direccionVariable,@idDireccion);
    CALL getIdTipoServicio(tipoServicioVariable,valorVariable,@idTipoServicio);
    CALL getIdEstadoServicio("SIN_ASIGNAR",@idEstadoServicio);
    CALL getIdDate(CURDATE(),"00:00:00","00:00:00",@idDate);
    
    INSERT 
    INTO servicios(id_cliente,id_encargados,id_direcciones,id_tipoServicios,id_date,id_estadoServicio,descripcion,adicional)
    VALUES (idClienteVariable,@idEncargados,@idDireccion,@idTipoServicio,@idDate,@idEstadoServicio,descripcionVariable,adicionalVariable);
     SELECT LAST_INSERT_ID() AS idServicio;
    
    
   


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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIdEstadoTipoServicios` (IN `estadoVariable` VARCHAR(50), OUT `idEstado` INT(1))  NO SQL
BEGIN
	DECLARE existeEstado INT;
    SELECT  COUNT(estadotiposervicios.id_estadoTipoServicios) 
    INTO existeEstado FROM estadotiposervicios
    WHERE estadotiposervicios.estado  = estadoVariable; 
    
    IF existeEstado > 0 THEN
    	SELECT estadotiposervicios.id_estadoTipoServicios 
        INTO idEstado FROM estadotiposervicios
        WHERE estadotiposervicios.estado= estadoVariable; 
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIdTipoServicio` (IN `tipoServicioVariable` VARCHAR(50), IN `valorVariable` INT(11), OUT `idTipoServicio` INT(2))  NO SQL
BEGIN
	DECLARE existeTipoServicio INT;
    
    SELECT  COUNT(tiposervicios.id_tipoServicios) 
    INTO existeTipoServicio 
    FROM tiposervicios 
    WHERE tiposervicios.servicios = tipoServicioVariable
    	AND tiposervicios.valor = valorVariable;
    
    IF existeTipoServicio > 0 THEN
    	SELECT tiposervicios.id_tipoServicios INTO idTipoServicio 
        FROM  tiposervicios 
        WHERE tiposervicios.servicios = tipoServicioVariable
        	AND tiposervicios.valor = valorVariable;
    ELSE
    	SIGNAL SQLSTATE '11760' SET MESSAGE_TEXT = 'No Existe Tipo de Servicio';
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `totalServicios` (IN `estadoVariable` VARCHAR(50))  NO SQL
BEGIN
	SELECT
	COUNT(servicios.id_servicios) as total
FROM servicios
INNER JOIN estadoservicio
	ON servicios.id_estadoServicio = estadoservicio.id_estadoServicio
WHERE estadoservicio.estado = estadoVariable;

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
(4, 'cliente 1', '3192030220'),
(5, 'Cliente 2', '311222333'),
(6, 'Cliente 3', '322333444'),
(7, 'Prueba exitosa Cliente', '2'),
(8, 'Sergio Aparicio Hernandez', '1007733234'),
(9, 'Prueba exitosa Cliente', '3'),
(10, ' Actualizado', '7777'),
(11, 'terminamos los clientes', '9999999999');

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
(22, 'domiciliario111@GMAIL.COM', 'myPassword'),
(23, '2@GMAIL.COM', 'myPassword'),
(24, '3@GMAIL.COM', 'myPassword'),
(25, '4N@GMAIL.COM', 'myPassword'),
(26, 'ADMIN_1_@GMAIL.COM', 'myPassword'),
(27, 'ADMIN_2_@GMAIL.COM', 'myPassword'),
(28, 'SUPER_ADMIN@gmail.com', '123456'),
(29, 'sergiomauriciop111@gmail.com', '1007733234'),
(30, 'norageraldi@hotmail.com', '37556195'),
(31, 'sergiopro@ddd', '3'),
(32, 'ssffs@gmail.com', '54646'),
(33, 'wfwfe@gmail.comm', '333'),
(34, 'ege18@gmail.com', '9'),
(35, 'pruebafinal@hotmail.com', '31468588'),
(36, 'Richard@hotmail.com', '234'),
(43, 'admin_4_@gmail.com', '123456789'),
(44, 'admin_5_@gmail.com', '8888888'),
(45, 'admin_6_@gmail.com', '95251'),
(46, 'eegomiegni@gmail.com', '815118'),
(47, 'richarddd@hotmail.com', '121211');

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
(25, 'Insert Domiciliario', '34555666', '3143143145', 'domiciliario/defaultUser.png'),
(26, ' Domiciliario 2', '123456', '3143143145', 'domiciliario/3d39a37a-f5ef-4b47-b4a5-4d1a7160ad0e.jpg'),
(27, 'Domiciliario 3 actualizado', '632541', '3143143145', 'domiciliario/1b7dd5e7-1188-4fe9-a4b2-0e070fdb6e8b.webp'),
(28, 'Insert Domiciliario 4', '56815', '3143143145', 'domiciliario/defaultUser.png'),
(29, 'Insert ADMIN 1', '12345655', '3143143145', 'admin/defaultAdmin.png'),
(30, 'Insert ADMIN 2', '77777776', '3143143145', 'admin/defaultAdmin.png'),
(31, 'SUPER ADMIN', '9999999999', '11111111111', '/superAdmin/defaultSuperAdmin.png'),
(32, 'sergio', '1007733234', '3142483968', 'fc32de75-7ab8-40b6-9907-6baff13bc640.jpg'),
(34, 'nora', '37556195', '3142483968', 'domiciliario/aa58c769-a5d4-4c76-8e38-5b3854639505.jpg'),
(35, 'Prueba exitosa Domiciliario', '3', '3', 'domiciliario/dd1ad4a7-27f1-4ec9-baae-2eff3342632f.jfif'),
(36, 'hola 1 ', '54646', '464646', 'domiciliario/defaultAdmin.png'),
(37, 'fefefef', '333', '5353535', 'domiciliario/e85c3daf-50b8-466d-a99d-635c302f8dc7.jpeg'),
(38, 'rgree', '9', '11', 'domiciliario/defaultUser.png'),
(39, 'prueba final', '31468588', '518588', 'domiciliario/defaultUser.png'),
(40, 'admin 3', '234', '333', 'admin/defaultAdmin.png'),
(43, 'Admin 4', '123456789', '32165452', 'admin/defaultAdmin.png'),
(44, 'Admin 5', '8888888', '8888888', 'admin/8f7718e5-d47c-40e6-bae7-34b37f359b9f.jfif'),
(45, 'admin 6', '95251', '5821', 'admin/a0746194-093c-44b5-8d37-e2a245b42b45.jpeg'),
(46, 'prueba final', '815118', '415151', 'admin/defaultAdmin.png'),
(47, 'richardadmin@homail.com', '121211', '4156', 'admin/bd89bceb-fb42-4d8c-8661-6f9d35a02372.jpg');

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
(6, 4, 'CALLE '),
(7, 5, 'CALLE 2'),
(8, 7, 'Calle nueva exitosa'),
(9, 8, ''),
(10, 9, 'wd'),
(11, 10, 'ssss'),
(12, 10, 'ssss Actualizado'),
(13, 10, 'jijij calle'),
(14, 8, 'hola'),
(15, 11, 'calle terminada '),
(16, 8, 'calle 61 #35 - 09'),
(17, 4, 'CALLE 3'),
(18, 6, 'Calla 6666');

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
(22, 17, 15),
(23, 18, NULL),
(24, 18, NULL),
(25, 18, 16),
(26, 17, NULL),
(27, 17, NULL),
(28, 17, NULL),
(29, 17, 13),
(30, 17, NULL),
(31, 17, 16),
(32, 17, NULL),
(33, 17, NULL),
(34, 17, NULL),
(35, 17, NULL),
(36, 17, NULL),
(37, 17, NULL),
(38, 17, NULL),
(39, 17, NULL),
(40, 17, NULL),
(41, 17, NULL),
(42, 17, NULL),
(43, 17, NULL),
(44, 17, NULL),
(45, 17, NULL),
(46, 17, NULL),
(47, 17, NULL),
(48, 17, NULL),
(49, 17, NULL),
(50, 17, NULL),
(51, 17, NULL),
(52, 17, NULL),
(53, 17, NULL),
(54, 17, NULL),
(55, 17, NULL),
(56, 17, NULL),
(57, 17, NULL),
(58, 17, NULL),
(59, 17, NULL),
(60, 17, NULL),
(61, 17, NULL),
(62, 17, NULL),
(63, 17, NULL),
(64, 17, NULL),
(65, 17, NULL),
(66, 17, NULL),
(67, 17, NULL),
(68, 17, NULL),
(69, 17, NULL),
(70, 17, NULL),
(71, 17, NULL),
(72, 17, NULL),
(73, 17, NULL),
(74, 17, NULL),
(75, 17, NULL),
(76, 17, NULL),
(77, 17, NULL),
(78, 17, NULL),
(79, 17, NULL),
(80, 17, NULL),
(81, 17, NULL),
(82, 17, NULL),
(83, 17, NULL),
(84, 17, NULL),
(85, 17, NULL),
(86, 17, NULL),
(87, 17, NULL),
(88, 17, NULL),
(89, 17, NULL),
(90, 17, NULL),
(91, 17, NULL),
(92, 17, NULL),
(93, 17, NULL),
(94, 17, NULL),
(95, 17, NULL),
(96, 17, NULL),
(97, 17, NULL),
(98, 17, NULL),
(99, 17, NULL),
(100, 17, NULL),
(101, 17, NULL),
(102, 17, NULL),
(103, 17, NULL),
(104, 17, NULL),
(105, 17, NULL),
(106, 17, NULL),
(107, 17, NULL),
(108, 17, NULL),
(109, 17, NULL),
(110, 17, NULL),
(111, 17, NULL),
(112, 17, NULL),
(113, 17, NULL),
(114, 17, NULL),
(115, 17, NULL),
(116, 17, NULL),
(117, 17, NULL),
(118, 17, NULL),
(119, 17, NULL),
(120, 17, NULL),
(121, 17, NULL),
(122, 17, NULL),
(123, 17, NULL),
(124, 17, NULL),
(125, 17, NULL),
(126, 17, NULL),
(127, 17, NULL),
(128, 17, NULL),
(129, 17, NULL),
(130, 17, NULL),
(131, 17, NULL),
(132, 17, NULL),
(133, 17, NULL),
(134, 17, NULL),
(135, 17, NULL),
(136, 17, NULL),
(137, 17, NULL),
(138, 17, NULL),
(139, 17, NULL),
(140, 17, NULL),
(141, 17, NULL);

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
-- Estructura de tabla para la tabla `estadotiposervicios`
--

CREATE TABLE `estadotiposervicios` (
  `id_estadoTipoServicios` int(1) NOT NULL,
  `estado` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `estadotiposervicios`:
--

--
-- Volcado de datos para la tabla `estadotiposervicios`
--

INSERT INTO `estadotiposervicios` (`id_estadoTipoServicios`, `estado`) VALUES
(1, 'DISPONIBLE'),
(2, 'ELIMINADO');

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
(13, '2020-10-13', '20:00:00', '21:00:00'),
(14, '2020-10-15', '07:00:00', '00:00:00'),
(15, '2020-10-15', '07:00:00', '21:00:00'),
(16, '2020-10-15', '00:00:00', '00:00:00'),
(17, '2020-10-15', '08:55:00', '00:00:00'),
(18, '2020-10-21', '08:55:00', '09:30:00'),
(19, '2020-10-21', '00:00:00', '00:00:00'),
(20, '2020-10-21', '13:05:38', '00:00:00'),
(21, '2020-10-21', '13:05:38', '13:11:03'),
(22, '2020-10-22', '00:00:00', '00:00:00'),
(23, '2020-10-22', '10:06:12', '00:00:00'),
(24, '2020-10-28', '00:00:00', '00:00:00'),
(25, '2020-10-28', '10:45:39', '00:00:00'),
(26, '2020-10-28', '10:56:18', '00:00:00'),
(27, '2020-10-28', '10:59:10', '00:00:00'),
(28, '2020-10-28', '11:05:22', '00:00:00'),
(29, '2020-10-28', '11:07:17', '00:00:00'),
(30, '2020-10-28', '11:21:33', '00:00:00'),
(31, '2020-10-28', '12:18:13', '00:00:00'),
(32, '2020-10-28', '12:20:37', '00:00:00'),
(33, '2020-10-28', '12:24:38', '00:00:00'),
(34, '2020-10-28', '12:29:28', '00:00:00'),
(35, '2020-10-28', '12:31:32', '00:00:00'),
(36, '2020-10-28', '12:35:18', '00:00:00'),
(37, '2020-10-28', '12:43:57', '00:00:00'),
(38, '2020-10-28', '12:45:07', '00:00:00'),
(39, '2020-10-28', '12:46:43', '00:00:00'),
(40, '2020-10-28', '12:48:59', '00:00:00'),
(41, '2020-10-28', '13:02:52', '00:00:00'),
(42, '2020-10-28', '13:05:34', '00:00:00'),
(43, '2020-10-28', '13:19:36', '00:00:00'),
(44, '2020-10-28', '13:21:26', '00:00:00'),
(45, '2020-10-22', '10:06:12', '15:03:28'),
(46, '2020-10-28', '13:21:26', '15:04:47'),
(47, '2020-10-28', '13:21:26', '15:20:38'),
(48, '2020-10-28', '15:23:34', '00:00:00'),
(49, '2020-10-28', '15:23:34', '15:23:49'),
(50, '2020-10-28', '15:25:20', '00:00:00'),
(51, '2020-10-28', '15:26:06', '00:00:00'),
(52, '2020-10-28', '15:25:20', '15:26:11'),
(53, '2020-10-28', '15:26:06', '15:26:29'),
(54, '2020-10-28', '15:27:32', '00:00:00'),
(55, '2020-10-28', '15:27:32', '15:28:08'),
(56, '2020-10-28', '15:28:10', '00:00:00'),
(57, '2020-10-28', '15:28:10', '15:28:15'),
(58, '2020-10-28', '15:28:52', '00:00:00'),
(59, '2020-10-28', '15:28:52', '15:30:05'),
(60, '2020-10-28', '15:30:06', '00:00:00'),
(61, '2020-10-28', '15:30:06', '15:30:08'),
(62, '2020-10-28', '15:43:05', '00:00:00'),
(63, '2020-10-28', '15:43:09', '00:00:00'),
(64, '2020-10-28', '15:43:05', '15:43:29'),
(65, '2020-10-28', '15:43:09', '15:43:30'),
(66, '2020-10-28', '15:44:08', '00:00:00'),
(67, '2020-10-28', '15:44:19', '00:00:00'),
(68, '2020-10-28', '15:44:08', '15:44:29'),
(69, '2020-10-28', '15:44:19', '15:45:01'),
(70, '2020-10-28', '15:46:59', '00:00:00'),
(71, '2020-10-28', '15:46:59', '15:48:55'),
(72, '2020-10-28', '15:49:01', '00:00:00'),
(73, '2020-10-28', '15:49:01', '15:49:12'),
(74, '2020-10-28', '16:16:44', '00:00:00'),
(75, '2020-10-28', '16:16:44', '16:18:58'),
(76, '2020-10-28', '16:19:16', '00:00:00'),
(77, '2020-10-28', '16:19:16', '16:20:35'),
(78, '2020-10-28', '16:21:10', '00:00:00'),
(79, '2020-10-28', '16:21:10', '16:22:09'),
(80, '2020-10-28', '16:22:14', '00:00:00'),
(81, '2020-10-28', '16:22:14', '16:22:55'),
(82, '2020-10-28', '16:23:45', '00:00:00'),
(83, '2020-10-28', '16:23:45', '16:27:25'),
(84, '2020-10-28', '16:27:28', '00:00:00'),
(85, '2020-10-28', '16:27:28', '16:27:51'),
(86, '2020-10-28', '16:33:21', '00:00:00'),
(87, '2020-10-28', '16:34:31', '00:00:00'),
(88, '2020-10-28', '16:34:31', '16:34:33'),
(89, '2020-10-28', '16:33:21', '16:34:35'),
(90, '2020-10-28', '16:34:54', '00:00:00'),
(91, '2020-10-28', '16:35:01', '00:00:00'),
(92, '2020-10-28', '16:35:01', '16:35:04'),
(93, '2020-10-28', '16:34:54', '16:35:05'),
(94, '2020-10-28', '16:36:02', '00:00:00'),
(95, '2020-10-28', '16:36:05', '00:00:00'),
(96, '2020-10-28', '16:36:06', '00:00:00'),
(97, '2020-10-28', '16:36:05', '16:36:55'),
(98, '2020-10-28', '16:36:06', '16:37:03'),
(99, '2020-10-28', '16:36:02', '16:37:21'),
(100, '2020-10-28', '16:50:45', '00:00:00'),
(101, '2020-10-28', '16:50:52', '00:00:00'),
(102, '2020-10-28', '16:50:55', '00:00:00'),
(103, '2020-10-28', '16:50:52', '16:51:01'),
(104, '2020-10-28', '16:55:15', '00:00:00'),
(105, '2020-10-28', '16:50:55', '17:03:13'),
(106, '2020-10-28', '16:50:45', '17:03:23'),
(107, '2020-10-28', '16:55:15', '17:03:26'),
(108, '2020-10-28', '17:03:35', '00:00:00'),
(109, '2020-10-28', '17:03:35', '17:03:36'),
(110, '2020-10-28', '17:03:37', '00:00:00'),
(111, '2020-10-28', '17:03:37', '17:03:39'),
(112, '2020-10-29', '00:00:00', '00:00:00'),
(113, '2020-10-29', '11:22:53', '00:00:00'),
(114, '2020-10-29', '11:22:53', '11:22:57'),
(115, '2020-10-29', '11:24:44', '00:00:00'),
(116, '2020-10-29', '11:25:09', '00:00:00'),
(117, '2020-10-29', '11:25:09', '11:25:16'),
(118, '2020-10-29', '11:24:44', '11:25:17'),
(119, '2020-10-29', '11:26:29', '00:00:00'),
(120, '2020-10-29', '11:26:52', '00:00:00'),
(121, '2020-10-29', '11:27:13', '00:00:00'),
(122, '2020-10-29', '11:26:29', '11:27:33'),
(123, '2020-10-29', '11:26:52', '11:41:33'),
(124, '2020-10-29', '11:27:13', '11:41:48'),
(125, '2020-10-29', '11:44:53', '00:00:00'),
(126, '2020-10-29', '11:44:55', '00:00:00'),
(127, '2020-10-29', '11:44:57', '00:00:00'),
(128, '2020-10-29', '11:44:57', '12:02:57'),
(129, '2020-10-29', '11:44:55', '12:03:00'),
(130, '2020-10-29', '11:44:53', '12:03:03'),
(131, '2020-10-29', '12:04:13', '00:00:00'),
(132, '2020-10-29', '12:04:32', '00:00:00'),
(133, '2020-10-29', '12:04:35', '00:00:00'),
(134, '2020-10-29', '12:04:13', '12:04:42'),
(135, '2020-10-29', '12:04:32', '12:04:43'),
(136, '2020-10-29', '12:04:35', '12:15:08'),
(137, '2020-10-29', '12:20:07', '00:00:00'),
(138, '2020-10-29', '12:20:08', '00:00:00'),
(139, '2020-10-29', '12:20:09', '00:00:00'),
(140, '2020-10-29', '12:20:08', '12:29:44'),
(141, '2020-10-29', '12:20:07', '12:30:00'),
(142, '2020-10-29', '12:20:09', '12:30:02'),
(143, '2020-10-29', '12:34:57', '00:00:00'),
(144, '2020-10-29', '12:35:00', '00:00:00'),
(145, '2020-10-29', '12:35:03', '00:00:00'),
(146, '2020-10-29', '12:34:57', '12:38:54'),
(147, '2020-10-29', '12:35:00', '12:38:55'),
(148, '2020-10-29', '12:35:03', '12:39:13'),
(149, '2020-10-29', '12:40:28', '00:00:00'),
(150, '2020-10-29', '12:40:42', '00:00:00'),
(151, '2020-10-29', '12:40:50', '00:00:00'),
(152, '2020-10-29', '12:40:42', '12:41:09'),
(153, '2020-10-29', '12:40:50', '12:41:10'),
(154, '2020-10-29', '12:40:28', '12:41:11'),
(155, '2020-10-29', '12:43:12', '00:00:00'),
(156, '2020-10-29', '12:43:15', '00:00:00'),
(157, '2020-10-29', '12:48:05', '00:00:00'),
(158, '2020-10-29', '12:48:05', '12:48:51'),
(159, '2020-10-29', '12:43:15', '12:48:54'),
(160, '2020-10-29', '12:43:12', '12:48:56'),
(161, '2020-10-29', '12:49:43', '00:00:00'),
(162, '2020-10-29', '12:49:49', '00:00:00'),
(163, '2020-10-29', '12:49:53', '00:00:00'),
(164, '2020-10-29', '12:49:49', '12:49:57'),
(165, '2020-10-29', '12:49:53', '12:49:59'),
(166, '2020-10-29', '12:49:43', '12:50:00'),
(167, '2020-10-29', '12:50:51', '00:00:00'),
(168, '2020-10-29', '12:50:54', '00:00:00'),
(169, '2020-10-29', '12:50:57', '00:00:00'),
(170, '2020-10-29', '12:50:51', '12:51:03'),
(171, '2020-10-29', '13:07:03', '00:00:00'),
(172, '2020-10-29', '12:50:57', '13:07:07'),
(173, '2020-10-29', '13:09:37', '00:00:00'),
(174, '2020-10-29', '13:09:37', '13:09:43'),
(175, '2020-10-29', '13:11:34', '00:00:00'),
(176, '2020-10-29', '13:11:34', '13:11:57'),
(177, '2020-10-29', '13:13:05', '00:00:00'),
(178, '2020-10-29', '13:13:05', '13:13:50'),
(179, '2020-10-29', '13:13:53', '00:00:00'),
(180, '2020-10-29', '12:50:54', '13:13:58'),
(181, '2020-10-29', '13:14:04', '00:00:00'),
(182, '2020-10-29', '13:07:03', '13:14:08'),
(183, '2020-10-29', '13:13:53', '13:14:13'),
(184, '2020-10-29', '13:14:16', '00:00:00'),
(185, '2020-10-29', '13:14:16', '13:14:18'),
(186, '2020-10-29', '13:14:04', '13:14:20'),
(187, '2020-10-31', '00:00:00', '00:00:00'),
(188, '2020-10-31', '10:25:40', '00:00:00'),
(189, '2020-10-31', '10:25:40', '10:25:50'),
(190, '2020-10-31', '10:57:20', '00:00:00'),
(191, '2020-10-31', '10:57:20', '10:57:23'),
(192, '2020-10-31', '10:57:26', '00:00:00'),
(193, '2020-10-31', '10:57:26', '10:57:29'),
(194, '2020-10-31', '11:13:58', '00:00:00'),
(195, '2020-10-31', '11:13:58', '11:14:00'),
(196, '2020-10-31', '11:20:50', '00:00:00'),
(197, '2020-10-31', '11:20:50', '11:20:52'),
(198, '2020-10-31', '11:22:06', '00:00:00'),
(199, '2020-10-31', '11:22:06', '11:22:07'),
(200, '2020-10-31', '11:38:21', '00:00:00'),
(201, '2020-10-31', '11:38:21', '11:38:23'),
(202, '2020-10-31', '11:38:27', '00:00:00'),
(203, '2020-10-31', '11:38:27', '11:38:28'),
(204, '2020-10-31', '11:39:16', '00:00:00'),
(205, '2020-10-31', '11:39:16', '11:39:24'),
(206, '2020-10-31', '11:40:53', '00:00:00'),
(207, '2020-10-31', '11:40:53', '11:40:55'),
(208, '2020-10-31', '11:41:12', '00:00:00'),
(209, '2020-10-31', '11:41:51', '00:00:00'),
(210, '2020-10-31', '11:41:51', '11:41:53'),
(211, '2020-10-31', '11:41:12', '11:41:57'),
(212, '2020-10-31', '11:43:11', '00:00:00'),
(213, '2020-10-31', '11:43:11', '11:43:12'),
(214, '2020-10-31', '11:43:16', '00:00:00'),
(215, '2020-10-31', '11:43:16', '11:43:19'),
(216, '2020-10-31', '11:43:36', '00:00:00'),
(217, '2020-10-31', '11:43:36', '11:43:38'),
(218, '2020-10-31', '11:44:12', '00:00:00'),
(219, '2020-10-31', '11:44:12', '11:44:14'),
(220, '2020-10-31', '12:01:35', '00:00:00'),
(221, '2020-11-01', '00:00:00', '00:00:00'),
(222, '2020-11-01', '16:58:43', '00:00:00'),
(223, '2020-11-01', '16:58:43', '16:58:44'),
(224, '2020-11-04', '00:00:00', '00:00:00'),
(225, '2020-11-04', '09:32:19', '00:00:00'),
(226, '2020-11-04', '09:32:19', '09:32:28'),
(227, '2020-11-04', '09:36:04', '00:00:00'),
(228, '2020-11-04', '09:36:04', '09:36:07'),
(229, '2020-11-04', '09:37:03', '00:00:00'),
(230, '2020-11-04', '09:37:03', '09:37:04'),
(231, '2020-10-31', '12:01:35', '10:06:36'),
(232, '2020-11-05', '00:00:00', '00:00:00'),
(233, '2020-11-05', '17:13:36', '00:00:00'),
(234, '2020-11-05', '17:13:36', '17:14:05');

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
  `id_date` int(15) NOT NULL,
  `id_estadoServicio` int(1) NOT NULL,
  `id_tipoServicios` int(2) NOT NULL,
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
--   `id_date`
--       `mydate` -> `id_date`
--   `id_estadoServicio`
--       `estadoservicio` -> `id_estadoServicio`
--   `id_tipoServicios`
--       `tiposervicios` -> `id_tipoServicios`
--

--
-- Volcado de datos para la tabla `servicios`
--

INSERT INTO `servicios` (`id_servicios`, `id_cliente`, `id_encargados`, `id_direcciones`, `id_date`, `id_estadoServicio`, `id_tipoServicios`, `descripcion`, `adicional`) VALUES
(3, 4, 21, 6, 18, 3, 1, 'Esto es una prueba', 5200),
(4, 4, 22, 6, 15, 3, 1, 'Esto es una prueba', 5200),
(6, 5, 25, 7, 18, 3, 1, 'Esto es una prueba 2', 500),
(7, 4, 22, 5, 21, 3, 4, 'pruebas finales frontend', 5200),
(10, 4, 29, 17, 45, 3, 4, 'Esto es una prueba en Desarrollo', 5500),
(30, 4, 21, 5, 47, 3, 4, 'EXITO', 1000),
(31, 4, 29, 6, 49, 3, 4, 'Esto es una prueba', 5200),
(32, 4, 21, 6, 52, 3, 4, 'Esto es una prueba', 5200),
(33, 4, 29, 5, 53, 3, 4, 'Esto es una prueba 2', 5200),
(34, 4, 21, 6, 55, 3, 4, 'Esto es una prueba555', 300),
(35, 4, 29, 6, 57, 3, 4, 'Esto es una prueba666', 200),
(36, 4, 29, 6, 59, 3, 4, 'Esto es una prueba555', 300),
(37, 4, 21, 6, 61, 3, 4, 'Esto es una prueba888', 200),
(38, 4, 29, 6, 64, 3, 4, 'Esto es una prueba555', 300),
(39, 4, 21, 6, 65, 3, 4, 'Esto es una prueba888', 200),
(40, 4, 29, 6, 68, 3, 4, 'Esto es una prueba555', 300),
(41, 4, 21, 6, 69, 3, 4, 'Esto es una prueba555', 300),
(42, 4, 31, 6, 71, 3, 4, 'Esto es una prueba', 5200),
(43, 4, 29, 6, 73, 3, 4, 'Esto es una prueba', 5200),
(44, 4, 29, 6, 75, 3, 4, 'Esto es una prueba', 5200),
(45, 4, 29, 6, 77, 3, 4, 'Esto es una prueba', 5200),
(46, 4, 29, 6, 79, 3, 4, 'Esto es una prueba', 5200),
(47, 4, 29, 6, 81, 3, 4, 'Esto es una prueba', 5200),
(48, 4, 29, 6, 83, 3, 4, 'Esto es una prueba', 5200),
(49, 4, 29, 6, 85, 3, 4, 'Esto es una prueba', 5200),
(50, 4, 21, 6, 88, 3, 4, 'Esto es una prueba', 5200),
(51, 4, 29, 6, 89, 3, 4, 'Esto es una prueba', 5200),
(52, 4, 31, 6, 92, 3, 4, 'Esto es una prueba', 5200),
(53, 4, 29, 6, 93, 3, 4, 'Esto es una prueba', 5200),
(54, 4, 31, 6, 97, 3, 4, 'Esto es una prueba', 1111),
(55, 4, 21, 6, 98, 3, 4, 'Esto es una prueba', 2222),
(56, 4, 29, 6, 99, 3, 4, 'Esto es una prueba', 3333),
(57, 4, 21, 6, 103, 3, 4, 'Esto es una prueba1', 1111),
(58, 4, 29, 6, 105, 3, 4, 'Esto es una prueba2', 2222),
(59, 4, 31, 6, 106, 3, 4, 'Esto es una prueba3', 3333),
(60, 4, 21, 6, 107, 3, 4, 'Esto es una prueba1', 1111),
(61, 4, 31, 6, 109, 3, 4, 'Esto es una prueba2', 2222),
(62, 4, 21, 6, 111, 3, 4, 'Esto es una prueba3', 3333),
(63, 4, 21, 6, 114, 3, 4, 'Esto es una prueba', 5200),
(64, 4, 21, 6, 117, 3, 4, 'Esto es una prueba', 5200),
(65, 4, 29, 6, 118, 3, 4, 'Esto es una prueba', 5200),
(66, 4, 29, 5, 122, 3, 4, 'Esto es una prueba1', 5200),
(67, 4, 21, 6, 123, 3, 4, 'Esto es una prueba2', 5200),
(68, 4, 31, 6, 124, 3, 4, 'Esto es una prueba3', 5200),
(69, 4, 29, 5, 128, 3, 4, 'Esto es una prueba1', 5200),
(70, 4, 21, 5, 129, 3, 4, 'Esto es una prueba2', 5200),
(71, 4, 31, 5, 130, 3, 4, 'Esto es una prueba3', 5200),
(72, 4, 29, 5, 134, 3, 4, 'Esto es una 111', 5200),
(73, 4, 21, 5, 135, 3, 4, 'Esto es una 222', 5200),
(74, 4, 31, 5, 136, 3, 4, 'Esto es una 333', 5200),
(75, 4, 21, 5, 141, 3, 4, 'Esto es una prueba1', 5200),
(76, 4, 29, 5, 140, 3, 4, 'Esto es una prueba2', 5200),
(77, 4, 31, 5, 142, 3, 4, 'Esto es una prueba3', 5200),
(78, 4, 21, 5, 147, 3, 4, 'Esto es una prueba1', 5200),
(79, 4, 31, 5, 148, 3, 4, 'Esto es una prueba2', 5200),
(80, 4, 29, 5, 146, 3, 4, 'Esto es una prueba3', 5200),
(81, 4, 29, 6, 154, 3, 4, 'Esto es una 1', 5200),
(82, 4, 21, 6, 152, 3, 4, 'Esto es una 2', 5200),
(83, 4, 31, 6, 153, 3, 4, 'Esto es una 3', 5200),
(84, 4, 29, 6, 159, 3, 4, 'Esto es una 1', 5200),
(85, 4, 21, 6, 160, 3, 4, 'Esto es una 2', 5200),
(86, 4, 31, 6, 158, 3, 4, 'Esto es una 3', 5200),
(87, 4, 31, 6, 165, 3, 4, 'Esto es una 1', 5200),
(88, 4, 29, 6, 166, 3, 4, 'Esto es una 2', 5200),
(89, 4, 21, 6, 164, 3, 4, 'Esto es una 3', 5200),
(90, 4, 21, 6, 170, 3, 4, 'Esto es una 1', 5200),
(91, 4, 29, 6, 172, 3, 4, 'Esto es una 2', 5200),
(92, 4, 31, 6, 180, 3, 4, 'Esto es una 3', 5200),
(93, 4, 21, 6, 182, 3, 4, 'Esto es una 4', 5200),
(94, 4, 29, 6, 174, 3, 4, 'Esto es una 5', 5200),
(95, 4, 29, 6, 176, 3, 4, 'Esto es una 6', 5200),
(96, 4, 29, 6, 178, 3, 4, 'Esto es una 7', 5200),
(97, 4, 29, 6, 183, 3, 4, 'Esto es una 8', 5200),
(98, 4, 31, 6, 186, 3, 4, 'Esto es una 9', 5200),
(99, 4, 29, 6, 185, 3, 4, 'Esto es una 10', 5200),
(100, 5, 29, 7, 189, 3, 3, 'jjijiijj', 10),
(101, 5, 29, 7, 191, 3, 3, 'jjijiijj', 10),
(102, 5, 29, 7, 193, 3, 3, 'jjijiijj', 10),
(103, 5, 29, 7, 195, 3, 3, 'jjijiijj', 10),
(104, 4, 29, 5, 197, 3, 4, '', 987),
(105, 5, 29, 7, 199, 3, 3, '', 4),
(106, 4, 29, 17, 201, 3, 3, '', 0),
(107, 4, 29, 17, 203, 3, 3, '', 0),
(108, 5, 29, 7, 205, 3, 3, 'jijij', 3),
(109, 4, 29, 5, 207, 3, 3, '', 4),
(110, 4, 29, 5, 211, 3, 3, '', 1582),
(111, 7, 31, 8, 210, 3, 12, '', 7),
(112, 5, 29, 7, 213, 3, 11, '', 666),
(113, 5, 29, 7, 215, 3, 11, '', 666),
(114, 5, 29, 7, 217, 3, 4, '', 6),
(115, 7, 29, 8, 219, 3, 3, '', 0),
(116, 4, 29, 5, 231, 3, 3, '', 0),
(117, 5, 21, 7, 223, 3, 1, 'Exito total', 1955),
(118, 7, 21, 8, 226, 3, 1, 'okkk', 600),
(119, 9, 31, 10, 228, 3, 3, 'ooooook', 15000),
(120, 7, 31, 8, 230, 3, 4, '', 19000),
(121, 6, 21, 18, 234, 3, 13, '', 2000);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tiposervicios`
--

CREATE TABLE `tiposervicios` (
  `id_tipoServicios` int(2) NOT NULL,
  `id_estadoTipoServicios` int(1) NOT NULL,
  `servicios` varchar(50) NOT NULL,
  `valor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `tiposervicios`:
--   `id_estadoTipoServicios`
--       `estadotiposervicios` -> `id_estadoTipoServicios`
--

--
-- Volcado de datos para la tabla `tiposervicios`
--

INSERT INTO `tiposervicios` (`id_tipoServicios`, `id_estadoTipoServicios`, `servicios`, `valor`) VALUES
(1, 2, 'Domicilio Comida', 12000),
(2, 2, 'Vuelta Banco', 7000),
(3, 1, 'Pagos Facturas y Servicios Publicos', 5000),
(4, 1, 'Punto A Punto', 8000),
(5, 2, 'Domicilio Otro', 6000),
(11, 1, 'Prueba Exitosa', 10000),
(12, 1, 'prueba exitosa 3', 424242),
(13, 1, 'Domicilio Comida', 15000),
(14, 1, 'bancos prueba', 5000);

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
(13, 3, 1, 25, 22, 2),
(14, 3, 1, 26, 23, 1),
(15, 3, 2, 27, 24, 1),
(16, 3, 1, 28, 25, 1),
(17, 2, 1, 29, 26, NULL),
(18, 2, 1, 30, 27, NULL),
(19, 1, 1, 31, 28, NULL),
(20, 3, 3, 32, 29, 1),
(21, 3, 3, 34, 30, 1),
(22, 3, 3, 35, 31, 1),
(23, 3, 3, 36, 32, 2),
(24, 3, 3, 37, 33, 1),
(25, 3, 3, 38, 34, 2),
(26, 3, 1, 39, 35, 1),
(27, 2, 3, 40, 36, NULL),
(28, 2, 1, 43, 43, NULL),
(29, 2, 3, 44, 44, NULL),
(30, 2, 3, 45, 45, NULL),
(31, 2, 3, 46, 46, NULL),
(32, 2, 1, 47, 47, NULL);

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
-- Indices de la tabla `estadotiposervicios`
--
ALTER TABLE `estadotiposervicios`
  ADD PRIMARY KEY (`id_estadoTipoServicios`);

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
  ADD KEY `id_date` (`id_date`),
  ADD KEY `id_estadoServicio` (`id_estadoServicio`),
  ADD KEY `id_tipoServicios` (`id_tipoServicios`);

--
-- Indices de la tabla `tiposervicios`
--
ALTER TABLE `tiposervicios`
  ADD PRIMARY KEY (`id_tipoServicios`),
  ADD KEY `id_estadoTipoServicios` (`id_estadoTipoServicios`);

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
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `credenciales`
--
ALTER TABLE `credenciales`
  MODIFY `id_credenciales` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT de la tabla `datospersonales`
--
ALTER TABLE `datospersonales`
  MODIFY `id_datosPersonales` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT de la tabla `direcciones`
--
ALTER TABLE `direcciones`
  MODIFY `id_direcciones` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de la tabla `encargados`
--
ALTER TABLE `encargados`
  MODIFY `id_encargados` int(15) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=142;

--
-- AUTO_INCREMENT de la tabla `estadoservicio`
--
ALTER TABLE `estadoservicio`
  MODIFY `id_estadoServicio` int(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `estadotiposervicios`
--
ALTER TABLE `estadotiposervicios`
  MODIFY `id_estadoTipoServicios` int(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

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
  MODIFY `id_date` int(15) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=235;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `servicios`
--
ALTER TABLE `servicios`
  MODIFY `id_servicios` int(15) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=122;

--
-- AUTO_INCREMENT de la tabla `tiposervicios`
--
ALTER TABLE `tiposervicios`
  MODIFY `id_tipoServicios` int(2) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `turno`
--
ALTER TABLE `turno`
  MODIFY `id_turno` int(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

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
  ADD CONSTRAINT `servicios_ibfk_5` FOREIGN KEY (`id_date`) REFERENCES `mydate` (`id_date`),
  ADD CONSTRAINT `servicios_ibfk_6` FOREIGN KEY (`id_estadoServicio`) REFERENCES `estadoservicio` (`id_estadoServicio`),
  ADD CONSTRAINT `servicios_ibfk_7` FOREIGN KEY (`id_tipoServicios`) REFERENCES `tiposervicios` (`id_tipoServicios`);

--
-- Filtros para la tabla `tiposervicios`
--
ALTER TABLE `tiposervicios`
  ADD CONSTRAINT `tiposervicios_ibfk_1` FOREIGN KEY (`id_estadoTipoServicios`) REFERENCES `estadotiposervicios` (`id_estadoTipoServicios`);

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
