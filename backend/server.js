const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();

const db = require('./db');
const usersRouter = require('./routes/users');
const leavesRouter = require('./routes/leaves');
const managerRouter = require('./routes/manager');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// API Routes
app.use('/api/users', usersRouter);
app.use('/api/leaves', leavesRouter);
app.use('/api/manager', managerRouter);

// Health check endpoint
app.get('/api/health', async (req, res) => {
    try {
        const [result] = await db.query('SELECT 1 as isAlive, NOW() as serverTime');
        res.json({
            status: 'online',
            app: 'circleOne REST API',
            database: 'MySQL connected',
            serverTime: result[0].serverTime
        });
    } catch (err) {
        res.status(500).json({
            status: 'error',
            database: 'MySQL disconnected',
            error: err.message
        });
    }
});

// Root documentation overview
app.get('/', (req, res) => {
    res.json({
        name: 'circleOne 🌿 Leave Application & Management Web API',
        version: '1.0.1',
        endpoints: {
            health: 'GET /api/health',
            userProfile: 'GET /api/users/profile?userId=EMP-9402',
            teamMembers: 'GET /api/users/team',
            roleToggle: 'POST /api/users/role',
            leaveTypes: 'GET /api/leaves/types',
            leaveBalances: 'GET /api/leaves/balances?userId=EMP-9402',
            leaveRequests: 'GET /api/leaves/requests?userId=EMP-9402',
            applyLeave: 'POST /api/leaves/apply',
            managerRequests: 'GET /api/manager/requests?status=pending',
            managerReview: 'POST /api/manager/review'
        }
    });
});

// 404 Handler
app.use((req, res) => {
    res.status(404).json({ error: 'Endpoint not found', path: req.originalUrl });
});

// Process exception safety
process.on('uncaughtException', (err) => {
    console.error('💥 Uncaught Exception:', err);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('💥 Unhandled Rejection at:', promise, 'reason:', reason);
});

// Start Server on all potential Railway proxy target ports
const http = require('http');
const primaryPort = parseInt(process.env.PORT || '8080', 10);
const targetPorts = Array.from(new Set([primaryPort, 8080, 3000]));

targetPorts.forEach((port) => {
    try {
        const s = http.createServer(app);
        s.listen(port, '0.0.0.0', () => {
            console.log(`🚀 circleOne Web API is listening on http://0.0.0.0:${port}`);
            console.log(`🌿 Health Check: http://0.0.0.0:${port}/api/health`);
        });
        s.on('error', (err) => {
            if (err.code !== 'EADDRINUSE') {
                console.warn(`Port ${port} warning:`, err.message);
            }
        });
    } catch (e) {
        console.warn(`Failed to bind to port ${port}:`, e.message);
    }
});

