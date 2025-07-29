
/**************************************************************************** SETUP */
const express = require("express");
const app = express();
const PORT = 41394;

const db = require("./db-connector");
const sql_util = require("./sql_util");


/**************************************************************************** ROUTES */
app.get('/', async function (req, res) {
	sql_util.send_ddl(db);

	res.status(200).send("what's up bro");
});


/**************************************************************************** LISTENER */
app.listen(PORT, function() {
    console.log("Express started on http://localhost:" + PORT + "; press Ctrl-C to terminate.");
});

