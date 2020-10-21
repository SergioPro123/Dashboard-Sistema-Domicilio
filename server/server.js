const express = require('express');
const socketIO = require('socket.io');
const http = require('http');

const app = express();

const hbs = require('hbs');
const path = require('path');
const cookieParser = require('cookie-parser');
const bodyParser = require('body-parser');

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }));

// parse application/json
app.use(bodyParser.json());

app.use(express.static(path.resolve(__dirname, '../public')));
//Express HBS engine
app.set('view engine', 'hbs');
hbs.registerPartials(path.resolve(__dirname, '../views/partials'));
//Configuracion
require('./config/config');

//requerimos los helpers de HBS
require('./hbs/helpers');

let server = http.createServer(app);
// IO = esta es la comunicacion del backend
module.exports.io = socketIO(server);

require('./sockets/socket_generarServicio');

app.use(cookieParser());
app.use(require('./routes/config').app);

server.listen(process.env.PORT, () => {
    console.log('Escuchando en el puerto ' + process.env.PORT);
});
