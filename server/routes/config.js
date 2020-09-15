const express = require("express");
const app = express();

app.use(require("./login").app);
app.use(require("./dashboard").app);
app.use(require("./registro").app);

module.exports = {
    app,
};
