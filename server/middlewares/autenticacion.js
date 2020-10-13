var jwt = require('jsonwebtoken');

//=================================
//       Verificar token
//=================================

let verificaToken = (req, res, next) => {
    let token = req.cookies.Authorization;
    jwt.verify(token, process.env.SEED, (err, decode) => {
        if (err) {
            return res.status(401).json({
                ok: false,
                err,
            });
        }
        req.usuario = decode.usuario;
        next();
    });
};

module.exports = {
    verificaToken,
};
