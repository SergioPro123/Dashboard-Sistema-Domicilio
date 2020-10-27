const { Servicio } = require('./servicios');

class serviciosAsignados {
    constructor(idDomiciliario, servicio) {
        this.idDomiciliario = idDomiciliario;
        this.servicio = servicio;
    }
}

class Domiciliario {
    constructor(callback) {
        //Esta propiedad, almacena los usuarios conectados en sockets
        this.user = [];
        //Esta propiedad, almacena los usuarios conectados en sockets, la diferencia es que no repides ID de usuarios.
        //Tambien sera referencia del orden de los domiciliarios
        this.userUnique = [];
        //Esta propiedad, almacena los domiciliarios con un servicio en espera de aceptacion
        this.servicioSinAceptar = [];
        //Esta propiedad, almacena los domiciliarios con un servicio en estado de ejecucion
        this.serviciosAceptados = [];
        //Instancia de la Clase Servicio
        this.servicio = new Servicio(() => {
            callback();
        });
    }

    aceptarServicio(idServicio, idDomiciliario, callback) {
        console.log('Servicio aceptado:' + idServicio + '  -  ' + idDomiciliario);
        callback();
    }

    rechazarServicio(idServicio, idDomiciliario, callback) {
        console.log('Servicio rechazado:', this.servicioSinAceptar);
        console.log('Usuarios en cola:', this.userUnique);

        //Si por alguna razon no hay usuarios, entonces se devuelve el servicio
        if (this.userUnique.length == 0) {
            this.servicio.devolverServicio(idServicio);
            this.servicioSinAceptar = this.servicioSinAceptar.filter(
                (servicio) => servicio.servicio.idServicio != idServicio
            );
            return callback({
                ok: false,
            });
        }
        //Recorremos todos los usuarios almacenados en UserUnique, para asignarle este servicio recien rechazado
        for (let i = 0; i < this.userUnique.length; i++) {
            if (this.userUnique[i].idUser == idDomiciliario) {
                //Volvemos a hacer el ciclo para respetar el turno
                for (let j = i; j < this.userUnique.length; j++) {
                    //revisamos si el usuario ya tiene un servicio por aceptar o por realizar
                    let servicioSinAceptar =
                        this.servicioSinAceptar.find(
                            (servicio) => servicio.idDomiciliario === this.userUnique[j].idUser
                        ) ||
                        this.serviciosAceptados.find(
                            (servicio) => servicio.idDomiciliario === this.userUnique[j].idUser
                        );
                    if (servicioSinAceptar == undefined) {
                        //Si entra aca, es por que se encontro un domiciliario en espera de servicios.
                        let servicioActualizado;
                        this.servicioSinAceptar = this.servicioSinAceptar.filter((servicio) => {
                            if (servicio.servicio.idServicio == idServicio) {
                                servicio.idDomiciliario = this.userUnique[j].idUser;
                                servicioActualizado = servicio.servicio;
                            }
                            return true;
                        });
                        return callback({
                            ok: true,
                            nuevoDomiciliario: this.userUnique[j].idUser,
                            servicio: servicioActualizado,
                        });
                    }
                }
            }
        }
        //Si llega aca, es porque ya paso por todos los domiciliarios, lo que hace es volver desde el principio a asignar ese servicio
        for (let i = 0; i < this.userUnique.length; i++) {
            //revisamos si el usuario ya tiene un servicio por aceptar o por realizar
            let servicioSinAceptar =
                this.servicioSinAceptar.find((servicio) => servicio.idDomiciliario === this.userUnique[i].idUser) ||
                this.serviciosAceptados.find((servicio) => servicio.idDomiciliario === this.userUnique[i].idUser);
            if (servicioSinAceptar == undefined) {
                //Si entra aca, es por que se encontro un domiciliario en espera de servicios.
                let servicioActualizado;
                this.servicioSinAceptar = this.servicioSinAceptar.filter((servicio) => {
                    if (servicio.servicio.idServicio == idServicio) {
                        servicio.idDomiciliario = this.userUnique[i].idUser;
                        servicioActualizado = servicio.servicio;
                    }
                    return true;
                });
                return callback({
                    ok: true,
                    nuevoDomiciliario: this.userUnique[i].idUser,
                    servicio: servicioActualizado,
                });
            }
        }
        callback({ ok: false });
    }

    agregarUser(idSocket, idUser, callback) {
        //Agregamos la nueva conexion a nuestro array de domiciliarios
        let persona = { idSocket, idUser };
        this.user.push(persona);
        //Invocamos a la funcion que se encarga de registrar los usuarios unicos
        this.agregarUserUnique(persona, callback);

        return this.user;
    }

    agregarUserUnique(persona, callback) {
        //Verificamos que esa nueva conexion no exista en la variable UserUnique
        for (let i = 0; i < this.userUnique.length; i++) {
            if (this.userUnique[i].idUser == persona.idUser) {
                //revisamos si el usuario ya tiene un servicio por aceptar o por realizar
                let servicioSinAceptar =
                    this.servicioSinAceptar.find((servicio) => servicio.idDomiciliario === persona.idUser) ||
                    this.serviciosAceptados.find((servicio) => servicio.idDomiciliario === persona.idUser);
                if (servicioSinAceptar == undefined) {
                    return callback({ ok: false, msj: 'No hay servicios Disponibles', idDomiciliario: persona.idUser });
                } else {
                    return callback({ ok: true, servicio: servicioSinAceptar });
                }
            }
        }
        //Si llega aca es porque no esta registrado, y procedemos a registrarlo
        this.userUnique.push(persona);

        //revisamos si el usuario ya tiene un servicio por aceptar o por realizar
        let servicioSinAceptar =
            this.servicioSinAceptar.find((servicio) => servicio.idDomiciliario === persona.idUser) ||
            this.serviciosAceptados.find((servicio) => servicio.idDomiciliario === persona.idUser);

        if (servicioSinAceptar != undefined) {
            return callback({ ok: true, servicio: servicioSinAceptar });
        } else {
            //Solicitamos un servicio
            let servicio = this.servicio.solicitarServicio;
            //Preguntamos si hay un servicio
            if (servicio.length > 0) {
                //Asigmanos un servicio al usuario, en espera que lo acepte
                let servicioSinAceptar = new serviciosAsignados(persona.idUser, servicio);
                this.servicioSinAceptar.push(servicioSinAceptar);
                return callback({ ok: true, servicio: servicioSinAceptar });
            } else {
                return callback({ ok: false, msj: 'No hay servicios Disponibles.', idDomiciliario: persona.idUser });
            }
        }
    }

    getUserByIdSocket(idSocket) {
        let persona = this.user.filter((persona) => {
            return persona.idSocket === idSocket;
        })[0];
        return persona;
    }

    borrarUserByIdSocket(idSocket) {
        let personaBorrada = this.getUserByIdSocket(idSocket);
        //Borramos ese usuario
        this.user = this.user.filter((persona) => {
            return persona.idSocket != idSocket;
        });
        //Borramos tambien ese usuario de la variable UserUnique
        this.userUnique = this.userUnique.filter((persona) => {
            //Este proceso se hace con el fin de verificar si existe el usuario con el mismo ID
            //conectado desde otro dispositivo, para reemplazar su idSocket en el UserUnique
            if (persona.idSocket == idSocket) {
                for (let i = 0; i < this.user.length; i++) {
                    if (persona.idUser == this.user[i].idUser) {
                        persona.idSocket = this.user[i].idSocket;
                        return true;
                    } else {
                        return false;
                    }
                }
            }
            return persona.idSocket != idSocket;
        });
        return personaBorrada;
    }
}

module.exports = {
    Domiciliario,
};
