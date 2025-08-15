
/**
 *	-- ################# CITATION NOTICE #################
 *	-- If any function does NOT list a citation, then it
 *	-- was created originally by either Justice Peyton or
 *	-- Zachary Wilkins-Olson, and in those cases the entire
 *  -- team (Justice Peyton, Zachary Wilkins-Olson) is to
 *  -- be credited.
 *	-- ###################################################
*/


const fs = require("fs");

/**
 * table_to_pl_mapper - Maps a table name to its corresponding stored procedure prefix.
 * @param {string} tablename - The name of the table to translate.
 * @returns {string|null} - The corresponding stored procedure prefix or null if not found.
 * 
 * Created by Justice Peyton
 */
function table_to_pl_mapper(tablename) {
	if (tablename) {
		switch (tablename) {
			case "Players":
				return "player";
			case "Farms":
				return "farm";
			case "Villagers":
				return "villager";
			case "Gifts":
				return "gift";
			case "VillagersGiftsPreferences":
				return "villager_gift_preference";
			case "PlayersVillagersRelationships":
				return "villager_player_relationship";
			case "GiftHistories":
				return "gift_history";
		}
	}
	return null;
}


/**
 * send_ddl_pl - Sends the DDL and DML to the database.
 * @param {Pool} db - The database object to query with.
 * 
 * Created by Justice Peyton
 */
async function send_ddl_pl(db) {
	try {
		const DDL = fs.readFileSync("internal/ddl.sql", "utf8");
		await db.query(DDL);
		console.log("send_ddl_pl: DDL loaded successfully.");
	} catch (err) {
		console.error("send_ddl_pl: Failed to load DDL:", err.message || err);
		throw err;
	}

	try {
		const PL = fs.readFileSync("internal/pl.sql", "utf8");
		await db.query(PL);
		console.log("send_ddl_pl: PL loaded successfully.");
	} catch (err) {
		console.error("send_ddl_pl: Failed to load PL:", err.message || err);
		throw err;
	}
}


/**
 * reset_database - Resends the DDL.
 * @param {Pool} db - The database object to query with.
 * 
 * Created by Zachary Wilkins-Olson
 */
async function reset_database(db) {
	try {
		// Read the stored procedure file
		const resetProcedureSQL = fs.readFileSync("internal/pl.sql", "utf8");
		
		// Execute the entire file as one query (thanks to multipleStatements: true)
		await db.query(resetProcedureSQL);
		
		// Then call the stored procedure to reset the database
		await db.query("CALL ResetDatabase();");
	} catch (error) {
		console.error("Error in reset_database:", error);
		throw error;
	}
}


/**
 * table_select - Selects all rows from a table.
 * @param {Pool} db - The database object to query with.
 * @param {string} tablename - The name of the table to select from.
 * @returns {Object} - An object containing two more objects,
 * one contains rows and the other contains the title of the columns.
 * 
 * Created by Justice Peyton
 */
async function table_select(db, tablename) {
	return await db.query(`SELECT * FROM ${tablename};`);
}


/**
 * table_call_with_args - Calls a stored procedure that has more than just the primary key as an argument.
 * @param {Pool} db - The database object to query with.
 * @param {string} tablename - The name of the table to call the procedure for.
 * @param {string} primary_key - The primary key of the item to update or insert.
 * @param {Object} form_data - The form data containing the arguments to the stored procedure.
 * @param {string} function_prefix - The prefix for the stored procedure name ("create" or "update").
 * 
 * Created by Justice Peyton
 */
async function table_call_with_args(db, tablename, primary_key, form_data, function_prefix) {
	const PROCEDURE_NAME = table_to_pl_mapper(tablename);

	let arg_str = "";

	for (const KEY in form_data) {
		if (form_data[KEY] === "null") {
			arg_str += ",NULL";
		} else {
			arg_str += `,'${form_data[KEY]}'`;
		}
	}
	
	if (primary_key !== null) {
		arg_str = primary_key + arg_str;
	} else {
		/* strip the leading comma */
		arg_str = arg_str.substring(1);
	}

	console.log(arg_str);

	if (PROCEDURE_NAME) {
		await db.query(`CALL ${function_prefix}_${PROCEDURE_NAME}(${arg_str});`);
	}
}


/**
 * table_isnert - Inserts a row into some table.
 * @param {Pool} db - The database object to query with.
 * @param {string} tablename - The name of the table to insert into.
 * @param {Object} form_data - The form data containing the arguments to the insert stored procedure.
 * 
 * Created by Justice Peyton
 */
async function table_insert(db, tablename, form_data) {
	console.log("ran insert");
	console.log(`received, \n\ttable name: ${tablename}\n\tform data:`);
	console.dir(form_data);

	await table_call_with_args(db, tablename, null, form_data, "create");
}


/**
 * table_update - Updates a row in some table.
 * @param {Pool} db - The database object to query with.
 * @param {string} tablename - The name of the table to update.
 * @param {string} primary_key - The primary key of the item to update.
 * @param {Object} form_data - The form data containing the arguments to the update stored procedure.
 * NOTE: the order here matters. Please be mindful!
 * 
 * Created by Justice Peyton
 */
async function table_update(db, tablename, primary_key, form_data) {
	console.log("ran update");
	console.log(`received, \n\ttable name: ${tablename}\n\tprimary key: ${primary_key}\n\tform data:`);
	console.dir(form_data);

	await table_call_with_args(db, tablename, primary_key, form_data, "update");
}


/**
 * table_delete - Deletes a row from some table.
 * @param {Pool} db - The database object to query with.
 * @param {string} tablename - The name of the table to delete from.
 * @param {Object} primary_key - The primary key of the item to delete.
 * Can be a comma-separated string of IDs for composite keys.
 * 
 * Created by Justice Peyton
 */
async function table_delete(db, tablename, primary_key) {
	console.log("ran delete");
	console.log(`received, \n\ttable name: ${tablename}\n\tprimary key: ${primary_key}`);

	const PROCEDURE_NAME = table_to_pl_mapper(tablename);

	if (PROCEDURE_NAME) {
		await db.query(`CALL delete_${PROCEDURE_NAME}(${primary_key});`);
	}
}


/**
 * 7/28/2025
 * Understanding the module.exports statement was clarified and adapted by an output from OpenAI's ChatGPT.
 * The prompt utilized,
 * 		what is module.exports?
 * The example code given,
 * 		function add(a, b) {
 *  		return a + b;
 *  	}
 *		function subtract(a, b) {
 * 			return a - b;
 *  	}
 * 		module.exports = { add, subtract };
 * 
 * Created by Justice Peyton with inspiration from OpenAI's ChatGPT
 */
module.exports = {
	send_ddl_pl,
	reset_database,
	table_select,
	table_insert,
	table_update,
	table_delete
};
