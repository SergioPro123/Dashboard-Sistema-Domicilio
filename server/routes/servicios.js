const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');
const { capitalizar } = require('../functions/funciones');
//Renderizamos la seccion de Servicios, del domiciliario
app.get('/servicios', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'USER') {
        return res.render('domiciliario/servicios_domiciliario.hbs', {
            data: {
                infoPersonal: {
                    nombre: capitalizar(req.usuario.nombre),
                    pathImage: req.usuario.pathImage,
                },
            },
        });
    } else {
        return res.redirect('/dashboard');
    }
});

module.exports = {
    app,
};
