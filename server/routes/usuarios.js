const express = require('express');
const app = express();
//Renderizamos la seccion de cliente
app.get('/clientes', (req, res) => {
    res.render('admin/clientes_admin.hbs', {
        data: {
            clientes: [
                ['Sergio Aparicio', '3142483968', ['Calle 1', 'Calle 2'], '999', 'id-1'],
                ['Richard Cano', '3142483968', [''], '999', 'id-2'],
                ['Jhonatan Lagares', '3142483968', ['Calle 3', 'Calle 4'], '999', 'id-3'],
            ],
        },
    });
});

//Renderizamos la seccion de domiciliario
app.get('/domiciliarios', (req, res) => {
    res.render('admin/domiciliarios_admin.hbs', {
        data: {
            domiciliarios: [
                [
                    'Sergio Aparicio',
                    'Sergio@hotmail.com',
                    '1007733234',
                    '3142483968',
                    'A',
                    'Habilitado',
                    'sergio.jpg',
                    'id-1',
                ],
                [
                    'Richard Cano',
                    'Richard@hotmail.com',
                    '1007733234',
                    '3142483968',
                    'A',
                    'Deshabilitado',
                    'richard.jpg',
                    'id-2',
                ],
                [
                    'Jhonatan Lagares',
                    'jhonatan@hotmail.com',
                    '1007733234',
                    '3142483968',
                    'B',
                    'Habilitado',
                    'jhonatan.jpg',
                    'id-3',
                ],
            ],
            estados: [['Habilitado'], ['Deshabilitado']],
        },
    });
});

//Renderizamos la seccion de domiciliario
app.get('/administradores', (req, res) => {
    res.render('superAdmin/administradores_superAdmin.hbs', {
        data: {
            administradores: [
                [
                    'Sergio Aparicio',
                    'Sergio@hotmail.com',
                    '1007733234',
                    '3142483968',
                    'Habilitado',
                    'sergio.jpg',
                    'id-1',
                ],
                [
                    'Richard Cano',
                    'Richard@hotmail.com',
                    '1007733234',
                    '3142483968',
                    'Deshabilitado',
                    'richard.jpg',
                    'id-2',
                ],
                [
                    'Jhonatan Lagares',
                    'jhonatan@hotmail.com',
                    '1007733234',
                    '3142483968',
                    'Habilitado',
                    'jhonatan.jpg',
                    'id-3',
                ],
            ],
            estados: [['Habilitado'], ['Deshabilitado']],
        },
    });
});
module.exports = {
    app,
};
