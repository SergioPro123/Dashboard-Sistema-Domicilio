/*
******ADMIN******
dashboard =
data:{
    estadistica:{
        clientesTotales,
        serviciosMes,
        dineroMes,
        domiciliariosTotales,
        ventasMes:{
            columns:[],
            color:[]
        }
    },
    infoPersonal:{
        nombre
    },

}
*/
const dashboardSUPER_ADMIN = (req, res) => {
    return res.render('superAdmin/dashboard_superAdmin.hbs', {
        data: {
            estadisticas: {
                clientesTotales: [999, 1],
                serviciosMes: [888, 0],
                gananciasMes: [123456, -1],
                domiciliariosTotales: [50, 5],
            },
            infoPersonal: {
                nombre: req.usuario.nombre,
            },
            ventasMes: {
                valores: [
                    ['Valor Prueba 1', 22, 'primary'],
                    ['Valor Prueba 2', 33, 'danger'],
                    ['Valor Prueba 3', 55, 'cyan'],
                    ['Valor Prueba 4', 99, 'success'],
                ],
            },
        },
    });
};

const dashboardADMIN = (req, res) => {
    return res.render('admin/dashboard_admin.hbs', {
        data: {
            estadisticas: {
                clientesTotales: [999, 1],
                serviciosMes: [888, 0],
                gananciasMes: [123456, -1],
                domiciliariosTotales: [50, 5],
            },
            infoPersonal: {
                nombre: req.usuario.nombre,
            },
            ventasMes: {
                valores: [
                    ['Valor Prueba 1', 22, 'primary'],
                    ['Valor Prueba 2', 33, 'danger'],
                    ['Valor Prueba 3', 55, 'cyan'],
                    ['Valor Prueba 4', 99, 'success'],
                ],
            },
        },
    });
};

const dashboardDOMICILIARIO = (req, res) => {
    return res.render('domiciliario/dashboard_domiciliario.hbs', {
        data: {
            estadisticas: {
                clientesTotales: [999, 1],
                serviciosMes: [888, 0],
                gananciasMes: [123456, -1],
                domiciliariosTotales: [50, 5],
            },
            infoPersonal: {
                nombre: req.usuario.nombre,
            },
            ventasMes: {
                valores: [
                    ['Valor Prueba 1', 22, 'primary'],
                    ['Valor Prueba 2', 33, 'danger'],
                    ['Valor Prueba 3', 55, 'cyan'],
                    ['Valor Prueba 4', 99, 'success'],
                ],
            },
        },
    });
};

module.exports = {
    dashboardADMIN,
    dashboardSUPER_ADMIN,
    dashboardDOMICILIARIO,
};
