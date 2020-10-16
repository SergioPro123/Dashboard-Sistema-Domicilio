const express = require('express');
const app = express();

let multer = require('multer');
let path = require('path');
const uuid = require('uuid');

const { verificaToken } = require('../middlewares/autenticacion');
const domiciliariosControllers = require('../controllers/domiciliarios');
//--------------------------------
//Configuración de Imagenes MULTER
//--------------------------------
const storageDomiciliario = multer.diskStorage({
    destination(req, file, cb) {
        cb(null, path.join(__dirname, '../../public/uploads/images/domiciliario'));
    },
    filename(req, file, cb) {
        cb(null, uuid.v4() + path.extname(file.originalname));
    },
});

const uploadDomiciliario = multer({
    storage: storageDomiciliario,
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

//Renderizamos la seccion de domiciliario
app.get('/domiciliarios', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        domiciliariosControllers.consutalDomiciliarios(req, res);
    } else {
        return res.redirect('/dashboard');
    }
});

//Agregamos un nuevo domicliario
app.post('/domiciliarios', [verificaToken, uploadDomiciliario.single('pathImageModalAnadir')], (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        domiciliariosControllers.agregarDomiciliarios(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
    return res;
});

//Actualizamos un domiciliario de la base de datos
app.put('/domiciliarios', [verificaToken, uploadDomiciliario.single('pathImageModalEditar')], (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        domiciliariosControllers.actualizarDomiciliarios(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
    return res;
});

//Eliminamos algun domicliario
app.delete('/domiciliarios', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        domiciliariosControllers.eliminarDomiciliarios(req, res);
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
