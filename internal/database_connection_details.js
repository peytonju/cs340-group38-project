const STUDENT_NAME = "dud";
const PASSWORD = "dud";

let mysql = require("mysql2");

const pool = mysql.createPool({
    waitForConnections: true,
    connectionLimit   : 10,
    multipleStatements: true,
    host              : "classmysql.engr.oregonstate.edu",
    user              : `cs340_${STUDENT_NAME}`,
    password          : `${PASSWORD}`,
    database          : `cs340_${STUDENT_NAME}`
}).promise();

module.exports = pool;

