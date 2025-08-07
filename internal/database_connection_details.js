const STUDENT_NAME = "wilkinza";
const PASSWORD = "4OSInPwi1Rso";

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

