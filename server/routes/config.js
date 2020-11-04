const express = require('express');
const app = express();
const dashboardController = require('../controllers/dashboard');

app.use(require('./login').app);
app.use(require('./dashboard').app);
app.use(require('./generarServicio').app);
app.use(require('./historial').app);
app.use(require('./tipoServicios').app);
app.use(require('./servicios').app);
app.use(require('./clientes').app);
app.use(require('./domiciliarios').app);
app.use(require('./administradores').app);
app.use(require('./generarLiquidacion').app);

//app.use(dashboardController.error404);
module.exports = {
    app,
};
