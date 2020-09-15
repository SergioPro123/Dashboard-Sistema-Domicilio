const express = require("express");
const app = express();
const hbs = require("hbs");
const path = require("path");

app.use(express.static(path.resolve(__dirname, "../public")));
//Express HBS engine
app.set("view engine", "hbs");
hbs.registerPartials(path.resolve(__dirname, "../views/partials"));
//Configuracion
require("./config/config");

app.use(require("./routes/config").app);

app.listen(process.env.PORT, () => {
    console.log("Escuchando en el puerto " + process.env.PORT);
});
