const { MySQL } = require('../database/mysql');
const { capitalizar } = require('../functions/funciones');

const consultarAdministradores = (req, res) => {
    let query = 'CALL consultarAdmins();';
    let administradores = [];
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
                administradores[index] = [];
                administradores[index][0] = capitalizar(result[0][index].nombre);
                administradores[index][1] = capitalizar(result[0][index].email);
                administradores[index][2] = capitalizar(result[0][index].cedula);
                administradores[index][3] = capitalizar(result[0][index].celular);
                administradores[index][4] = capitalizar(result[0][index].estado);
                administradores[index][5] = result[0][index].pathImage;
                administradores[index][6] = result[0][index].id_usuario;
                index++;
            }
        }
        res.render('superAdmin/administradores_superAdmin.hbs', {
            data: {
                administradores,
                estados: [['Habilitado'], ['Deshabilitado']],
                infoPersonal: {
                    nombre: capitalizar(req.usuario.nombre),
                },
            },
        });
    });
};

agregarAdministradores = (req, res) => {
    let nombre = MySQL.instance.conexion.escape(req.body.nombreModalAnadir);
    let cedula = MySQL.instance.conexion.escape(req.body.cedulaModalAnadir);
    let celular = MySQL.instance.conexion.escape(req.body.celularModalAnadir);
    let email = MySQL.instance.conexion.escape(req.body.correoModalAnadir);
    let estadoUsuario = MySQL.instance.conexion.escape(req.body.estadoModalAnadir);
    let password = cedula;

    let pathImage;

    if (req.file != undefined) {
        pathImage = MySQL.instance.conexion.escape('admin/' + req.file.filename);
    } else {
        pathImage = MySQL.instance.conexion.escape('admin/defaultAdmin.png');
    }
    let query = `CALL agregarAdmin(${nombre},${cedula},${celular},${email},${password},${pathImage},${estadoUsuario});`;
    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        } else {
            return res.json({
                ok: true,
                msj: 'Administrador agregado',
            });
        }
    });
};

const actualizarAdministradores = (req, res) => {
    let idAdministrador = MySQL.instance.conexion.escape(req.body.idAdministrador);
    let nombre = MySQL.instance.conexion.escape(req.body.nombreModalEditar);
    let cedula = MySQL.instance.conexion.escape(req.body.cedulaModalEditar);
    let celular = MySQL.instance.conexion.escape(req.body.celularModalEditar);
    let pathImage;
    if (req.file != undefined) {
        pathImage = MySQL.instance.conexion.escape('admin/' + req.file.filename);
    } else {
        pathImage = MySQL.instance.conexion.escape(req.body.pathImageModalEditar);
    }
    let estadoUsuario = MySQL.instance.conexion.escape(req.body.estadoModalEditar);

    let query = `CALL actualizarAdmin(${idAdministrador},${nombre},${cedula},${celular},${pathImage},${estadoUsuario});`;
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
eliminarAdministradores = (req, res) => {
    let idAdministrador = MySQL.instance.conexion.escape(req.body.idAdministrador);
    let query = `CALL eliminarUsuario(${idAdministrador});`;

    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        } else {
            return res.json({
                ok: true,
                msj: 'Administrador Eliminado',
            });
        }
    });
};

module.exports = {
    consultarAdministradores,
    agregarAdministradores,
    actualizarAdministradores,
    eliminarAdministradores,
};
