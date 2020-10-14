const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');
const dashboard = require('../controllers/dashboard');

//Renderizamos la seccion de DASHBOARD
app.get('/dashboard', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            dashboard.dashboardSUPER_ADMIN(req, res);
            break;
        case 'ADMIN':
            dashboard.dashboardADMIN(req, res);
            break;
        case 'USER':
            dashboard.dashboardDOMICILIARIO(req, res);
            break;
        default:
            res.redirect('/login');
            break;
    }
});

app.get('/dashboard/estadisticas', verificaToken, (req, res) => {
    let data = {
        estadistica: {
            ventasMes: {
                columns: [
                    ['Valor Prueba 1', 22],
                    ['Valor Prueba 2', 33],
                    ['Valor Prueba 3', 55],
                    ['Valor Prueba 4', 99],
                ],
                color: ['#edf2f6', '#5f76e8', '#ff4f70', '#01caf1'],
            },
            estadisticasGanancias: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                series: [[11, 10, 15, 21, 14, 23, 12]],
            },
            serviciosRealizados: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                series: [[5, 4, 3, 7, 10, 10]],
            },
        },
    };
    res.json(data);
});

module.exports = {
    app,
};
