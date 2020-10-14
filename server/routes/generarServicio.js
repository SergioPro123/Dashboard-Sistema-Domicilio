const express = require('express');
const app = express();

const { verificaToken } = require('../middlewares/autenticacion');

//Renderizamos la seccion de generarServicio
app.get('/generarServicio', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        return res.render('admin/generarServicio_admin.hbs', {
            data: {
                generarServicio: {
                    selected: 'selected',
                    active: 'active',
                },
                clientes: [
                    ['20150415', 'Chittagong Zila'],
                    ['20190901', 'Comilla Zila'],
                    ['20221601', "Cox's Bazar Zila"],
                    ['20301401', 'Feni Zila'],
                ],
                tipoServicios: [
                    ['20150415', 'Banco'],
                    ['20190901', 'Normal'],
                    ['20221601', 'Encargo'],
                    ['20301401', 'otro'],
                ],
                datoServicios: {
                    servicioTotales: 11,
                    servicioEnProceso: 55,
                    servicioConcluidos: 66,
                    servicioCancelados: 88,
                },
            },
        });
    } else {
        return res.redirect('/dashboard');
    }
});

//Devolvemos un archivo JSON, con los clientes y sus ID
/* app.get('/generarServicio/clientes', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        let data = {
            results: [
                {
                    id: 1,
                    text: 'Option 1',
                },
                {
                    id: 2,
                    text: 'Option 2',
                },
            ],
        };
        return res.json(data);
    } 
}); */

//Devolvemos un archivo JSON, con las direccion del cliente requerido
app.get('/generarServicio/clientes/:direcciones', verificaToken, (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        let data = {
            20150415: 'Chittagong Zila',
            20190901: 'Comilla Zila',
            20221601: "Cox's Bazar Zila",
            20301401: 'Feni Zila',
        };
        return res.json(data);
    }
});

module.exports = {
    app,
};
