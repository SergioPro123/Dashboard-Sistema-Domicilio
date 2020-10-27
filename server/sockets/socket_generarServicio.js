const { io } = require('../server');
const { Domiciliario } = require('../class/generarServicio');

const domiciliario = new Domiciliario(() => {});

io.on('connection', (client) => {
    //console.log('Cliente Conectado: ', client.usuario.id_usuario);
    client.join('id-' + client.usuario.id_usuario);
    //console.log(client.usuario);
    domiciliario.agregarUser(client.id, client.usuario.id_usuario, function (data) {
        //Comprobamos si hay data, lo que quiere decir que hay un servicio Disponible.
        if (data.ok) {
            //Verificamos si es un servicio por asignar o ya asignado, ya que de esto depende de mostrar
            //la informacion completa
            if (data.servicio.servicio[3] == 'SIN_ASIGNAR') {
                //console.log(data);
                //Emitimos al cliente, que tiene un servicio pendiente por aceptar.
                io.to('id-' + client.usuario.id_usuario).emit('servicios', {
                    ok: true,
                    idServicio: data.servicio.servicio['idServicio'],
                    pathImageAdmin: data.servicio.servicio[13],
                });
            } else {
                //Emitimos al cliente, que tiene un servicio pendiente por  culminar.
                io.to('id-' + client.usuario.id_usuario).emit('servicios', {
                    ok: true,
                    servicio: data.servicio,
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
        domiciliario.aceptarServicio(idServicio, client.usuario.id_usuario, function () {
            callback();
        });
    });
    client.on('rechazarServicio', (idServicio, callback) => {
        domiciliario.rechazarServicio(idServicio, client.usuario.id_usuario, function (data) {
            //Si hay un nuevo domiciliario, enviara TRUE, lo que significa que le retornamos ese servicio al nuevo domiciliario
            console.log(data);

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

    //---------Eventos del Socket-----------

    client.on('disconnect', () => {
        domiciliario.borrarUserByIdSocket(client.id);
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
