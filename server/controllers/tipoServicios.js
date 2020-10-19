const { MySQL } = require('../database/mysql');
const { capitalizar } = require('../functions/funciones');

const renderTipoServicios = (req, res) => {
    let query = 'CALL consultarTipoServicios();';
    let tipoServicios = [];
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
                tipoServicios[index] = [];
                tipoServicios[index][0] = capitalizar(result[0][index].servicios);
                tipoServicios[index][1] = result[0][index].valor;
                tipoServicios[index][2] = result[0][index].id_tipoServicios;
                index++;
            }
        }
        //Enviamos los datos al cliente
        return res.render('superAdmin/tipoServicios_superAdmin.hbs', {
            data: {
                tipoServicios,
                infoPersonal: {
                    nombre: capitalizar(req.usuario.nombre),
                },
            },
        });
    });
};

const actualizarTipoServicios = (req, res) => {
    let idTipoServicio = MySQL._instance.conexion.escape(req.body.idTipoServicio);
    let servicio = MySQL._instance.conexion.escape(req.body.servicioModalEditar);
    let precio = MySQL._instance.conexion.escape(req.body.precioModalEditar);
    let query = `CALL actualizarTipoServicios(${idTipoServicio},${servicio},${precio});`;
    let tipoServicios = [];
    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        } else {
            return res.json({
                ok: true,
                msj: 'Tipo de Servicio Actualizado',
            });
        }
    });
};

module.exports = {
    renderTipoServicios,
    actualizarTipoServicios,
};
