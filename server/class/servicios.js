const { MySQL } = require('../database/mysql');
const { capitalizar, devolverFecha } = require('../functions/funciones');
class Servicio {
    constructor(callback) {
        this.servicios = [];
        this.servicionEnProceso = [];
        //Cada vez que se reinicia el servidor, este busca en la base de datos si quedaron servicios
        //sin asignar.
        this.getServiciosAsignados(() => {
            this.getServiciosSinAsignar(callback);
        });
    }
    getServiciosSinAsignar(callback) {
        this.servicios = [];
        //Buscamos en la base de datos, los servicios que no estan asignados aún y lo agregamos a nuestra
        //propiedad "this.servicios"
        MySQL.ejecutarQuery('CALL consultarServicios_SINASIGNAR();', (err, result) => {
            if (err) {
                return callback({
                    ok: false,
                });
            }
            //Verifico que haya devuelto datos
            if (result.length > 0) {
                let index = 0;
                //Recorro cada registro
                while (result[0][index]) {
                    let idServicio = result[0][index].id_servicios;
                    this.servicios[index] = [];
                    this.servicios[index][0] = capitalizar(result[0][index].nombreAdmin);
                    this.servicios[index][1] = capitalizar(result[0][index].nombreDomiciliario);
                    this.servicios[index][2] = capitalizar(result[0][index].nombreCliente);
                    this.servicios[index][3] = result[0][index].estadoservicio;
                    this.servicios[index][4] = capitalizar(result[0][index].direccion);
                    this.servicios[index][5] = capitalizar(result[0][index].tiposervicio);
                    this.servicios[index][6] = result[0][index].valorServicio;
                    this.servicios[index][7] = result[0][index].valorAdicional;
                    this.servicios[index][8] = result[0][index].descripcion;
                    this.servicios[index][9] = devolverFecha(result[0][index].Fecha);
                    this.servicios[index][10] = result[0][index].horaInicio;
                    this.servicios[index][11] = result[0][index].horaFinal;
                    this.servicios[index][12] = result[0][index].celularCliente;
                    this.servicios[index][13] = result[0][index].pathImageAdmin;
                    this.servicios[index]['idServicio'] = idServicio;
                    this.servicios[index]['solicitado'] = false;

                    index++;
                }
                callback({
                    ok: true,
                });
            }
        });
    }

    getServiciosAsignados(callback) {
        this.servicionEnProceso = [];
        //Buscamos en la base de datos, los servicios que no estan asignados aún y lo agregamos a nuestra
        //propiedad "this.servicios"
        MySQL.ejecutarQuery('CALL consultarServicios_ASIGNADO();', (err, result) => {
            if (err) {
                return callback({
                    ok: false,
                });
            }
            //Verifico que haya devuelto datos
            if (result.length > 0) {
                let index = 0;
                //Recorro cada registro
                while (result[0][index]) {
                    let idServicio = result[0][index].id_servicios;
                    this.servicionEnProceso[index] = [];
                    this.servicionEnProceso[index][0] = capitalizar(result[0][index].nombreAdmin);
                    this.servicionEnProceso[index][1] = capitalizar(result[0][index].nombreDomiciliario);
                    this.servicionEnProceso[index][2] = capitalizar(result[0][index].nombreCliente);
                    this.servicionEnProceso[index][3] = result[0][index].estadoservicio;
                    this.servicionEnProceso[index][4] = capitalizar(result[0][index].direccion);
                    this.servicionEnProceso[index][5] = capitalizar(result[0][index].tiposervicio);
                    this.servicionEnProceso[index][6] = result[0][index].valorServicio;
                    this.servicionEnProceso[index][7] = result[0][index].valorAdicional;
                    this.servicionEnProceso[index][8] = result[0][index].descripcion;
                    this.servicionEnProceso[index][9] = devolverFecha(result[0][index].Fecha);
                    this.servicionEnProceso[index][10] = result[0][index].horaInicio;
                    this.servicionEnProceso[index][11] = result[0][index].horaFinal;
                    this.servicionEnProceso[index][12] = result[0][index].celularCliente;
                    this.servicionEnProceso[index][13] = result[0][index].pathImageAdmin;
                    this.serviciosEnProceso[index]['idServicio'] = idServicio;
                    this.serviciosEnProceso[index]['solicitado'] = true;
                    index++;
                }
                callback({
                    ok: true,
                });
            }
        });
    }

    cancelarServicio(idServicio, callback) {
        idServicio = MySQL.instance.conexion.escape(idServicio);
        let query = `CALL cancelarServicio(${idServicio});`;
        MySQL.ejecutarQuery(query, (err, result) => {
            if (err) {
                let response = {
                    ok: false,
                    msj: 'No se pudo cancelar el servicio',
                };
                callback(response);
            } else {
                //Recorreomos el array con la intencion de buscar la posicion donde se encuentra ese servicio
                for (let i = 0; i < this.serviciosEnProceso.length; i++) {
                    if (this.serviciosEnProceso['idServicio'] == data.idServicio) {
                        this.serviciosEnProceso.splice(i, 1);
                        return callback({
                            ok: true,
                        });
                    }
                }
                for (let i = 0; i < this.servicios.length; i++) {
                    if (this.servicios['idServicio'] == data.idServicio) {
                        this.servicios.splice(i, 1);
                        return callback({
                            ok: true,
                        });
                    }
                }
            }
        });
    }

    aceptarServicio(data, callback) {
        let idServicio = MySQL.instance.conexion.escape(data.idServicio);
        let idDomiciliario = MySQL.instance.conexion.escape(data.idDomiciliario);

        let query = `CALL aceptarServicio(${idServicio},${idDomiciliario});`;
        MySQL.ejecutarQuery(query, (err, result) => {
            if (err) {
                let response = {
                    ok: false,
                    msj: 'No se pudo aceptar el  servicio',
                };
                return callback(response);
            } else {
                //Recorreomos el array con la intencion de buscar la posicion donde se encuentra ese servicio
                let indexServicioAceptado;
                for (let i = 0; i < this.servicios.length; i++) {
                    if (this.servicios['idServicio'] == data.idServicio) {
                        indexServicioAceptado = i;
                        break;
                    }
                }
                //Pasamos el servicio que esta sin asignar, al objeto que contiene los servicios ya asignados.
                this.servicionEnProceso.push(this.servicios[indexServicioAceptado]);
                this.servicios.splice(indexServicioAceptado, 1);
                callback({
                    ok: true,
                });
            }
        });
    }

    concluirServicio(data, callback) {
        let idServicio = MySQL.instance.conexion.escape(data.idServicio);
        let query = `CALL concluirServicio(${idServicio});`;
        MySQL.ejecutarQuery(query, (err, result) => {
            if (err) {
                let response = {
                    ok: false,
                    msj: 'No se pudo concluir el  servicio',
                };
                return callback(response);
            } else {
                //Recorreomos el array con la intencion de buscar la posicion donde se encuentra ese servicio
                for (let i = 0; i < this.serviciosEnProceso.length; i++) {
                    if (this.serviciosEnProceso['idServicio'] == data.idServicio) {
                        this.serviciosEnProceso.splice(i, 1);
                        break;
                    }
                }
                callback({
                    ok: true,
                });
            }
        });
    }

    agregarServicio(data, callback) {
        let idCliente = MySQL.instance.conexion.escape(data.idCliente);
        let idAdmin = MySQL.instance.conexion.escape(data.idAdmin);
        let direccion = MySQL.instance.conexion.escape(data.direccion);
        let tipoServicio = MySQL.instance.conexion.escape(data.tipoServicio);
        let valorTipoServicio = MySQL.instance.conexion.escape(data.valorTipoServicio);
        let descripcion = MySQL.instance.conexion.escape(data.descripcion);
        let adicional = MySQL.instance.conexion.escape(data.adicional);

        let query = `CALL generarServicio(${idCliente}, ${idAdmin}, ${direccion}, ${tipoServicio},${valorTipoServicio},${descripcion}, ${adicional});`;
        MySQL.ejecutarQuery(query, (err, result) => {
            if (err) {
                let response = {
                    ok: false,
                    msj: 'No se pudo generar un nuevo servicio',
                };
                return callback(response);
            } else {
                this.getServiciosSinAsignar(callback);
            }
        });
    }

    get solicitarServicio() {
        //Recorremos los servicios SIN ASIGNAR, para devolver y ponemos en estado SOLICITADO (mas no asignado)
        for (let i = 0; i < this.servicios.length; i++) {
            //Buscamos algun servicio disponible
            if (!this.servicios[i].solicitado) {
                this.servicios[i].solicitado = true;
                return this.servicios[i];
            }
        }
        //Si llega aca, es porque no hay servicios SIN ASIGNAR, devolvemos array vacio.
        return [];
    }

    devolverServicio(idServicio) {
        //Esta funcion vuelve a poner un servicio a disposicion de los domiciliarios,
        //por lo regular se usa cuando se rechaza un servicio por parte de los domiciliarios
        // y no se encuentra otro domiciliario a asignarle, entonces se devuelve a esta clase.
        for (let i = 0; i < this.servicios.length; i++) {
            if (this.servicios[i].idServicio == idServicio) {
                this.servicios[i].solicitado = false;
                return;
            }
        }
    }
}

module.exports = {
    Servicio,
};
