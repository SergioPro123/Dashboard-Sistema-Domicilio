const express = require('express');
const app = express();
//Renderizamos la seccion de Servicios, del domiciliario
app.get('/servicios', (req, res) => {
    res.render('domiciliario/servicios_domiciliario.hbs');
});

module.exports = {
    app,
};
