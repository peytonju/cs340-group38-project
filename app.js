
/**
 *	------------------ CITATION NOTICE ------------------
 *	-- If any function does NOT list a citation, then it
 *	-- was created originally by either Justice Peyton or
 *	-- Zachary Wilkins-Olson, and in those cases the entire
 *  -- team (Justice Peyton, Zachary Wilkins-Olson) is to
 *  -- be credited.
 *	-----------------------------------------------------
*/

/**
 * 7/6/2025
 * The general Express layout contained in this file is heavily inspired by Dr. Michael
 * Curry's "Activity 1 - Access and Use the CS340 Database" from the Introduction to
 * Databases (CS 340) course at Oregon State University, summer 2025.
 * https://canvas.oregonstate.edu/courses/2007765/assignments/10118864?module_item_id=25664550
 */


/**************************************************************************** SETUP */
/************ REQUIRES */
const express = require("express");
const express_handlebars = require("express-handlebars");
const path = require("path")
const sql_util = require("./internal/sql_functions");
const { helpers } = require("./helpers/hbs");

/************ CONSTANTS */
const app = express(); /* express app */
const db = require("./internal/database_connection_details"); /* database. send queries here. */
const PORT = 41394; /* port this express server will be hosted on. */

/* maps a URL to the tables that that URL requires in order to be displayed. essentially table dependencies for a URL. */
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

/************ HANDLEBARS SETUP */
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


/**************************************************************************** ROUTES */
/**
 * for the root page. See views/pages_root.handlebars
 * 
 * Created by Justice Peyton and Zachary Wilkins-Olson
 */
app.get("/", async function (req, res) {
	const resetSuccess = req.query.reset === 'success';
	res.status(200).render("pages_root", { resetSuccess });
});


/**
 * for displaying a table. See internal/sql_functions.js:table_select
 * 
 * Created by Justice Peyton
 */
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
			handlebar_data["error"] = req.query.error;

			res.status(200).render(`pages_${URL_TABLE_NAME}`, handlebar_data);
		} catch (error) {
			res.status(404).send("Desired table does not exist!");
			console.log(error);
		}
	} else {
		res.status(404).send("Table specified in the URL does not have a translation!");
	}
});


/**
 * for deleting or updating a row in a table. See internal/sql_functions.js:table_delete and internal/sql_functions.js:table_update
 * 
 * Created by Justice Peyton
 */
app.post("/tables/:db_tablename/:db_action/:db_primary_key", async function (req, res) {
	/* the table's name, translated into its actual SQL name. */
	const TABLE_NAME = URL_TABLES[(req.params.db_tablename).toLowerCase()].primary;
	/* the action to take. */
	const ACTION = req.params.db_action
	/* primary key of the element in question */
	const PRIMARY_KEY = req.params.db_primary_key.split("/");
	/* contains attributes that the form specified */
	const FORM_DATA = req.body;

	let database_error = "";


	try {
		if (ACTION === "delete") {
			await sql_util.table_delete(db, TABLE_NAME, PRIMARY_KEY);
		} else if (ACTION === "update") {
			await sql_util.table_update(db, TABLE_NAME, PRIMARY_KEY, FORM_DATA);
		}
	} catch (error) {
		database_error = `?error=${encodeURIComponent(error.message)}`;
	}

	console.log(database_error);

	res.redirect(`/tables/${req.params.db_tablename}${database_error}`);
});


/**
 * for inserting a row into a table. See internal/sql_functions.js:table_insert
 * 
 * Created by Justice Peyton
 */
app.post("/tables/:db_tablename/insert", async function (req, res) {
	/* the table's name, translated into its actual SQL name. */
	const TABLE_NAME = URL_TABLES[(req.params.db_tablename).toLowerCase()].primary;
	/* contains attributes that the form specified */
	const FORM_DATA = req.body;

	let database_error = "";

	try {
		await sql_util.table_insert(db, TABLE_NAME, FORM_DATA);
	} catch (error) {
		database_error = `?error=${encodeURIComponent(error.message)}`;
	}

	console.log(database_error);

	res.redirect(`/tables/${req.params.db_tablename}${database_error}`);
});


/**
 * for reseting the data and the DML procedures in the database. See internal/sql_functions.js:send_ddl_dml
 * 
 * Created by Justice Peyton
 */
app.get("/send_ddl_dml", async function (req, res) {
	await sql_util.send_ddl_dml(db);
	res.status(200).send("ddl sent");
});


/**
 * for reseting the example data. See internal/sql_functions.js:reset_database
 * 
 * Created by Zachary Wilkins-Olson
 */
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
/**
 * for listening on a specific port.
 * 
 * 7/6/2025
 * The following function was copied from "Activity 1 - Access and Use the CS340 Database"
 * from Dr. Michael Curry's Introduction to Databases (CS340) course at Oregon State
 * University, summer 2025.
 * https://canvas.oregonstate.edu/courses/2007765/assignments/10118864?module_item_id=25664550
 */
app.listen(PORT, function() {
    console.log("Express started on http://localhost:" + PORT + "; press Ctrl-C to terminate.");
});

