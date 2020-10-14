const express = require('express');
const app = express();

const loginController = require('../controllers/login');

//Renderizamos el Login al cliente.
app.get('/login', (req, res) => {
    res.render('secciones/login.hbs');
});

//Verificamos las credenciales enviadas por el cliente,
// y si esta correcto, le generamos el Token, y se lo almacenamos
// en sus Cookies.
app.post('/login', (req, res) => {
    loginController.verificaCredenciales(req, res);
});

module.exports = {
    app,
};
