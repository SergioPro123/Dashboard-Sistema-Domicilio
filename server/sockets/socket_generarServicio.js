const { io } = require('../server');
const { Domiciliario } = require('../class/generarServicio');

const domiciliario = new Domiciliario(() => {
    io.on('connection', (client) => {
        client.join('id-' + client.usuario.id_usuario);
        domiciliario.agregarUser(client.id, client.usuario.id_usuario, function (data) {
            //Comprobamos si hay data, lo que quiere decir que hay un servicio Disponible.
            if (data.ok) {
                //Verificamos si es un servicio por asignar o ya asignado, ya que de esto depende de mostrar
                //la informacion completa
                if (data.servicio.servicio[3] == 'SIN_ASIGNAR') {
                    //Emitimos al cliente, que tiene un servicio pendiente por aceptar.
                    io.to('id-' + client.usuario.id_usuario).emit('servicios', {
                        ok: true,
                        idServicio: data.servicio.servicio['idServicio'],
                        pathImageAdmin: data.servicio.servicio[13],
                    });
                } else if (data.servicio.servicio[3] == 'ASIGNADO') {
                    //Emitimos al cliente, que tiene un servicio pendiente por  culminar.
                    io.to('id-' + client.usuario.id_usuario).emit('serviciosDetalles', {
                        ok: true,
                        idServicio: data.servicio.servicio['idServicio'],
                        servicio: data.servicio,
                    });
                } else {
                    io.to('id-' + client.usuario.id_usuario).emit('serviciosDetalles', {
                        ok: false,
                    });
                }
            } else {
                //Emitimos al cliente diciendole que no hay servicios por ahora
                io.to('id-' + client.usuario.id_usuario).emit('servicios', {
                    ok: false,
                    msj: data.msj,
                });
            }
        });

        //---------Respuesta de los Domiciliarios-----------
        client.on('aceptarServicio', (idServicio, callback) => {
            domiciliario.aceptarServicio(idServicio, client.usuario.id_usuario, function (data) {
                //Si llega un respuesta TRUE, es porque se comprobo que ese servicio pertenece a ese domiciliario
                // y se procede a devolver los detalles.
                if (data.ok) {
                    return callback({
                        ok: true,
                        servicio: data.servicio,
                    });
                } else {
                    return callback({ ok: false });
                }
            });
        });
        client.on('rechazarServicio', (idServicio, callback) => {
            domiciliario.rechazarServicio(idServicio, client.usuario.id_usuario, function (data) {
                //Si hay un nuevo domiciliario, enviara TRUE, lo que significa que le retornamos ese servicio al nuevo domiciliario
                if (data.ok) {
                    io.to('id-' + data.nuevoDomiciliario).emit('servicios', {
                        ok: true,
                        idServicio: data.servicio.idServicio,
                        pathImageAdmin: data.servicio[13],
                    });
                }
                callback();
            });
        });
        client.on('concluirServicio', (idServicio, callback) => {
            domiciliario.concluirServicio(idServicio, client.usuario.id_usuario, function (data) {
                //despues de haber concluido el servicio, si devuelve TRUE, es porque existe otro servicio por aceptar.
                if (data.ok) {
                    io.to('id-' + client.usuario.id_usuario).emit('servicios', {
                        ok: true,
                        idServicio: data.servicio.servicio.idServicio,
                        pathImageAdmin: data.servicio.servicio[13],
                    });
                }
                callback();
            });
        });

        //---------Eventos del Socket-----------

        client.on('disconnect', () => {
            domiciliario.borrarUserByIdSocket(client.id);
        });
    });
});

const generarServicio = (req, res) => {
    io.to('domiciliarios').emit('enviarMensaje', {
        msj: 'hola Domiciliario',
    });
    console.log(req.body);
    return res.json({ ok: true });
};

module.exports = {
    generarServicio,
};
