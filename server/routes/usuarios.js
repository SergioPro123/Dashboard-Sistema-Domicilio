const express = require('express');
const app = express();

let multer = require('multer');
let path = require('path');
const uuid = require('uuid');

const { verificaToken } = require('../middlewares/autenticacion');

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

const usuariosFunciones = require('../controllers/usuarios');
//Renderizamos la seccion de cliente
app.get('/clientes', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        usuariosFunciones.consultarClientes(req, res);
    } else {
        return res.redirect('/dashboard');
    }
});

//Agregamos un nuevo cliente a la Base de Datos
app.post('/clientes', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        usuariosFunciones.agregarClientes(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
});
//Actualizamos datos
app.put('/clientes', verificaToken, (req, res) => {
    console.log('update');
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        usuariosFunciones.actualizarClientes(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
});

//Renderizamos la seccion de domiciliario
app.get('/domiciliarios', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        usuariosFunciones.consutalDomiciliarios(req, res);
    } else {
        return res.redirect('/dashboard');
    }
});

//Renderizamos la seccion de domiciliario
app.post('/domiciliarios', [verificaToken, uploadDomiciliario.single('pathImageModalAnadir')], (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        usuariosFunciones.agregarDomiciliarios(req, res);
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
        usuariosFunciones.actualizarDomiciliarios(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
    return res;
});

//Renderizamos la seccion de domiciliario
app.get('/administradores', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        usuariosFunciones.administradores(req, res);
    } else {
        return res.redirect('/dashboard');
    }
});
module.exports = {
    app,
};
