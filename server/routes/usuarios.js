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
//Actualizamos datos de un cliente
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

//Agregamos un nuevo domicliario
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

//Eliminamos algun domicliario
app.delete('/domiciliarios', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        usuariosFunciones.eliminarDomiciliarios(req, res);
    } else {
        return res.status(401).json({
            ok: false,
            msj: 'No Autorizado',
        });
    }
});

//Renderizamos la seccion de Administradores
app.get('/administradores', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        usuariosFunciones.administradores(req, res);
    } else {
        return res.redirect('/dashboard');
    }
});

//Agregamos un nuevo Administrador
app.post('/administradores', [verificaToken, uploadAdministrador.single('pathImageModalAnadir')], (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'SUPER_ADMIN') {
        usuariosFunciones.agregarAdministradores(req, res);
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
        usuariosFunciones.actualizarAdministradores(req, res);
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
        usuariosFunciones.eliminarAdministradores(req, res);
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
