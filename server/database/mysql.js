const mysql = require('mysql');
class MySQL {
    constructor() {
        this.conectado = false;
        console.log('clase inicializada');
        this.conexion = mysql.createConnection({
            host: 'localhost',
            user: 'sistemaDomicilio',
            password: '123456',
            database: 'sistemadomicilio',
        });

        this.conectarDB();
    }
    static get instance() {
        return this._instance || (this._instance = new this());
    }
    static ejecutarQuery(query, callback) {
        this.instance.conexion.query(query, (err, result, fields) => {
            if (err) {
                console.log('Error : ' + err);
                return callback(err);
            }
            if (result.length == 0) {
                callback('El registro solicitado no Existe');
            } else {
                callback(null, result);
            }
        });
    }
    conectarDB() {
        this.conexion.connect((err) => {
            if (err) {
                console.log(err.message);
                return;
            }
            this.conectado = true;
            console.log('Base de Datos Conectada con Exito');
        });
    }
}
module.exports = {
    MySQL,
};
