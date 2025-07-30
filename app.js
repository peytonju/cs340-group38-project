
/**************************************************************************** SETUP */
/* REQUIRES */
const express = require("express");
const express_handlebars = require("express-handlebars");
const path = require("path")
const sql_util = require("./internal/sql_functions");

/* CONSTANTS */
const app = express(); /* express app */
const db = require("./internal/database_connection_details"); /* database. send queries here. */
const PORT = 2; /* port this express server will be hosted on. */


/* HANDLEBARS SETUP */
app.engine("handlebars", express_handlebars.engine({
	/* as specified by layouts/index.handlebars */
	defaultLayout: "layouts_index"
}));
app.set("view engine", "handlebars");
app.use(express.static("public"));
app.use(express.urlencoded({
	extended: true
}));

/**************************************************************************** ROUTES */
app.get("/", async function (req, res) {
	res.status(200).render("pages_root");
});

app.get("/players", async function (req, res) {
	res.status(200).render("pages_players");
});

app.get("/farms", async function (req, res) {
	res.status(200).render("pages_farms");
});

app.get("/villagers", async function (req, res) {
	res.status(200).render("pages_villagers");
});

app.get("/gifts", async function (req, res) {
	res.status(200).render("pages_gifts");
});

app.get("/gifthistories", async function (req, res) {
	res.status(200).render("pages_gifthistories");
});

app.get("/playersvillagersrelationships", async function (req, res) {
	res.status(200).render("pages_playersvillagersrelationships");
});

app.get("/villagersgiftspreferences", async function (req, res) {
	res.status(200).render("pages_villagersgiftspreferences");
});

app.get("/send_ddl", async function (req, res) {
	sql_util.send_ddl(db);
	res.status(200).send("ddl sent");
});


/**************************************************************************** LISTENER */
app.listen(PORT, function() {
    console.log("Express started on http://localhost:" + PORT + "; press Ctrl-C to terminate.");
});

