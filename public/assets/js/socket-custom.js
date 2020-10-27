var socket = io({ transports: ['websocket'] });
//on = Escuchar Información
//emit = Emitir información

window.onbeforeunload = function (e) {
    socket.disconnect();
};

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

//----------------------------------------------
//             SERVICIOS
//----------------------------------------------
var idServicioGlobal;
socket.on('servicios', function (data) {
    //Comprobamos si hay servicios asignados
    if (data.ok) {
        console.log(data);
        idServicioGlobal = data.idServicio;
        $('#pathImageAdmin').attr('src', 'uploads/images/' + data.pathImageAdmin);
        $('#serviciosSinAsignar').show();
        $('#aceptarServicio').attr('disabled', false);
        $('#rechazarServicio').attr('disabled', false);
    } else {
        $('#serviciosSinAsignar').hide();
    }
});
