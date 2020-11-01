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
            color:[]
        }
    },
    infoPersonal:{
        nombre
    },

}
*/
let valoresGlobalAdmin = [];

const { MySQL } = require('../database/mysql');
const { capitalizar, fechaInicioyFinMes, devolverFecha } = require('../functions/funciones');
const dashboardADMINS = (req, res, url) => {
    data(req, res, url);
};

const data = (req, res, url) => {
    let fechas = fechaInicioyFinMes();
    //let query = `CALL consultarServiciosTemporal('${fechas.desde}','${fechas.hasta}')`;
    let query = `CALL consultarServiciosTemporal('2020-10-1','2020-10-31')`;
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
        valoresGlobalAdmin = [];
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

                    if (valoresGlobalAdmin.length > 0) {
                        for (let j = 0; j < valoresGlobalAdmin.length; j++) {
                            if (historial[index][5] === valoresGlobalAdmin[j][0]) {
                                valoresGlobalAdmin[j][1] += historial[index][6] + historial[index][7];
                                break;
                            } else if (j + 1 == valoresGlobalAdmin.length) {
                                valoresGlobalAdmin.push([
                                    historial[index][5],
                                    historial[index][6] + historial[index][7],
                                    colorHEX(),
                                ]);
                                break;
                            }
                        }
                    } else {
                        valoresGlobalAdmin.push([
                            historial[index][5],
                            historial[index][6] + historial[index][7],
                            colorHEX(),
                        ]);
                    }
                }
                index++;
            }
        }
        return res.render(url, {
            data: {
                estadisticas: {
                    clientesTotales: [clientesActivos, 0],
                    serviciosMes: [serviciosRealizados, 0],
                    gananciasMes: [gananciasMes, 0],
                    domiciliariosTotales: [domiciliariosActivos, 0],
                },
                infoPersonal: {
                    nombre: capitalizar(req.usuario.nombre),
                },
                ventasMes: {
                    valores: valoresGlobalAdmin,
                },
            },
        });
    });
};

const dashboardDOMICILIARIO = (req, res) => {
    return res.render('domiciliario/dashboard_domiciliario.hbs', {
        data: {
            estadisticas: {
                clientesTotales: [999, 1],
                serviciosMes: [888, 0],
                gananciasMes: [123456, -1],
                domiciliariosTotales: [50, 5],
            },
            infoPersonal: {
                nombre: capitalizar(req.usuario.nombre),
            },
            ventasMes: {
                valores: [
                    ['Valor Prueba 1', 22, 'primary'],
                    ['Valor Prueba 2', 33, 'danger'],
                    ['Valor Prueba 3', 55, 'cyan'],
                    ['Valor Prueba 4', 99, 'success'],
                ],
            },
        },
    });
};

const dashboardEstadisticasAdmin = (req, res) => {
    let data = {
        estadistica: {
            ventasMes: {
                valores: valoresGlobalAdmin,
            },
            estadisticasGanancias: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                series: [[11, 10, 15, 21, 14, 23, 12]],
            },
            serviciosRealizados: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                series: [[5, 4, 3, 7, 10, 25]],
            },
        },
    };
    return res.json(data);
};

function generarLetra() {
    var letras = ['a', 'b', 'c', 'd', 'e', 'f', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var numero = (Math.random() * 15).toFixed(0);
    return letras[numero];
}

function colorHEX() {
    var coolor = '';
    for (var i = 0; i < 6; i++) {
        coolor = coolor + generarLetra();
    }
    return '#' + coolor;
}
module.exports = {
    dashboardADMINS,
    dashboardDOMICILIARIO,
    dashboardEstadisticasAdmin,
};
