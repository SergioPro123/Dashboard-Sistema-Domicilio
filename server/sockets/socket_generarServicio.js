const { io } = require('../server');
const { Domiciliario } = require('../class/generarServicio');

const domiciliario = new Domiciliario(() => {
    console.log('ok');
});

io.on('connection', (client) => {
    //console.log(client.usuario);
    domiciliario.agregarUser(client.id, client.usuario.id_usuario, function (data) {
        //Comprobamos si hay data, lo que quiere decir que hay un servicio Disponible.
        if (data.ok) {
        }
    });
    console.log('Cliente Conectado');
    client.join(client.usuario.id_usuario);

    //Escuchamos al cliente
    client.on('enviarMensaje', (msj, callback) => {
        //console.log(msj);
    });

    client.on('chatSala', (msj) => {
        client.broadcast.emit('chatSala', msj);
    });

    //Enviamos información al Cliente
    client.emit('enviarMensaje', {
        usuario: client.id,
        mensaje: 'Bienvenido a mi aplicación.',
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
