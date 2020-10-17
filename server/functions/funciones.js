const capitalizar = (myString) => {
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

module.exports = {
    capitalizar,
    fechaActual,
    devolverFecha,
};
