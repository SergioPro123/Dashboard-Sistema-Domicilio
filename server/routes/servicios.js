const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');

//Renderizamos la seccion de Servicios, del domiciliario
app.get('/servicios', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'USER') {
        return res.render('domiciliario/servicios_domiciliario.hbs');
    } else {
        return res.redirect('/dashboard');
    }
});

module.exports = {
    app,
};
