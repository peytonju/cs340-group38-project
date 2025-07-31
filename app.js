
/**************************************************************************** SETUP */
/* REQUIRES */
const express = require("express");
const express_handlebars = require("express-handlebars");
const path = require("path")
const sql_util = require("./internal/sql_functions");
const { helpers } = require("./helpers/hbs");

/* CONSTANTS */
const app = express(); /* express app */
const db = require("./internal/database_connection_details"); /* database. send queries here. */
const PORT = 2; /* port this express server will be hosted on. */


/* HANDLEBARS SETUP */
app.engine("handlebars", express_handlebars.engine({
	/* as specified by layouts/index.handlebars */
	defaultLayout: "layouts_index",
	helpers
}));
app.set("view engine", "handlebars");
app.set()
app.use(express.static("public"));
app.use(express.urlencoded({
	extended: true
}));


const URL_TO_TABLE_NAME = {
	"players": "Players",
	"villagers": "Villagers",
	"farms": "Farms",
	"gifts": "Gifts",
	"gifthistories": "GiftHistories",
	"playersvillagersrelationships": "PlayersVillagersRelationships",
	"villagersgiftspreferences": "VillagersGiftsPreferences"
}


/**************************************************************************** ROUTES */
app.get("/", async function (req, res) {
	res.status(200).render("pages_root");
});

app.get("/tables/:db_tablename", async function (req, res) {
	const URL_TABLE_NAME = (req.params.db_tablename).toLowerCase();
	const TABLE_NAME = (URL_TABLE_NAME in URL_TO_TABLE_NAME) ? URL_TO_TABLE_NAME[URL_TABLE_NAME] : null;

	if (TABLE_NAME) {
		try {
			console.log(await sql_util.fetch_full_table(db, TABLE_NAME));
			res.status(200).render(`pages_${URL_TABLE_NAME}`);
		} catch (error) {
			res.status(404).send("Desired table does not exist!");
		}
	} else {
		res.status(404).send("Table specified in the URL does not have a translation!");
	}
});

app.get("/send_ddl", async function (req, res) {
	sql_util.send_ddl(db);
	res.status(200).send("ddl sent");
});


/**************************************************************************** LISTENER */
app.listen(PORT, function() {
    console.log("Express started on http://localhost:" + PORT + "; press Ctrl-C to terminate.");
});

