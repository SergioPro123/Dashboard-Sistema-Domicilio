const express = require('express');
const app = express();

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
//Renderizamos la seccion de DASHBOARD
app.get('/dashboard', (req, res) => {
    res.render('domiciliario/dashboard_domiciliario.hbs', {
        data: {
            estadisticas: {
                clientesTotales: [999, 1],
                serviciosMes: [888, 0],
                gananciasMes: [123456, -1],
                domiciliariosTotales: [50, 5],
            },
            infoPersonal: {
                nombre: 'Sergio Mauricio',
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
});

app.get('/dashboard/estadisticas', (req, res) => {
    let data = {
        estadistica: {
            ventasMes: {
                columns: [
                    ['Valor Prueba 1', 22],
                    ['Valor Prueba 2', 33],
                    ['Valor Prueba 3', 55],
                    ['Valor Prueba 4', 99],
                ],
                color: ['#edf2f6', '#5f76e8', '#ff4f70', '#01caf1'],
            },
            estadisticasGanancias: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                series: [[11, 10, 15, 21, 14, 23, 12]],
            },
            serviciosRealizados: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                series: [[5, 4, 3, 7, 10, 10]],
            },
        },
    };
    res.json(data);
});

module.exports = {
    app,
};
