const express = require('express');
const app = express();
//Renderizamos la seccion de generarServicio
app.get('/generarServicio', (req, res) => {
    res.render('generarServicio_admin.hbs', {
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
});

//Devolvemos un archivo JSON, con los clientes y sus ID
app.get('/generarServicio/clientes', (req, res) => {
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
    res.json(data);
});

//Devolvemos un archivo JSON, con las direccion del cliente requerido
app.get('/generarServicio/clientes/:direcciones', (req, res) => {
    let data = {
        20150415: 'Chittagong Zila',
        20190901: 'Comilla Zila',
        20221601: "Cox's Bazar Zila",
        20301401: 'Feni Zila',
    };
    res.json(data);
});

module.exports = {
    app,
};
