const capitalizar = (myString) => {
    if (!myString) {
        if (myString == null || myString == undefined) {
            return '';
        }
        return myString;
    }
    let palabras = myString.split(' ');
    palabras.forEach((palabra, index) => {
        palabras[index] = palabra.charAt(0).toUpperCase() + palabra.slice(1).toLowerCase();
    });
    return palabras.join(' ');
};

const fechaActual = () => {
    let date = new Date();
    let fechaActual = date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();
    return fechaActual;
};

const devolverFecha = (fechaObjeto) => {
    let date = new Date(fechaObjeto);
    let fecha = date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();
    return fecha;
};

const fechaInicioyFinMes = () => {
    let myDate = new Date();
    let FechaDesde = new Date(myDate.getFullYear(), myDate.getMonth(), 1);
    let FechaHasta = new Date(myDate.getFullYear(), myDate.getMonth() + 1, 0);
    let desde = FechaDesde.getFullYear() + '-' + (FechaDesde.getMonth() + 1) + '-' + FechaDesde.getDate();
    let hasta = FechaHasta.getFullYear() + '-' + (FechaHasta.getMonth() + 1) + '-' + FechaHasta.getDate();

    return {
        desde,
        hasta,
    };
};

module.exports = {
    capitalizar,
    fechaActual,
    devolverFecha,
    fechaInicioyFinMes,
};
