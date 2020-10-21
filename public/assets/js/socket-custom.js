var socket = io();
//on = Escuchar Información
//emit = Emitir información

socket.on('connect', function () {
    console.log('Conectado al Servidor');
});

socket.on('disconnect', function () {
    console.log('Perdimos conexion con el Servidor');
});

socket.emit(
    'enviarMensaje',
    {
        usuario: 'Sergio Aparicio',
        mensaje: 'Hola Mundo!!',
    },
    function () {
        console.log('Se disparo el Callback');
    }
);

socket.on('enviarMensaje', function (data) {
    console.log(data);
});
