const { MySQL } = require('../database/mysql');
const { capitalizar, fechaActual, devolverFecha } = require('../functions/funciones');

const historialDiaDomiciliario = (req, res) => {
    let query = `CALL consultarServiciosDomiciliario('${
        req.usuario.id_usuario
    }','${fechaActual()}','${fechaActual()}')`;
    let rutaHBS = 'domiciliario/historialDia_domiciliario.hbs';
    consultarHistorialMysql(req, res, query, true, rutaHBS);
};

const historialTemporalDomiciliario = (req, res) => {};

const historialDiaAdministrador = (req, res) => {
    let query = `CALL consultarServiciosDia('${fechaActual()}')`;
    let rutaHBS = 'admin/historialDia_admin.hbs';
    consultarHistorialMysql(req, res, query, true, rutaHBS);
};

const historialTemporalAdministrador = (req, res) => {
    let query = `CALL consultarServiciosTemporal('${req.body.desde}','${req.body.hasta}')`;
    consultarHistorialMysql(req, res, query, false);
};

const historialClienteAdministrador = (req, res) => {};

const historialDomiciliarioAdministrador = (req, res) => {};

const consultarHistorialMysql = (req, res, query, render, rutaHBS = '') => {
    let historial = [];
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
                historial[index] = [];
                historial[index][0] = capitalizar(result[0][index].nombreAdmin);
                historial[index][1] = capitalizar(result[0][index].nombreDomiciliario);
                historial[index][2] = capitalizar(result[0][index].nombreCliente);
                historial[index][3] = capitalizar(result[0][index].estadoservicio);
                historial[index][4] = capitalizar(result[0][index].direccion);
                historial[index][5] = capitalizar(result[0][index].tiposervicio);
                historial[index][6] = result[0][index].valorServicio;
                historial[index][7] = result[0][index].valorAdicional;
                historial[index][8] = result[0][index].descripcion;
                historial[index][9] = devolverFecha(result[0][index].Fecha);
                historial[index][10] = result[0][index].horaInicio;
                historial[index][11] = result[0][index].horaFinal;
                historial[index][12] = result[0][index].celularCliente;
                index++;
            }
        }
        if (render) {
            //Respondo  con los datos y renderizacion al cliente
            return res.render(rutaHBS, {
                data: {
                    historial,
                    infoPersonal: {
                        nombre: capitalizar(req.usuario.nombre),
                    },
                },
            });
        } else {
            //Respondo  con los datos con Json
            return res.json({
                data: {
                    historial,
                },
            });
        }
    });
};
module.exports = {
    historialDiaDomiciliario,
    historialTemporalDomiciliario,
    historialDiaAdministrador,
    historialTemporalAdministrador,
    historialClienteAdministrador,
    historialDomiciliarioAdministrador,
};
