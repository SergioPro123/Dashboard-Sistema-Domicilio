const express = require('express');
const app = express();
//Renderizamos la seccion de tipoServicios
app.get('/tipoServicios', (req, res) => {
    res.render('superAdmin/tipoServicios.hbs');
});

module.exports = {
    app,
};
