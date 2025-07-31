const fs = require("fs");

function send_ddl(db) {
	const DDL = fs.readFileSync("internal/ddl.sql", "utf8");
	db.query(DDL);
}

function fetch_full_table(db, tablename) {
	return db.query(`SELECT * FROM ${tablename};`);
}




module.exports = {
	send_ddl,
	fetch_full_table
};

