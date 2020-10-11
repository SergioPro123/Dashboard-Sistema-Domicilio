-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 12-10-2020 a las 01:32:25
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIdCredenciales` (IN `emailVariable` VARCHAR(50), IN `passwordVariable` VARCHAR(20), OUT `idCredenciales` INT(11))  NO SQL
BEGIN
	DECLARE existeCredenciales INT;
    
   INSERT into credenciales(credenciales.email,credenciales.password) VALUES(emailVariable,passwordVariable);
        SELECT LAST_INSERT_ID() into idCredenciales;
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
  `id_direcciones` int(11) NOT NULL,
  `nombre` varchar(40) NOT NULL,
  `celular` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `cliente`:
--   `id_direcciones`
--       `direcciones` -> `id_direcciones`
--

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
(18, 'PRUEBAADMIN@GMAIL.COM', 'myPassword'),
(21, 'PRUEBDOMICILIARIO@GMAIL.COM', 'myPassword');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `date`
--

CREATE TABLE `date` (
  `id_date` int(15) NOT NULL,
  `fecha` date NOT NULL,
  `horaInicio` time NOT NULL,
  `horaFinal` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `date`:
--

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
(22, 'UPDATE ADMIN', '111111', '22222', '/image/UPDATE'),
(23, 'UPDATE DOMICILIARIO', '55555', '666666', '/image/UPDATE');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `direcciones`
--

CREATE TABLE `direcciones` (
  `id_direcciones` int(11) NOT NULL,
  `direccion` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `direcciones`:
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `encargados`
--

CREATE TABLE `encargados` (
  `id_encargados` int(15) NOT NULL,
  `id_usuario_ADMIN` int(11) NOT NULL,
  `id_usuario_DOMICILIARIO` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `encargados`:
--   `id_usuario_ADMIN`
--       `usuario` -> `id_usuario`
--   `id_usuario_DOMICILIARIO`
--       `usuario` -> `id_usuario`
--

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
  `path_evidencia` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- RELACIONES PARA LA TABLA `evidencia`:
--

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
  `adicional` int(11) DEFAULT NULL,
  `id_evidencia` int(15) DEFAULT NULL
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
--       `date` -> `id_date`
--   `id_estadoServicio`
--       `estadoservicio` -> `id_estadoServicio`
--   `id_evidencia`
--       `evidencia` -> `id_evidencia`
--

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
(11, 2, 2, 22, 18, NULL),
(12, 3, 2, 23, 21, 2);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id_cliente`),
  ADD KEY `id_direcciones` (`id_direcciones`);

--
-- Indices de la tabla `credenciales`
--
ALTER TABLE `credenciales`
  ADD PRIMARY KEY (`id_credenciales`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `date`
--
ALTER TABLE `date`
  ADD PRIMARY KEY (`id_date`);

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
  ADD PRIMARY KEY (`id_direcciones`);

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
  ADD PRIMARY KEY (`id_evidencia`);

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
  ADD KEY `id_estadoServicio` (`id_estadoServicio`),
  ADD KEY `id_evidencia` (`id_evidencia`);

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
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `credenciales`
--
ALTER TABLE `credenciales`
  MODIFY `id_credenciales` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `date`
--
ALTER TABLE `date`
  MODIFY `id_date` int(15) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `datospersonales`
--
ALTER TABLE `datospersonales`
  MODIFY `id_datosPersonales` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT de la tabla `direcciones`
--
ALTER TABLE `direcciones`
  MODIFY `id_direcciones` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `encargados`
--
ALTER TABLE `encargados`
  MODIFY `id_encargados` int(15) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `estadoservicio`
--
ALTER TABLE `estadoservicio`
  MODIFY `id_estadoServicio` int(1) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `estadousuario`
--
ALTER TABLE `estadousuario`
  MODIFY `id_estadoUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `evidencia`
--
ALTER TABLE `evidencia`
  MODIFY `id_evidencia` int(15) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `servicios`
--
ALTER TABLE `servicios`
  MODIFY `id_servicios` int(15) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tiposervicios`
--
ALTER TABLE `tiposervicios`
  MODIFY `id_tipoServicios` int(2) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `turno`
--
ALTER TABLE `turno`
  MODIFY `id_turno` int(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `cliente_ibfk_1` FOREIGN KEY (`id_direcciones`) REFERENCES `direcciones` (`id_direcciones`);

--
-- Filtros para la tabla `encargados`
--
ALTER TABLE `encargados`
  ADD CONSTRAINT `encargados_ibfk_1` FOREIGN KEY (`id_usuario_ADMIN`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `encargados_ibfk_2` FOREIGN KEY (`id_usuario_DOMICILIARIO`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `servicios`
--
ALTER TABLE `servicios`
  ADD CONSTRAINT `servicios_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`),
  ADD CONSTRAINT `servicios_ibfk_2` FOREIGN KEY (`id_encargados`) REFERENCES `encargados` (`id_encargados`),
  ADD CONSTRAINT `servicios_ibfk_3` FOREIGN KEY (`id_direcciones`) REFERENCES `direcciones` (`id_direcciones`),
  ADD CONSTRAINT `servicios_ibfk_4` FOREIGN KEY (`id_tipoServicios`) REFERENCES `tiposervicios` (`id_tipoServicios`),
  ADD CONSTRAINT `servicios_ibfk_5` FOREIGN KEY (`id_date`) REFERENCES `date` (`id_date`),
  ADD CONSTRAINT `servicios_ibfk_6` FOREIGN KEY (`id_estadoServicio`) REFERENCES `estadoservicio` (`id_estadoServicio`),
  ADD CONSTRAINT `servicios_ibfk_7` FOREIGN KEY (`id_evidencia`) REFERENCES `evidencia` (`id_evidencia`);

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
