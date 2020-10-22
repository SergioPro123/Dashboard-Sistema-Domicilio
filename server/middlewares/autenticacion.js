const jwt = require('jsonwebtoken');
const cookie = require('cookie');
//=================================
//    Verificar token para API
//=================================

let verificaToken = (req, res, next) => {
    let token = req.cookies.Authorization;
    jwt.verify(token, process.env.SEED, (err, decode) => {
        if (err) {
            return res.redirect('/login');
        }
        req.usuario = decode.usuario;
        next();
    });
};

//=======================================
// Verificar token para Conexion Sockets
//=======================================

let verificaTokenSocket = (client, next) => {
    let miCookie = cookie.parse(client.request.headers.cookie);
    let token = miCookie.Authorization;
    jwt.verify(token, process.env.SEED, (err, decode) => {
        if (err) {
            client.disconnect();
        } else {
            client.usuario = decode.usuario;

            if (client.usuario.rol === 'USER') {
                next();
            } else {
                client.disconnect();
            }
        }
    });
};

module.exports = {
    verificaToken,
    verificaTokenSocket,
};
