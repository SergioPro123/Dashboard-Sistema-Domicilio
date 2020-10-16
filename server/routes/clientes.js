const express = require('express');
const app = express();

let path = require('path');

const { verificaToken } = require('../middlewares/autenticacion');
const clientesControllers = require('../controllers/clientes');

//Renderizamos la seccion de cliente
app.get('/clientes', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        clientesControllers.consultarClientes(req, res);
    } else {
        return res.redirect('/dashboard');
    }
});

//Agregamos un nuevo cliente a la Base de Datos
app.post('/clientes', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        clientesControllers.agregarClientes(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
});
//Actualizamos datos de un cliente
app.put('/clientes', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        clientesControllers.actualizarClientes(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
});

module.exports = {
    app,
};
