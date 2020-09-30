const express = require('express');
const app = express();
//Renderizamos la seccion de historialDia
app.get('/historialDia', (req, res) => {
    res.render('historialDia_admin.hbs');
});

//Renderizamos la seccion de historialTemporal
app.get('/historialTemporal', (req, res) => {
    res.render('historialTemporal_admin.hbs');
});

//Renderizamos la seccion de historialCliente
app.get('/historialCliente', (req, res) => {
    res.render('historialCliente_admin.hbs');
});

//Renderizamos la seccion de historialDomiciliario
app.get('/historialDomiciliario', (req, res) => {
    res.render('historialDomiciliario_admin.hbs');
});

module.exports = {
    app,
};
