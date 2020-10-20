const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');
const tipoServiciosControllers = require('../controllers/tipoServicios');

//Renderizamos la seccion de tipoServicios
app.get('/tipoServicios', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        tipoServiciosControllers.renderTipoServicios(req, res);
    }
});

//Eliminamos tipoServicios
app.post('/tipoServicios', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        tipoServiciosControllers.agregarTipoServicios(req, res);
    }
});

//Actualizamos tipoServicios
app.put('/tipoServicios', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        tipoServiciosControllers.actualizarTipoServicios(req, res);
    }
});

//Eliminamos tipoServicios
app.delete('/tipoServicios', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        tipoServiciosControllers.eliminarTipoServicios(req, res);
    }
});
module.exports = {
    app,
};
