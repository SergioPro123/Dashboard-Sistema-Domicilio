const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');
const historialConstrollers = require('../controllers/historial');
//Renderizamos la seccion de historialDia
app.get('/historialDia', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            historialConstrollers.historialDiaAdministrador(req, res, 'superAdmin/historialTemporal_superAdmin.hbs');
            break;
        case 'ADMIN':
            historialConstrollers.historialDiaAdministrador(req, res, 'admin/historialDia_admin.hbs');
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

//Esta API, obtiene informacion desde la base de datos sobre el historial temporal.
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
            historialConstrollers.historialClienteAdministrador(req, res, 'superAdmin/historialCliente_superAdmin.hbs');
            break;
        case 'ADMIN':
            historialConstrollers.historialClienteAdministrador(req, res, 'admin/historialCliente_admin.hbs');
            break;
        default:
            return res.redirect('/dashboard');
            break;
    }
});

//Esta API, obtiene informacion desde la base de datos sobre el historial de algun cliente.
app.get('/historialCliente/getData', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            historialConstrollers.historialClienteData(req, res);
            break;
        case 'ADMIN':
            historialConstrollers.historialClienteData(req, res);
            break;
        default:
            return res.status(401).json({
                ok: false,
                msj: 'No Autorizado',
            });
    }
});

//Renderizamos la seccion de historialDomiciliario
app.get('/historialDomiciliario', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            historialConstrollers.historialDomiciliarioAdministrador(
                req,
                res,
                'superAdmin/historialDomiciliario_superAdmin.hbs'
            );
            break;
        case 'ADMIN':
            historialConstrollers.historialDomiciliarioAdministrador(req, res, 'admin/historialDomiciliario_admin.hbs');
            break;
        default:
            return res.redirect('/dashboard');
            break;
    }
});

//Esta API, obtiene informacion desde la base de datos sobre el historial de algun Domiciliario.
app.get('/historialDomiciliario/getData', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            historialConstrollers.historialDomiciliarioData(req, res);
            break;
        case 'ADMIN':
            historialConstrollers.historialDomiciliarioData(req, res);
            break;
        default:
            return res.status(401).json({
                ok: false,
                msj: 'No Autorizado',
            });
    }
});

module.exports = {
    app,
};
