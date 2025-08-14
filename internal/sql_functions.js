const fs = require("fs");

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


async function send_ddl_dml(db) {
	const DDL = fs.readFileSync("internal/ddl.sql", "utf8");
	await db.query(DDL);
	const DML = fs.readFileSync("internal/dml.sql", "utf8");
	await db.query(DML);
}


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


async function table_select(db, tablename) {
	return await db.query(`SELECT * FROM ${tablename};`);
}


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


async function table_insert(db, tablename, form_data) {
	console.log("ran insert");
	console.log(`received, \n\ttable name: ${tablename}\n\tform data:`);
	console.dir(form_data);

	await table_call_with_args(db, tablename, null, form_data, "create");
}


async function table_update(db, tablename, primary_key, form_data) {
	console.log("ran update");
	console.log(`received, \n\ttable name: ${tablename}\n\tprimary key: ${primary_key}\n\tform data:`);
	console.dir(form_data);

	await table_call_with_args(db, tablename, primary_key, form_data, "update");
}


async function table_delete(db, tablename, primary_key) {
	console.log("ran delete");
	console.log(`received, \n\ttable name: ${tablename}\n\tprimary key: ${primary_key}`);

	const PROCEDURE_NAME = table_to_pl_mapper(tablename);

	if (PROCEDURE_NAME) {
		await db.query(`CALL delete_${PROCEDURE_NAME}(${primary_key});`);
	}
}



module.exports = {
	send_ddl_dml,
	reset_database,
	table_select,
	table_insert,
	table_update,
	table_delete
};

