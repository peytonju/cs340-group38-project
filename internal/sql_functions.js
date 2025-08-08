const fs = require("fs");

function send_ddl(db) {
	const DDL = fs.readFileSync("internal/ddl.sql", "utf8");
	db.query(DDL);
	const PL = fs.readFileSync("internal/pl.sql", "utf8");
	db.query(PL);
}

async function reset_database(db) {
	try {
		// Read the stored procedure file
		const resetProcedureSQL = fs.readFileSync("internal/pl.sql", "utf8");
		
		// Execute the entire file as one query (thanks to multipleStatements: true)
		await db.query(resetProcedureSQL);
		
		// Then call the stored procedure to reset the database
		return await db.query("CALL ResetDatabase();");
	} catch (error) {
		console.error("Error in reset_database:", error);
		throw error;
	}
}

function table_select(db, tablename) {
	return db.query(`SELECT * FROM ${tablename};`);
}


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

function table_insert(db, tablename, form_data) {
	console.log("ran insert");
	console.log(`received, \n\ttable name: ${tablename}\n\tform data:`);
	console.dir(form_data);

	const PROCEDURE_NAME = table_to_pl_mapper(tablename);

	// if (PROCEDURE_NAME) {
	// 	db.query(`CALL create_${PROCEDURE_NAME}();`);
	// }
}

function table_update(db, tablename, primary_key, form_data) {
	console.log("ran update");
	console.log(`received, \n\ttable name: ${tablename}\n\tprimary key: ${primary_key}\n\tform data:`);
	console.dir(form_data);

	const PROCEDURE_NAME = table_to_pl_mapper(tablename);

	// if (PROCEDURE_NAME) {
	// 	db.query(`CALL update_${PROCEDURE_NAME}(${primary_key});`);
	// }
}

function table_delete(db, tablename, primary_key) {
	console.log("ran delete");
	console.log(`received, \n\ttable name: ${tablename}\n\tprimary key: ${primary_key}`);

	const PROCEDURE_NAME = table_to_pl_mapper(tablename);

	if (PROCEDURE_NAME) {
		db.query(`CALL delete_${PROCEDURE_NAME}(${primary_key});`);
	}
}



module.exports = {
	send_ddl,
	reset_database,
	table_select,
	table_insert,
	table_update,
	table_delete
};

