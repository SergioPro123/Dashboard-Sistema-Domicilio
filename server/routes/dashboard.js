const express = require("express");
const app = express();
//const dashboardController = require("../controllers/dashboard");

//Renderizamos la seccion de DASHBOARD
app.get("/dashboard", (req, res) => {
    res.render("dashboard.hbs", {
        menu: {
            dashboard: {
                selected: "selected",
                active: "active",
            },
        },
    });
});

//Renderizamos la seccion de TicketList
app.get("/dashboard/ticketList", (req, res) => {
    res.render("ticket-list.hbs", {
        menu: {
            ticketList: {
                selected: "selected",
                active: "active",
            },
        },
    });
});

//Renderizamos la seccion de CHAT
app.get("/dashboard/chat", (req, res) => {
    res.render("chat.hbs", {
        menu: {
            chat: {
                selected: "selected",
                active: "active",
            },
        },
    });
});

//Renderizamos la seccion de CALENDARIO
app.get("/dashboard/calendario", (req, res) => {
    res.render("calendario.hbs", {
        menu: {
            calendario: {
                selected: "selected",
                active: "active",
            },
        },
    });
});
//app.use(dashboardController.error404);
module.exports = {
    app,
};
