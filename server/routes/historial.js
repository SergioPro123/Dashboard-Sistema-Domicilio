const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');
const historialConstrollers = require('../controllers/historial');
//Renderizamos la seccion de historialDia
app.get('/historialDia', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            historialConstrollers.historialDiaAdministrador(req, res);
            break;
        case 'ADMIN':
            historialConstrollers.historialDiaAdministrador(req, res);
            break;
        case 'USER':
            historialConstrollers.historialDiaDomiciliario(req, res);
            break;
        default:
            return res.redirect('/dashboard');
            break;
    }
});

//Renderizamos la seccion de historialTemporal
app.get('/historialTemporal', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            return res.render('superAdmin/historialTemporal_superAdmin.hbs');
            break;
        case 'ADMIN':
            return res.render('admin/historialTemporal_admin.hbs');
            break;
        case 'USER':
            return res.render('domiciliario/historialTemporal_domiciliario.hbs');
            break;
        default:
            return res.redirect('/dashboard');
            break;
    }
});

//Renderizamos la seccion de historialTemporal
app.get('/historialTemporal/getData', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            historialConstrollers.historialTemporalAdministrador(req, res);
            break;
        case 'ADMIN':
            historialConstrollers.historialTemporalAdministrador(req, res);
            break;
        case 'USER':
            historialConstrollers.historialTemporalDomiciliario(req, res);
            break;
        default:
            return res.status(401).json({
                ok: false,
                msj: 'No Autorizado',
            });
    }
});

//Renderizamos la seccion de historialCliente
app.get('/historialCliente', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            return res.render('superAdmin/historialCliente_superAdmin.hbs');
            break;
        case 'ADMIN':
            return res.render('admin/historialCliente_admin.hbs');
            break;
        default:
            return res.redirect('/dashboard');
            break;
    }
});

//Renderizamos la seccion de historialDomiciliario
app.get('/historialDomiciliario', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            return res.render('superAdmin/historialDomiciliario_superAdmin.hbs');
            break;
        case 'ADMIN':
            return res.render('admin/historialDomiciliario_admin.hbs');
            break;
        default:
            return res.redirect('/dashboard');
            break;
    }
});

module.exports = {
    app,
};
