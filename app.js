
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
const PORT = 41394; /* port this express server will be hosted on. */


/* HANDLEBARS SETUP */
app.engine("handlebars", express_handlebars.engine({
	/* as specified by layouts/index.handlebars */
	defaultLayout: "layouts_index",
	partialsDir: path.join(__dirname, "views", "partials"),
	helpers
}));
app.set("view engine", "handlebars");
app.set()
app.use(express.static("public"));
app.use(express.urlencoded({
	extended: true
}));


/* contains relevant tables needed for a specific URL path on our site. */
const URL_TABLES = {
	"players": {primary: "Players", additional: null},
	"villagers": {primary: "Villagers", additional: ["Farms"]},
	"farms": {primary: "Farms", additional: ["Players"]},
	"gifts": {primary: "Gifts", additional: null},
	"gifthistories": {primary: "GiftHistories", additional: ["Players", "Gifts", "Villagers"]},
	"playersvillagersrelationships": {primary: "PlayersVillagersRelationships", additional: ["Players", "Villagers"]},
	"villagersgiftspreferences": {primary: "VillagersGiftsPreferences", additional: ["Villagers", "Gifts"]}
};

const FARM_TYPES = ["Standard", "Riverland", "Forest", "Hill-top", "Wilderness", "Four Corners", "Beach", "Meadowlands"];
const SEASONS = ["Spring", "Summer", "Fall", "Winter"];
const RELATIONSHIP_LEVELS = ["acquaintance", "friend", "spouse"];
const GIFT_LIKES = ["love", "like", "neutral", "dislike", "hate"];


/**************************************************************************** ROUTES */
app.get("/", async function (req, res) {
	const resetSuccess = req.query.reset === 'success';
	res.status(200).render("pages_root", { resetSuccess });
});

app.get("/tables/:db_tablename", async function (req, res) {
	const URL_TABLE_NAME = (req.params.db_tablename).toLowerCase();
	const NEEDED_TABLES = (URL_TABLE_NAME in URL_TABLES) ? URL_TABLES[URL_TABLE_NAME] : null;

	if (NEEDED_TABLES) {
		try {
			/* empty object */
			let handlebar_data = new Object(null);
			const PRIMARY_TABLE_NAME = NEEDED_TABLES.primary;

			handlebar_data[PRIMARY_TABLE_NAME] = (await sql_util.table_select(db, PRIMARY_TABLE_NAME))[0];


			if (NEEDED_TABLES.additional) {
				/* for every table needed, */
				for (const TABLE_NAME of NEEDED_TABLES.additional) {
					/* request it from the SQL server and dump it into the table data object */
					handlebar_data[TABLE_NAME] = (await sql_util.table_select(db, TABLE_NAME))[0];
				}
			}

			/* constants */
			handlebar_data["FARM_TYPES"] = FARM_TYPES;
			handlebar_data["SEASONS"] = SEASONS;
			handlebar_data["RELATIONSHIP_LEVELS"] = RELATIONSHIP_LEVELS;
			handlebar_data["GIFT_LIKES"] = GIFT_LIKES;

			res.status(200).render(`pages_${URL_TABLE_NAME}`, handlebar_data);
		} catch (error) {
			res.status(404).send("Desired table does not exist!");
		}
	} else {
		res.status(404).send("Table specified in the URL does not have a translation!");
	}
});

/* used by UPDATE and DELETE */
app.post("/tables/:db_tablename/:db_action/:db_primary_key", async function (req, res) {
	/* the table's name, translated into its actual SQL name. */
	const TABLE_NAME = URL_TABLES[(req.params.db_tablename).toLowerCase()].primary;
	/* the action to take. */
	const ACTION = req.params.db_action
	/* primary key of the element in question */
	const PRIMARY_KEY = req.params.db_primary_key.split("/");
	/* contains attributes that the form specified */
	const FORM_DATA = req.body;

	if (ACTION === "delete") {
		await sql_util.table_delete(db, TABLE_NAME, PRIMARY_KEY);
	} else if (ACTION === "update") {
		await sql_util.table_update(db, TABLE_NAME, PRIMARY_KEY, FORM_DATA);
	}

	res.redirect(`/tables/${req.params.db_tablename}`);
});

/* used by UPDATE for composite-key tables */
app.post("/tables/:db_tablename/update", async function (req, res) {
	/* the table's name, translated into its actual SQL name. */
	const TABLE_NAME = URL_TABLES[(req.params.db_tablename).toLowerCase()].primary;
	/* contains attributes that the form specified */
	const FORM_DATA = req.body;

	await sql_util.table_update(db, TABLE_NAME, null, FORM_DATA);

	res.redirect(`/tables/${req.params.db_tablename}`);
});

/* used by INSERT */
app.post("/tables/:db_tablename/insert", async function (req, res) {
	/* the table's name, translated into its actual SQL name. */
	const TABLE_NAME = URL_TABLES[(req.params.db_tablename).toLowerCase()].primary;
	/* contains attributes that the form specified */
	const FORM_DATA = req.body;

	await sql_util.table_insert(db, TABLE_NAME, FORM_DATA);

	res.redirect(`/tables/${req.params.db_tablename}`);
});

app.get("/send_ddl", async function (req, res) {
	await sql_util.send_ddl(db);
	res.status(200).send("ddl sent");
});

app.get("/reset", async function (req, res) {
	try {
		await sql_util.reset_database(db);
		res.redirect("/?reset=success"); // Redirect with success parameter
	} catch (error) {
		console.error("Reset failed:", error);
		res.status(500).send("Database reset failed: " + error.message);
	}
});


/**************************************************************************** LISTENER */
app.listen(PORT, function() {
    console.log("Express started on http://localhost:" + PORT + "; press Ctrl-C to terminate.");
});

