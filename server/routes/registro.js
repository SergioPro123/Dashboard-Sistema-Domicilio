const express = require("express");
const app = express();

app.get("/registro", (req, res) => {
    res.render("registro.hbs");
});

module.exports = {
    app,
};
