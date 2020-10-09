const express = require('express');
const app = express();
//Renderizamos la seccion de historialDia
app.get('/historialDia', (req, res) => {
    res.render('domiciliario/historialDia_domiciliario.hbs');
});

//Renderizamos la seccion de historialTemporal
app.get('/historialTemporal', (req, res) => {
    res.render('domiciliario/historialTemporal_domiciliario.hbs');
});

//Renderizamos la seccion de historialCliente
app.get('/historialCliente', (req, res) => {
    res.render('admin/historialCliente_admin.hbs');
});

//Renderizamos la seccion de historialDomiciliario
app.get('/historialDomiciliario', (req, res) => {
    res.render('admin/historialDomiciliario_admin.hbs');
});

module.exports = {
    app,
};
