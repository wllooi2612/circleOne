const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'circleone_db',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0,
    dateStrings: true // Return date as string for clean Swift ISO formatting
});

// Test database connectivity
pool.getConnection()
    .then(connection => {
        console.log('✅ Connected to MySQL database [circleone_db]');
        connection.release();
    })
    .catch(err => {
        console.error('❌ Failed to connect to MySQL database:', err.message);
    });

module.exports = pool;
