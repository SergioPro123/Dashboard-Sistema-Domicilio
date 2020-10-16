const { MySQL } = require('../database/mysql');
const { capitalizar } = require('../functions/funciones');

const consutalDomiciliarios = (req, res) => {
    let query = 'CALL consultarDomiciliarios();';
    let domiciliarios = [];
    //Se hace la respectiva consulta a MySql
    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        }
        //Verifico que haya devuelto datos
        if (result.length > 0) {
            let index = 0;
            //Recorro cada registro
            while (result[0][index]) {
                domiciliarios[index] = [];
                domiciliarios[index][0] = capitalizar(result[0][index].nombre);
                domiciliarios[index][1] = capitalizar(result[0][index].email);
                domiciliarios[index][2] = capitalizar(result[0][index].cedula);
                domiciliarios[index][3] = capitalizar(result[0][index].celular);
                domiciliarios[index][4] = capitalizar(result[0][index].nombreTurno);
                domiciliarios[index][5] = capitalizar(result[0][index].estado);
                domiciliarios[index][6] = result[0][index].pathImage;
                domiciliarios[index][7] = result[0][index].id_usuario;
                index++;
            }
        }
        //Respondo al cliente con los datos
        return res.render('admin/domiciliarios_admin.hbs', {
            data: {
                domiciliarios,
                estados: [['Habilitado'], ['Deshabilitado']],
                infoPersonal: {
                    nombre: capitalizar(req.usuario.nombre),
                },
            },
        });
    });
};

agregarDomiciliarios = (req, res) => {
    let nombre = MySQL.instance.conexion.escape(req.body.nombreModalAnadir);
    let cedula = MySQL.instance.conexion.escape(req.body.cedulaModalAnadir);
    let celular = MySQL.instance.conexion.escape(req.body.celularModalAnadir);
    let turno = MySQL.instance.conexion.escape(req.body.turnoModalAnadir);
    let email = MySQL.instance.conexion.escape(req.body.correoModalAnadir);
    let estadoUsuario = MySQL.instance.conexion.escape(req.body.estadoModalAnadir);
    let password = cedula;

    let pathImage;

    if (req.file != undefined) {
        pathImage = MySQL.instance.conexion.escape('domiciliario/' + req.file.filename);
    } else {
        pathImage = MySQL.instance.conexion.escape('domiciliario/defaultUser.png');
    }
    let query = `CALL agregarDomiciliario(${nombre},${cedula},${celular},${turno},${email},${password},${pathImage},${estadoUsuario});`;
    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        } else {
            return res.json({
                ok: true,
                msj: 'Domiciliario agregado',
            });
        }
    });
};

eliminarDomiciliarios = (req, res) => {
    let idDomiciliario = MySQL.instance.conexion.escape(req.body.idDomiciliario);
    let query = `CALL eliminarUsuario(${idDomiciliario});`;

    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        } else {
            return res.json({
                ok: true,
                msj: 'Domiciliario Eliminado',
            });
        }
    });
};

const actualizarDomiciliarios = (req, res) => {
    let idDomiciliario = MySQL.instance.conexion.escape(req.body.idDomiciliario);
    let nombre = MySQL.instance.conexion.escape(req.body.nombreModalEditar);
    let cedula = MySQL.instance.conexion.escape(req.body.cedulaModalEditar);
    let celular = MySQL.instance.conexion.escape(req.body.celularModalEditar);
    let turno = MySQL.instance.conexion.escape(req.body.turnoModalEditar);
    let pathImage;
    if (req.file != undefined) {
        pathImage = MySQL.instance.conexion.escape('domiciliario/' + req.file.filename);
    } else {
        pathImage = MySQL.instance.conexion.escape(req.body.pathImageModalEditar);
    }
    let estadoUsuario = MySQL.instance.conexion.escape(req.body.estadoModalEditar);

    let query = `CALL actualizarDomiciliario(${idDomiciliario},${nombre},${cedula},${celular},${turno},${pathImage},${estadoUsuario});`;

    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        } else {
            return res.json({
                ok: true,
                msj: 'Usuario Actualizado',
            });
        }
    });
};

module.exports = {
    consutalDomiciliarios,
    agregarDomiciliarios,
    eliminarDomiciliarios,
    actualizarDomiciliarios,
};
