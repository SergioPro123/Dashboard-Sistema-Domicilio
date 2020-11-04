/*
******ADMIN******
dashboard =
data:{
    estadistica:{
        clientesTotales,
        serviciosMes,
        dineroMes,
        domiciliariosTotales,
        ventasMes:{
            columns:[],
        }
    },
    infoPersonal:{
        nombre
    },

}
*/
const { MySQL } = require('../database/mysql');
const { capitalizar, fechaInicioyFinMes, devolverFecha } = require('../functions/funciones');

const dashboardADMINS = (req, res, url) => {
    let query = `CALL consultarTopDomiciliariosMes();`;
    let topDomiciliarios = [];
    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        }
        if (result.length > 0) {
            let index = 0;
            //Recorro cada registro
            while (result[0][index]) {
                topDomiciliarios[index] = [];
                topDomiciliarios[index][0] = capitalizar(result[0][index].nombre);
                topDomiciliarios[index][1] = result[0][index].pathImage;
                topDomiciliarios[index][2] = capitalizar(result[0][index].correo);
                topDomiciliarios[index][3] = result[0][index].totalServicios;
                topDomiciliarios[index][4] = result[0][index].totalGanancias;
                index++;
            }
        }
        return res.render(url, {
            data: {
                topDomiciliarios,
                infoPersonal: {
                    nombre: capitalizar(req.usuario.nombre),
                    pathImage: req.usuario.pathImage,
                },
            },
        });
    });
};

const dashboardDOMICILIARIO = (req, res) => {
    return res.render('domiciliario/dashboard_domiciliario.hbs', {
        data: {
            infoPersonal: {
                nombre: capitalizar(req.usuario.nombre),
                pathImage: req.usuario.pathImage,
            },
        },
    });
};

const dashboardEstadisticasAdmin = (req, res) => {
    let fechas = fechaInicioyFinMes();
    let query = `CALL consultarServiciosTemporal('${fechas.desde}','${fechas.hasta}')`;
    let historial = [];
    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        }
        let clientesActivos = 0;
        let serviciosRealizados = 0;
        let gananciasMes = 0;
        let domiciliariosActivos = 0;
        let valores = [];
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
                //Contamos la cantidad de servicios completados en el mes
                if (historial[index][3] == 'COMPLETADO') {
                    serviciosRealizados++;
                    gananciasMes += historial[index][6] + historial[index][7];
                    //Si es el primer servicio, obviamente se suma directamente en este bloque, ya que por ser cero
                    // no entrara en los bucles
                    if (index == 0) {
                        clientesActivos++;
                        domiciliariosActivos++;
                        index++;
                        continue;
                    }
                    //Recorremos desde el principio hasta el valor de 'i', para verificar si el cliente ya se conto
                    for (let j = 0; j < index; j++) {
                        if (historial[j][2] == historial[index][2]) {
                            break;
                        } else if (j + 1 == index) {
                            clientesActivos++;
                            break;
                        }
                    }
                    //Recorremos desde el principio hasta el valor de 'i', para verificar si el domiciliario ya se conto
                    for (let j = 0; j < index; j++) {
                        if (historial[j][1] == historial[index][1]) {
                            break;
                        } else if (j + 1 == index) {
                            domiciliariosActivos++;
                            break;
                        }
                    }
                    //

                    if (valores.length > 0) {
                        for (let j = 0; j < valores.length; j++) {
                            if (historial[index][5] === valores[j][0]) {
                                valores[j][1] += historial[index][6] + historial[index][7];
                                break;
                            } else if (j + 1 == valores.length) {
                                valores.push([historial[index][5], historial[index][6] + historial[index][7]]);
                                break;
                            }
                        }
                    } else {
                        valores.push([historial[index][5], historial[index][6] + historial[index][7]]);
                    }
                }
                index++;
            }
        }
        MySQL.ejecutarQuery('CALL consultarEstadisticasVentasMes();', (err, result) => {
            if (err) {
                return res.json({
                    ok: false,
                    msj: 'Error en la consulta',
                });
            }
            let serviciosRealizadosLabels = [];
            let serviciosRealizadosSeries = [];
            if (result.length > 0) {
                index = 0;

                //Recorro cada registro
                while (result[0][index]) {
                    serviciosRealizadosLabels.unshift(capitalizar(result[0][index].mes));
                    serviciosRealizadosSeries.unshift(result[0][index].cantidadServicios);
                    index++;
                }
            }
            MySQL.ejecutarQuery('CALL consultarEstadisticasGananciaMes();', (err, result) => {
                if (err) {
                    return res.json({
                        ok: false,
                        msj: 'Error en la consulta',
                    });
                }
                let estadisticasGananciasLabels = [];
                let estadisticasGananciasSeries = [];
                if (result.length > 0) {
                    index = 0;

                    //Recorro cada registro
                    while (result[0][index]) {
                        estadisticasGananciasLabels.unshift(capitalizar(result[0][index].dia));
                        estadisticasGananciasSeries.unshift(result[0][index].gananciaServicios);
                        index++;
                    }
                }
                return res.json({
                    estadisticas: {
                        clientesTotales: clientesActivos,
                        serviciosMes: serviciosRealizados,
                        gananciasMes: gananciasMes,
                        domiciliariosTotales: domiciliariosActivos,
                    },
                    ventasMes: {
                        valores,
                    },
                    estadisticasGanancias: {
                        labels: estadisticasGananciasLabels,
                        series: [estadisticasGananciasSeries],
                    },
                    serviciosRealizados: {
                        labels: serviciosRealizadosLabels,
                        series: [serviciosRealizadosSeries],
                    },
                });
            });
        });
    });
};

module.exports = {
    dashboardADMINS,
    dashboardDOMICILIARIO,
    dashboardEstadisticasAdmin,
};
