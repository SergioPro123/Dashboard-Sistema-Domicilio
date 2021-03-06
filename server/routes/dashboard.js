const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');
const dashboard = require('../controllers/dashboard');

//Renderizamos la seccion de DASHBOARD
app.get('/dashboard', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            dashboard.dashboardADMINS(req, res, 'superAdmin/dashboard_superAdmin.hbs');
            break;
        case 'ADMIN':
            dashboard.dashboardADMINS(req, res, 'admin/dashboard_admin.hbs');
            break;
        case 'USER':
            //Por ahora, por ser un prototipo mostramos el mismo dashboard de admins a los domiciliarios
            //dashboard.dashboardDOMICILIARIO(req, res);
            dashboard.dashboardADMINS(req, res, 'domiciliario/dashboard_domiciliario.hbs');
            break;
        default:
            res.redirect('/login');
            break;
    }
});

app.get('/dashboard/estadisticas', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            dashboard.dashboardEstadisticasAdmin(req, res);
            break;
        case 'ADMIN':
            dashboard.dashboardEstadisticasAdmin(req, res);
            break;
        case 'USER':
            dashboard.dashboardEstadisticasAdmin(req, res);
            break;
        default:
            res.json({
                ok: false,
                msj: 'Acceso Denegado',
            });
            break;
    }
});

module.exports = {
    app,
};
