var jwt = require('jsonwebtoken');

//=================================
//       Verificar token
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

module.exports = {
    verificaToken,
};
