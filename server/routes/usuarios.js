const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');

const usuariosFunciones = require('../controllers/usuarios');
//Renderizamos la seccion de cliente
app.get('/clientes', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        usuariosFunciones.consultarClientes(req, res);
    } else {
        return res.redirect('/dashboard');
    }
});

//Agregamos un nuevo cliente a la Base de Datos
app.post('/clientes', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        usuariosFunciones.agregarClientes(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
});
//Actualizamos datos
app.put('/clientes', verificaToken, (req, res) => {
    console.log('update');
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        usuariosFunciones.actualizarClientes(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
});

//Renderizamos la seccion de domiciliario
app.get('/domiciliarios', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        usuariosFunciones.domiciliarios(req, res);
    } else {
        return res.redirect('/dashboard');
    }
});

//Renderizamos la seccion de domiciliario
app.get('/administradores', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        usuariosFunciones.administradores(req, res);
    } else {
        return res.redirect('/dashboard');
    }
});
module.exports = {
    app,
};
