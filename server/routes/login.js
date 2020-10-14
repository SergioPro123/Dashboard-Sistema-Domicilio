const express = require('express');
const app = express();

const jwt = require('jsonwebtoken');

const { MySQL } = require('../database/mysql');

//Renderizamos el Login al cliente.
app.get('/login', (req, res) => {
    res.render('secciones/login.hbs');
});

//Verificamos las credenciales enviadas por el cliente,
// y si esta correcto, le generamos el Token, y se lo almacenamos
// en sus Cookies.
app.post('/login', (req, res) => {
    const email = MySQL.instance.conexion.escape(req.body.email);
    const password = MySQL.instance.conexion.escape(req.body.password);

    const query = `CALL loginCredenciales(${email},${password});`;
    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                err,
                msj: 'Error en la Comunicacion con la Base de Datos',
            });
        }
        //Si no devuelve resultado, es porque no encontro las credenciales
        if (result.affectedRows == undefined) {
            usuario = JSON.stringify(result[0][0]);
            usuario = JSON.parse(usuario);

            let token = jwt.sign({ usuario }, process.env.SEED, { expiresIn: process.env.CADUCIDAD_TOKEN });
            return res.json({
                ok: true,
                token,
            });
        } else {
            return res.json({
                ok: false,
                msj: 'Datos Incorrectos',
            });
        }
    });
});

module.exports = {
    app,
};
