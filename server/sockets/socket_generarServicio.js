const { io } = require('../server');

io.on('connection', (client) => {
    console.log('Cliente Conectado');
    client.join('domiciliarios');

    client.on('generarServicio_Admin', () => {
        console.log('Cliente desconectado');
    });

    //Escuchamos al cliente
    client.on('enviarMensaje', (msj, callback) => {
        console.log(msj);
    });

    client.on('chatSala', (msj) => {
        client.broadcast.emit('chatSala', msj);
    });

    //Enviamos información al Cliente
    client.emit('enviarMensaje', {
        usuario: client.id,
        mensaje: 'Bienvenido a mi aplicación.',
    });
});
const generarServicio = (req, res) => {
    io.to('domiciliarios').emit('enviarMensaje', {
        msj: 'hola explorer',
    });
};

module.exports = {
    generarServicio,
};
