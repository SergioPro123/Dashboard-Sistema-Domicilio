const { MySQL } = require('../database/mysql');
const { capitalizar, devolverFecha } = require('../functions/funciones');

//Tendremos que hacer varias consultas para entregarle la información sufieciente al cliente
//Estructura ejemplo:
/*

data: { 
            historial: [[...]],
            clientes: [
                [idCliente,nombreCliente],
            ],
            tipoServicios: [
                [idServicio,valorCliente, nombreServicio],
            ],
            datoServicios: {
                servicioTotales: 11,
                servicioEnProceso: 55,
                servicioConcluidos: 66,
                servicioCancelados: 88,
            },
            infoPersonal: {
                nombre: capitalizar(req.usuario.nombre),
            },
        },
    }

*/
var historialGlobal;
var clientesGlobal = [];
var tipoServiciosGlobal = [];
var datoServiciosGlobal = [];
const renderGenerarServicio = (req, res) => {
    let query = `CALL consultarServicios_enPROCESO();`;
    consultarHistorialMysql(req, res, query);
};

const consultarDirecciones = (req, res) => {
    let idCliente = MySQL._instance.conexion.escape(req.params.idCliente);
    let query = `CALL consultarDireccionesIndividual(${idCliente});`;
    let data = {};
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
                data[result[0][index].direccion] = capitalizar(result[0][index].direccion);
                index++;
            }
        }
        return res.json(data);
    });
};

//Esta funcion es servida para las demas funciones, ya que se encarga de
//de procesar la informacion devuelta por el servidor, de acuerdo a cada
// consulta de los historiales.
const consultarHistorialMysql = (req, res, query) => {
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
                historial[index][3] = result[0][index].estadoservicio;
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
        historialGlobal = historial;
        let query = 'CALL consultarClientes();';
        consultarUsuarios(req, res, query);
    });
};

const consultarUsuarios = (req, res, query) => {
    let dataUsuarios = [];
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
                dataUsuarios[index] = [];
                dataUsuarios[index][0] = result[0][index].id_cliente;
                dataUsuarios[index][1] = capitalizar(result[0][index].nombre);
                index++;
            }
        }
        clientesGlobal = dataUsuarios;
        query = 'CALL consultarTipoServicios();';
        tipoServicios(req, res, query);
    });
};

const tipoServicios = (req, res, query) => {
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
                tipoServicios[index][0] = result[0][index].id_tipoServicios;
                tipoServicios[index][1] = result[0][index].valor;
                tipoServicios[index][2] = capitalizar(result[0][index].servicios);
                index++;
            }
        }
        //Vamos llenando la información
        tipoServiciosGlobal = tipoServicios;
        //Empezamos a hacer las consultas una por una, para saber los totales de estado de servicios
        let estadoServicio = ['SIN_ASIGNAR', 'ASIGNADO', 'COMPLETADO', 'CANCELADO'];
        let nombreServicio = ['servicioTotales', 'servicioEnProceso', 'servicioConcluidos', 'servicioCancelados'];
        for (let i = 0; i < estadoServicio.length; i++) {
            datoServicios(req, res, estadoServicio[i], nombreServicio[i]);
        }
    });
};

const datoServicios = (req, res, estadoServicio, nombreServicio) => {
    let query = `CALL totalServicios('${estadoServicio}');`;
    let total;
    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        }
        //Verifico que haya devuelto datos
        if (result.length > 0) {
            total = result[0][0].total;
        }
        //Vamos llenando la información
        datoServiciosGlobal[nombreServicio] = total;
        let data = {
            data: {
                historial: historialGlobal,
                clientes: clientesGlobal,
                tipoServicios: tipoServiciosGlobal,
                datoServicios: datoServiciosGlobal,
                infoPersonal: {
                    nombre: capitalizar(req.usuario.nombre),
                },
            },
        };
        //Verificamos que sea el ultimo ciclo, si es asi, enviamos la informacion al cliente.
        if (nombreServicio == 'servicioCancelados') {
            //Tenemos que sumar primero los totales de los servicios y tambien sumar 'SIN_ASIGNAR' con 'ASIGNAR'
            //con el fin de sacar el valor total de servicio en proceso

            data.data.datoServicios.servicioEnProceso += data.data.datoServicios.servicioTotales;
            data.data.datoServicios.servicioTotales =
                data.data.datoServicios.servicioEnProceso +
                data.data.datoServicios.servicioConcluidos +
                data.data.datoServicios.servicioCancelados;
            return res.render('admin/generarServicio_admin.hbs', data);
        }
    });
};

module.exports = {
    renderGenerarServicio,
    consultarDirecciones,
};
