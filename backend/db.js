const mysql = require('mysql2/promise');
require('dotenv').config();

const dbConfig = process.env.MYSQL_URL || process.env.DATABASE_URL ? {
    uri: process.env.MYSQL_URL || process.env.DATABASE_URL,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0,
    dateStrings: true
} : {
    host: process.env.MYSQLHOST || process.env.DB_HOST || '127.0.0.1',
    user: process.env.MYSQLUSER || process.env.DB_USER || 'root',
    password: process.env.MYSQLPASSWORD !== undefined ? process.env.MYSQLPASSWORD : (process.env.DB_PASSWORD || ''),
    database: process.env.MYSQLDATABASE || process.env.DB_NAME || 'circleone_db',
    port: parseInt(process.env.MYSQLPORT || process.env.DB_PORT || '3306', 10),
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0,
    dateStrings: true // Return date as string for clean Swift ISO formatting
};

const pool = mysql.createPool(dbConfig);

// Test database connectivity
pool.getConnection()
    .then(connection => {
        console.log('✅ Connected to MySQL database');
        connection.release();
    })
    .catch(err => {
        console.error('❌ Failed to connect to MySQL database:', err.message);
    });

module.exports = pool;
