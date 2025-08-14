
/**
 *	------------------ CITATION NOTICE ------------------
 *	-- If any function does NOT list a citation, then it
 *	-- was created originally by either Justice Peyton or
 *	-- Zachary Wilkins-Olson, and in those cases the entire
 *  -- team (Justice Peyton, Zachary Wilkins-Olson) is to
 *  -- be credited.
 *	-----------------------------------------------------
*/

/**
 * for connecting to an SQL database.
 * 
 * 7/6/2025
 * The following content of this file was copied from "Activity 1 - Access and Use the CS340 Database"
 * from Dr. Michael Curry's Introduction to Databases (CS340) course at Oregon State
 * University, summer 2025.
 * https://canvas.oregonstate.edu/courses/2007765/assignments/10118864?module_item_id=25664550
 */
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
