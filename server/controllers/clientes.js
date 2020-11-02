const { MySQL } = require('../database/mysql');
const { capitalizar } = require('../functions/funciones');

const consultarClientes = (req, res) => {
    let query = 'CALL consultarClientes();';
    var clientes = [];
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
                clientes[index] = [];
                clientes[index][0] = capitalizar(result[0][index].nombre);
                clientes[index][1] = capitalizar(result[0][index].celular);
                clientes[index][2] = [];
                clientes[index][3] = result[0][index].serviciosBrindados;
                clientes[index][4] = result[0][index].id_cliente;
                index++;
            }
        }
        let query2 = 'CALL consultarDirecciones();';
        //Se vuelve a consultar en la base de datos, las direcciones de los clientes.
        MySQL.ejecutarQuery(query2, (err, result) => {
            if (err) {
                return res.json({
                    ok: false,
                    msj: 'Error en la consulta',
                });
            }
            //Verifico que haya devuelto datos
            if (result.length > 0) {
                if (result.length > 0) {
                    let index = 0;
                    //Recorro cada registro
                    while (result[0][index]) {
                        //Empezamos a añadir las direcciones a los clientes
                        for (let i = 0; i < clientes.length; i++) {
                            //Buscamos entre todos los clientes ya guardados, comparando las ID de direcciones
                            if (clientes[i][4] == result[0][index].id_cliente) {
                                //Validamos que no este vacia la direccion
                                if (!(result[0][index].direccion == '')) {
                                    //Vamos añadiendos las direcciones que contenga ese cliente
                                    clientes[i][2].push(capitalizar(result[0][index].direccion));
                                }
                            }
                        }
                        index++;
                    }
                }
            }
            //Enviamos los datos al cliente
            return res.render('admin/clientes_admin.hbs', {
                data: {
                    clientes,
                    infoPersonal: {
                        nombre: capitalizar(req.usuario.nombre),
                        pathImage: req.usuario.pathImage,
                    },
                },
            });
        });
    });
};

const agregarClientes = (req, res) => {
    let nombre = MySQL.instance.conexion.escape(req.body.nombreModalAnadir);
    let celular = MySQL.instance.conexion.escape(req.body.celularModalAnadir);
    let direccion = MySQL.instance.conexion.escape(req.body.direccionModalAnadir);

    let query = `CALL agregarCliente(${nombre},${celular},${direccion});`;
    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        } else {
            return res.json({
                ok: true,
                msj: 'Usuario Eliminado',
            });
        }
    });
};
const actualizarClientes = (req, res) => {
    let idCliente = MySQL.instance.conexion.escape(req.body.idCliente);
    let nombre = MySQL.instance.conexion.escape(req.body.nombreModalEditar);
    let celular = MySQL.instance.conexion.escape(req.body.celularModalEditar);
    let direccion = MySQL.instance.conexion.escape(req.body.direccionesModalEditar);

    let query = `CALL actualizarCliente(${idCliente},${nombre},${celular},${direccion});`;
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
    consultarClientes,
    agregarClientes,
    actualizarClientes,
};
