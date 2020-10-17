const jwt = require('jsonwebtoken');

const { MySQL } = require('../database/mysql');

const verificaCredenciales = (req, res) => {
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
        if (result.length > 0 && result[0][0] != undefined) {
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
};

module.exports = {
    verificaCredenciales,
};
