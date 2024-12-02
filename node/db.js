require('dotenv').config();
const sql = require('mssql');

const dbConfig = {
    server: process.env.DB_SERVER,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: parseInt(process.env.DB_PORT,10),
    options: {
        encrypt: true,
        trustServerCertificate: true,
    },
};

const poolPromise = new sql.ConnectionPool(dbConfig)
    .connect()
    .then(pool => 
    {
        console.log('Connected to MSSQL');
        return pool
    })
    .catch(err => {
        console.error('Database Connection Failed! Bad Config:', err)
        throw err;
    });
module.exports = {
        sql, // Exporting sql for direct use if needed
        poolPromise
    };