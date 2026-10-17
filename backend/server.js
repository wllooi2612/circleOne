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
        version: '1.0.0',
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

// Start Server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 circleOne Web API is running on http://localhost:${PORT}`);
    console.log(`🌿 Health Check: http://localhost:${PORT}/api/health`);
});
