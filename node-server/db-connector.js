let mysql = require('mysql2')

const pool = mysql.createPool({
    waitForConnections: true,
    connectionLimit   : 10,
    host              : 'classmysql.engr.oregonstate.edu',
    user              : 'cs340_studentname',
    password          : 'password',
    database          : 'cs340_studentname'
}).promise();

module.exports = pool;

