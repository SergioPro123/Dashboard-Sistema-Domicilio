const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');

//Renderizamos la seccion de historialDia
app.get('/historialDia', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            return res.render('superAdmin/historialDia_superAdmin.hbs');
            break;
        case 'ADMIN':
            return res.render('admin/historialDia_admin.hbs', {
                data: {
                    historial: [
                        [
                            'Insert ADMIN 1',
                            'domiciliario',
                            'cliente',
                            'estado',
                            'direccion',
                            'tipoServicio',
                            'valorServicio',
                            'valorAdicional',
                            'descripcion',
                            'fecha',
                            'horaInicio',
                            'horaFinal',
                        ],
                        [
                            'Insert ADMIN 2',
                            'domiciliario',
                            'cliente',
                            'estado',
                            'direccion',
                            'tipoServicio',
                            'valorServicio',
                            'valorAdicional',
                            'descripcion',
                            'fecha',
                            'horaInicio',
                            'horaFinal',
                        ],
                    ],
                    infoPersonal: {
                        nombre: req.usuario.nombre,
                    },
                },
            });
            break;
        case 'USER':
            return res.render('domiciliario/historialDia_domiciliario.hbs');
            break;
        default:
            return res.redirect('/dashboard');
            break;
    }
});

//Renderizamos la seccion de historialTemporal
app.get('/historialTemporal', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            return res.render('superAdmin/historialTemporal_superAdmin.hbs');
            break;
        case 'ADMIN':
            return res.render('admin/historialTemporal_admin.hbs');
            break;
        case 'USER':
            return res.render('domiciliario/historialTemporal_domiciliario.hbs');
            break;
        default:
            return res.redirect('/dashboard');
            break;
    }
});

//Renderizamos la seccion de historialCliente
app.get('/historialCliente', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            return res.render('superAdmin/historialCliente_superAdmin.hbs');
            break;
        case 'ADMIN':
            return res.render('admin/historialCliente_admin.hbs');
            break;
        default:
            return res.redirect('/dashboard');
            break;
    }
});

//Renderizamos la seccion de historialDomiciliario
app.get('/historialDomiciliario', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    switch (rol) {
        case 'SUPER_ADMIN':
            return res.render('superAdmin/historialDomiciliario_superAdmin.hbs');
            break;
        case 'ADMIN':
            return res.render('admin/historialDomiciliario_admin.hbs');
            break;
        default:
            return res.redirect('/dashboard');
            break;
    }
});

module.exports = {
    app,
};
