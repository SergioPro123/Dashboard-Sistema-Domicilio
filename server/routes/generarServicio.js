const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');

const generarServicioController = require('../controllers/generarServicio');
const generarServicioControllerSockets = require('../sockets/socket_generarServicio');

//Renderizamos la seccion de generarServicio
app.get('/generarServicio', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        generarServicioController.renderGenerarServicio(req, res);
    } else {
        return res.redirect('/dashboard');
    }
});

//Devolvemos un archivo JSON, con las direccion del cliente requerido
app.get('/generarServicio/clientes/:idCliente', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        generarServicioController.consultarDirecciones(req, res);
    }
});

//Devolvemos un archivo JSON, con las direccion del cliente requerido
app.post('/generarServicio', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        generarServicioControllerSockets.generarServicio(req, res);
    }
});
//Devolvemos un archivo JSON, con los clientes y sus ID
/* app.get('/generarServicio/clientes', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        let data = {
            results: [
                {
                    id: 1,
                    text: 'Option 1',
                },
                {
                    id: 2,
                    text: 'Option 2',
                },
            ],
        };
        return res.json(data);
    } 
}); */

module.exports = {
    app,
};
