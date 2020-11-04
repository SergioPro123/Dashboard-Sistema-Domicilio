const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');
const generarLiquidacionConstrollers = require('../controllers/generarLiquidacion');

//Esta API, obtiene informacion desde la base de datos sobre el historial del dia.
app.post('/liquidacionDiaPDF', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            generarLiquidacionConstrollers.liquidacionDiaAdministrador(req, res);
            break;
        case 'ADMIN':
            generarLiquidacionConstrollers.liquidacionDiaAdministrador(req, res);
            break;
        case 'USER':
            generarLiquidacionConstrollers.liquidacionDiaDomiciliario(req, res);
            break;
        default:
            return res.status(401).json({
                ok: false,
                msj: 'No Autorizado',
            });
    }
});
//Esta API, obtiene informacion desde la base de datos sobre el historial temporal.
app.post('/liquidacionTemporalPDF', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            generarLiquidacionConstrollers.liquidacionTemporalAdministrador(req, res);
            break;
        case 'ADMIN':
            generarLiquidacionConstrollers.liquidacionTemporalAdministrador(req, res);
            break;
        case 'USER':
            generarLiquidacionConstrollers.liquidacionTemporalDomiciliario(req, res);
            break;
        default:
            return res.status(401).json({
                ok: false,
                msj: 'No Autorizado',
            });
    }
});

//Esta API, obtiene informacion desde la base de datos sobre el historial de algun cliente.
app.post('/liquidacionClientePDF', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            generarLiquidacionConstrollers.liquidacionClienteData(req, res);
            break;
        case 'ADMIN':
            generarLiquidacionConstrollers.liquidacionClienteData(req, res);
            break;
        default:
            return res.status(401).json({
                ok: false,
                msj: 'No Autorizado',
            });
    }
});

//Esta API, obtiene informacion desde la base de datos sobre el historial de algun Domiciliario.
app.post('/liquidacionDomiciliarioPDF', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            generarLiquidacionConstrollers.liquidacionDomiciliarioData(req, res);
            break;
        case 'ADMIN':
            generarLiquidacionConstrollers.liquidacionDomiciliarioData(req, res);
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
