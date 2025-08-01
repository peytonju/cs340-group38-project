const fs = require("fs");

function send_ddl(db) {
	const DDL = fs.readFileSync("internal/ddl.sql", "utf8");
	db.query(DDL);
}

function table_select(db, tablename) {
	return db.query(`SELECT * FROM ${tablename};`);
}

function table_insert(db, tablename, form_data) {
	console.log("ran insert");
	console.log(`received, \n\ttable name: ${tablename}\n\tform data:`);
	console.dir(form_data);
}

function table_update(db, tablename, primary_key, form_data) {
	console.log("ran update");
	console.log(`received, \n\ttable name: ${tablename}\n\tprimary key: ${primary_key}\n\tform data:`);
	console.dir(form_data);
}

function table_delete(db, tablename, primary_key) {
	console.log("ran delete");
	console.log(`received, \n\ttable name: ${tablename}\n\tprimary key: ${primary_key}`);
}



module.exports = {
	send_ddl,
	table_select,
	table_insert,
	table_update,
	table_delete
};

