
/**************************************************************************** SETUP */
const express = require('express');
const app = express();
const PORT = 14023;

const db = require('./db-connector');


/**************************************************************************** ROUTES */
app.get('/', async function (req, res) {
	res.status(500).send("An error occurred while executing the database queries.");
});


/**************************************************************************** LISTENER */
app.listen(PORT, function() {
    console.log('Express started on http://localhost:' + PORT + '; press Ctrl-C to terminate.')
});

