const express = require('express');
const app = express();
//Renderizamos la seccion de cliente
app.get('/clientes', (req, res) => {
    res.render('admin/clientes_admin.hbs');
});

//Renderizamos la seccion de domiciliario
app.get('/domiciliario', (req, res) => {
    res.render('admin/domiciliarios_admin.hbs');
});

module.exports = {
    app,
};
