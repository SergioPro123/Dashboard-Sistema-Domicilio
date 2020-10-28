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
    console.log('okkk');
    //Comprobamos si hay servicios asignados
    if (data.ok) {
        console.log(data);
        idServicioGlobal = data.idServicio;
        $('#ServicioDetalle').hide();
        $('#pathImageAdmin').attr('src', 'uploads/images/' + data.pathImageAdmin);
        $('#serviciosSinAsignar').show();
        $('#aceptarServicio').attr('disabled', false);
        $('#rechazarServicio').attr('disabled', false);
    } else {
        $('#serviciosSinAsignar').hide();
    }
});

socket.on('serviciosDetalles', function (data) {
    //Comprobamos si hay servicios asignados
    if (data.ok) {
        console.log(data);
        idServicioGlobal = data.idServicio;
        $('#pathImageAdminServicio').attr('src', 'uploads/images/' + data.servicio.servicio[13]);
        $('#clienteServicio').text(data.servicio.servicio[2]);
        $('#direccionServicio').text(data.servicio.servicio[4]);
        $('#celularServicio').text(data.servicio.servicio[12]);
        $('#tipoServicioServicio').text(data.servicio.servicio[5]);
        $('#descripcionServicio').text(data.servicio.servicio[8]);
        $('#valorServicio').text('$ ' + data.servicio.servicio[6]);
        $('#adicionalServicio').text('$ ' + data.servicio.servicio[7]);
        $('#valorTotalServicio').text('$ ' + (data.servicio.servicio[6] + data.servicio.servicio[7]));
        $('#concluirServicio').attr('disabled', false);
        $('#ServicioDetalle').show();
    } else {
        $('#ServicioDetalle').hide();
    }
});
