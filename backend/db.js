const mysql = require('mysql2/promise');
require('dotenv').config();

const rawUrl = process.env.MYSQL_URL || process.env.DATABASE_URL;
const isValidUrl = typeof rawUrl === 'string' && rawUrl.startsWith('mysql://') && !rawUrl.includes('${{');

let dbConfig;
if (isValidUrl) {
    dbConfig = {
        uri: rawUrl,
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0,
        enableKeepAlive: true,
        keepAliveInitialDelay: 0,
        dateStrings: true
    };
} else {
    if (rawUrl) {
        console.warn(`⚠️ Warning: MYSQL_URL "${rawUrl}" is not a valid MySQL URL, falling back to host config.`);
    }
    dbConfig = {
        host: process.env.MYSQLHOST || process.env.DB_HOST || 'zephyr.proxy.rlwy.net',
        user: process.env.MYSQLUSER || process.env.DB_USER || 'root',
        password: process.env.MYSQLPASSWORD !== undefined
            ? process.env.MYSQLPASSWORD
            : (process.env.DB_PASSWORD !== undefined ? process.env.DB_PASSWORD : 'dSuiqexWYpWNYPNNEtbyePfJsVPbIeUp'),
        database: process.env.MYSQLDATABASE || process.env.DB_NAME || 'railway',
        port: parseInt(process.env.MYSQLPORT || process.env.DB_PORT || '17717', 10),
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0,
        enableKeepAlive: true,
        keepAliveInitialDelay: 0,
        dateStrings: true // Return date as string for clean Swift ISO formatting
    };
}

let pool;
try {
    pool = mysql.createPool(dbConfig);
} catch (poolErr) {
    console.error('❌ Error creating MySQL pool:', poolErr.message);
    pool = mysql.createPool({
        host: 'zephyr.proxy.rlwy.net',
        user: 'root',
        password: 'dSuiqexWYpWNYPNNEtbyePfJsVPbIeUp',
        database: 'railway',
        port: 17717,
        dateStrings: true
    });
}

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
