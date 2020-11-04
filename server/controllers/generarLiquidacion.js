const { MySQL } = require('../database/mysql');
const { capitalizar, devolverFecha, fechaActual } = require('../functions/funciones');

const PDFDocument = require('../class/pdf-table');

const liquidacionDiaDomiciliario = (req, res) => {
    let query = `CALL consultarServiciosDomiciliario('${
        req.usuario.id_usuario
    }','${fechaActual()}','${fechaActual()}')`;
    generarLiquidacionPDF(req, res, query);
};

const liquidacionDiaAdministrador = (req, res) => {
    let query = `CALL consultarServiciosDia('${fechaActual()}')`;
    generarLiquidacionPDF(req, res, query);
};

const liquidacionTemporalDomiciliario = (req, res) => {
    let desde = MySQL.instance.conexion.escape(req.body.desde);
    let hasta = MySQL.instance.conexion.escape(req.body.hasta);
    let query = `CALL consultarServiciosDomiciliario('${req.usuario.id_usuario}',${desde},${hasta})`;
    generarLiquidacionPDF(req, res, query);
};

const liquidacionTemporalAdministrador = (req, res) => {
    let desde = MySQL.instance.conexion.escape(req.body.desde);
    let hasta = MySQL.instance.conexion.escape(req.body.hasta);
    let query = `CALL consultarServiciosTemporal(${desde},${hasta})`;
    generarLiquidacionPDF(req, res, query);
};

const liquidacionClienteData = (req, res) => {
    let idCliente = MySQL.instance.conexion.escape(req.body.idCliente);
    let query = `CALL consultarServiciosCliente(${idCliente})`;
    generarLiquidacionPDF(req, res, query);
};

const liquidacionDomiciliarioData = (req, res) => {
    let idDomiciliario = MySQL.instance.conexion.escape(req.body.idDomiciliario);
    let desde = MySQL.instance.conexion.escape(req.body.desde);
    let hasta = MySQL.instance.conexion.escape(req.body.hasta);
    let query = `CALL consultarServiciosDomiciliario(${idDomiciliario},${desde},${hasta})`;
    generarLiquidacionPDF(req, res, query);
};

const generarLiquidacionPDF = (req, res, query) => {
    let dataLiquidacion = [];
    let precioTotal = 0;
    MySQL.ejecutarQuery(query, (err, result) => {
        if (err) {
            return res.json({
                ok: false,
                msj: 'Error en la consulta',
            });
        }
        //Verifico que haya devuelto datos
        if (result.length > 0) {
            let index = 0;
            //Recorro cada registro
            while (result[0][index]) {
                dataLiquidacion[index] = [];
                dataLiquidacion[index][0] = devolverFecha(result[0][index].Fecha);
                dataLiquidacion[index][1] = capitalizar(result[0][index].nombreAdmin);
                dataLiquidacion[index][2] = capitalizar(result[0][index].nombreDomiciliario);
                dataLiquidacion[index][3] = capitalizar(result[0][index].nombreCliente);
                dataLiquidacion[index][4] = '$ ' + result[0][index].valorServicio;
                dataLiquidacion[index][5] = '$ ' + result[0][index].valorAdicional;
                precioTotal += result[0][index].valorServicio + result[0][index].valorAdicional;
                index++;
            }
            dataLiquidacion.unshift(['TOTAL', '', '', '', '', '$ ' + precioTotal]);
        }
        // Create a document
        const doc = new PDFDocument();

        // Set some headers
        res.statusCode = 200;
        res.setHeader('Content-type', 'application/pdf');
        res.setHeader('Access-Control-Allow-Origin', '*');

        // Header to force download
        res.setHeader('Content-disposition', 'attachment; filename=liquidacion.pdf');

        doc.pipe(res);

        doc.fontSize(20).fillColor('red');
        doc.text('Liquidación', {
            align: 'center',
            fillColor: 'red',
        });
        doc.fontSize(14).fillColor('black');

        const table0 = {
            headers: ['Fecha', 'Generado por', 'Atendido por', 'Cliente', 'Precio Servicio', 'Adicional'],
            rows: dataLiquidacion.reverse(),
        };
        doc.moveDown(2).table(table0, {
            prepareHeader: () => doc.font('Helvetica-Bold').fontSize(10),
            prepareRow: (row, i) => doc.font('Helvetica').fontSize(10),
        });
        // Finalize PDF file
        doc.end();
    });
};

module.exports = {
    liquidacionDiaDomiciliario,
    liquidacionDiaAdministrador,
    liquidacionTemporalDomiciliario,
    liquidacionTemporalAdministrador,
    liquidacionClienteData,
    liquidacionDomiciliarioData,
};
