const mysql = require("mysql");
const { database } = require("./keys");
const { promisify } = require("util");
const pool = mysql.createPool(database);

pool.getConnection((err, connection) => {
  if (err) {
    if (err.code === "PROTOCOL_CONNECTION_LOST") {
      console.log("Database lost connection");
    }
    if (err.code === "ER_CON_COUNT_ERROR") {
      console.log("Muchas conexiones");
    }
    if (err.code === "ECONNREFUSED") {
      console.log("Conexión rechazada");
    }
  }
  if (connection) connection.release();
  console.log("DB is connected");
  return;
});
//Promisify
pool.query = promisify(pool.query);

module.exports = pool;
