const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');

const usuariosFunciones = require('../controllers/usuarios');
//Renderizamos la seccion de cliente
app.get('/clientes', verificaToken, (req, res) => {
    usuariosFunciones.clientes(req, res);
});

//Renderizamos la seccion de domiciliario
app.get('/domiciliarios', verificaToken, (req, res) => {
    usuariosFunciones.domiciliarios(req, res);
});

//Renderizamos la seccion de domiciliario
app.get('/administradores', verificaToken, (req, res) => {
    usuariosFunciones.administradores(req, res);
});
module.exports = {
    app,
};
