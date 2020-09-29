const express = require('express');
const app = express();
const dashboardController = require('../controllers/dashboard');

app.use(require('./login').app);
app.use(require('./dashboard').app);
app.use(require('./registro').app);
app.use(dashboardController.error404);
module.exports = {
    app,
};
