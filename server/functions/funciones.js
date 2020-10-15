const capitalizar = (myString) => {
    let palabras = myString.split(' ');
    palabras.forEach((palabra, index) => {
        palabras[index] = palabra.charAt(0).toUpperCase() + palabra.slice(1).toLowerCase();
    });
    return palabras.join(' ');
};

module.exports = {
    capitalizar,
};
