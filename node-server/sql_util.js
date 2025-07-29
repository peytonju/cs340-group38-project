const fs = require("fs");

function send_ddl(db) {
	const DDL = fs.readFileSync("../ddl.sql", "utf8");
	db.query(DDL);
}




module.exports = {
	send_ddl
};

