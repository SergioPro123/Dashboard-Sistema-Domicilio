const express = require("express");
const app = express();

app.get("/login", (req, res) => {
    res.render("login.hbs");
});

module.exports = {
    app,
};
