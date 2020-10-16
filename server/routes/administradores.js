const express = require('express');
const app = express();

let multer = require('multer');
let path = require('path');
const uuid = require('uuid');

const { verificaToken } = require('../middlewares/autenticacion');
const administradoresControllers = require('../controllers/administradores');

//--------------------------------
//Configuración de Imagenes MULTER
//--------------------------------

const storageAdministrador = multer.diskStorage({
    destination(req, file, cb) {
        cb(null, path.join(__dirname, '../../public/uploads/images/admin'));
    },
    filename(req, file, cb) {
        cb(null, uuid.v4() + path.extname(file.originalname));
    },
});

const uploadAdministrador = multer({
    storage: storageAdministrador,
    fileFilter(req, file, next) {
        const isPhoto = file.mimetype.startsWith('image/');
        if (isPhoto) {
            next(null, true);
        } else {
            next({ message: 'El tipo de archivo no es válido' }, false);
        }
    },
});

//--------------------------------
//             Fin MULTER
//--------------------------------

//Renderizamos la seccion de Administradores
app.get('/administradores', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        administradoresControllers.consultarAdministradores(req, res);
    } else {
        return res.redirect('/dashboard');
    }
});

//Agregamos un nuevo Administrador
app.post('/administradores', [verificaToken, uploadAdministrador.single('pathImageModalAnadir')], (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        administradoresControllers.agregarAdministradores(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
    return res;
});

//Actualizamos un administrador de la base de datos
app.put('/administradores', [verificaToken, uploadAdministrador.single('pathImageModalEditar')], (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        administradoresControllers.actualizarAdministradores(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
    return res;
});

//Eliminamos algun administrador
app.delete('/administradores', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        administradoresControllers.eliminarAdministradores(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
});

module.exports = {
    app,
};
