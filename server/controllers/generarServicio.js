const { capitalizar } = require('../functions/funciones');
const generarServicio = (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        return res.render('admin/generarServicio_admin.hbs', {
            data: {
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
                infoPersonal: {
                    nombre: capitalizar(req.usuario.nombre),
                },
            },
        });
    } else {
        return res.redirect('/dashboard');
    }
};

const consultarDirecciones = (req, res) => {
    let rol = req.usuario.rol;
    if (rol == 'ADMIN') {
        let data = {
            55555555: 'Pros',
            20190901: 'Comilla Zila',
            20221601: "Cox's Bazar Zila",
            20301401: 'Feni Zila',
        };
        return res.json(data);
    }
};

module.exports = {
    generarServicio,
    consultarDirecciones,
};
