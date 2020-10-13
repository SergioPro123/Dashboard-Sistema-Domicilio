const express = require('express');
const app = express();

const jwt = require('jsonwebtoken');

let token = jwt.sign(
    {
        usuario: {
            nombre: 'Sergio',
            rol: 'ADMIN',
        },
    },
    process.env.SEED,
    { expiresIn: process.env.CADUCIDAD_TOKEN }
);

app.get('/login', (req, res) => {
    res.render('login.hbs');
});

module.exports = {
    app,
};
