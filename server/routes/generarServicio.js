const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');

const generarServicioController = require('../controllers/generarServicio');

//Renderizamos la seccion de generarServicio
app.get('/generarServicio', verificaToken, (req, res) => {
    generarServicioController.generarServicio(req, res);
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

//Devolvemos un archivo JSON, con las direccion del cliente requerido
app.get('/generarServicio/clientes/:idCliente', verificaToken, (req, res) => {
    generarServicioController.consultarDirecciones(req, res);
});

module.exports = {
    app,
};
