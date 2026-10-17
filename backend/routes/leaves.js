const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const db = require('../db');

// Map database code to Swift LeaveType rawValue
const leaveTypeMap = {
    'annual': 'Annual Leave',
    'medical': 'Medical / Sick',
    'casual': 'Casual / Emergency',
    'parental': 'Parental Leave',
    'compassionate': 'Compassionate',
    'unpaid': 'Unpaid Leave'
};

const reverseLeaveTypeMap = {
    'Annual Leave': 'annual',
    'Medical / Sick': 'medical',
    'Casual / Emergency': 'casual',
    'Parental Leave': 'parental',
    'Compassionate': 'compassionate',
    'Unpaid Leave': 'unpaid',
    'annual': 'annual',
    'medical': 'medical',
    'casual': 'casual',
    'parental': 'parental',
    'compassionate': 'compassionate',
    'unpaid': 'unpaid'
};

const durationTypeMap = {
    'fullDay': 'Full Day (1.0)',
    'halfDayAM': 'Morning AM (0.5)',
    'halfDayPM': 'Afternoon PM (0.5)',
    'multiDay': 'Multiple Days'
};

const reverseDurationTypeMap = {
    'Full Day (1.0)': 'fullDay',
    'Morning AM (0.5)': 'halfDayAM',
    'Afternoon PM (0.5)': 'halfDayPM',
    'Multiple Days': 'multiDay',
    'fullDay': 'fullDay',
    'halfDayAM': 'halfDayAM',
    'halfDayPM': 'halfDayPM',
    'multiDay': 'multiDay'
};

const statusMap = {
    'pending': 'Pending Approval',
    'approved': 'Approved',
    'rejected': 'Rejected',
    'cancelled': 'Cancelled'
};

/**
 * Generate a deterministically-formatted or random UUID v4
 */
function toUUID(str) {
    if (/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(str)) {
        return str;
    }
    const hash = crypto.createHash('md5').update(str).digest('hex');
    return `${hash.substring(0,8)}-${hash.substring(8,12)}-4${hash.substring(13,16)}-a${hash.substring(17,20)}-${hash.substring(20,32)}`;
}

/**
 * GET /api/leaves/types
 * Returns all leave types configured in database
 */
router.get('/types', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM leave_types ORDER BY default_quota DESC');
        res.json(rows);
    } catch (err) {
        console.error('Error fetching leave types:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
});

/**
 * GET /api/leaves/balances
 * Query: ?userId=EMP-9402&year=2026
 * Returns balances formatted to match Swift LeaveBalance model
 */
router.get('/balances', async (req, res) => {
    try {
        const userId = req.query.userId || 'EMP-9402';
        const year = parseInt(req.query.year || '2026', 10);

        const [rows] = await db.query(
            `SELECT lb.*, lt.name as type_name, lt.icon_name, lt.tint_color
             FROM leave_balances lb
             JOIN leave_types lt ON lb.leave_type_code = lt.code
             WHERE lb.user_id = ? AND lb.year = ?
             ORDER BY lt.default_quota DESC`,
            [userId, year]
        );

        const formattedBalances = rows.map(row => ({
            id: toUUID(`bal-${row.id}-${row.leave_type_code}`),
            type: leaveTypeMap[row.leave_type_code] || row.type_name,
            typeCode: row.leave_type_code,
            totalQuota: parseFloat(row.total_quota),
            usedDays: parseFloat(row.used_days),
            pendingDays: parseFloat(row.pending_days),
            availableDays: parseFloat(row.available_days)
        }));

        res.json(formattedBalances);
    } catch (err) {
        console.error('Error fetching leave balances:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
});

/**
 * GET /api/leaves/requests
 * Query: ?userId=EMP-9402
 * Returns employee's submitted leave requests matching Swift LeaveRequest model
 */
router.get('/requests', async (req, res) => {
    try {
        const userId = req.query.userId || 'EMP-9402';

        const [rows] = await db.query(
            `SELECT lr.*, lt.name as leave_type_name
             FROM leave_requests lr
             JOIN leave_types lt ON lr.leave_type_code = lt.code
             WHERE lr.employee_id = ?
             ORDER BY lr.applied_at DESC`,
            [userId]
        );

        const formattedRequests = rows.map(req => ({
            id: toUUID(req.id),
            requestNumber: req.request_number,
            employeeId: req.employee_id,
            employeeName: req.employee_name,
            employeeRole: req.employee_role,
            employeeAvatarInitials: req.employee_avatar_initials,
            leaveType: leaveTypeMap[req.leave_type_code] || req.leave_type_name,
            leaveTypeCode: req.leave_type_code,
            durationType: durationTypeMap[req.duration_type] || req.duration_type,
            startDate: req.start_date,
            endDate: req.end_date,
            totalDays: parseFloat(req.total_days),
            reason: req.reason,
            relieverName: req.reliever_name,
            attachmentName: req.attachment_name,
            status: statusMap[req.status] || req.status,
            statusCode: req.status,
            appliedAt: req.applied_at,
            reviewedBy: req.reviewed_by,
            reviewedAt: req.reviewed_at,
            reviewComment: req.review_comment
        }));

        res.json(formattedRequests);
    } catch (err) {
        console.error('Error fetching leave requests:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
});

/**
 * POST /api/leaves/apply
 * Submits a new leave request and places days into pending status atomically
 */
router.post('/apply', async (req, res) => {
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        const {
            employeeId = 'EMP-9402',
            leaveType,
            durationType,
            startDate,
            endDate,
            totalDays,
            reason,
            relieverName = null,
            attachmentName = null
        } = req.body;

        const typeCode = reverseLeaveTypeMap[leaveType] || 'annual';
        const durType = reverseDurationTypeMap[durationType] || 'multiDay';
        const days = parseFloat(totalDays || 1.0);

        // 1. Fetch user info
        const [users] = await connection.query('SELECT * FROM users WHERE id = ?', [employeeId]);
        if (users.length === 0) {
            await connection.rollback();
            return res.status(404).json({ error: 'Employee not found' });
        }
        const user = users[0];

        // 2. Check balance
        const [balances] = await connection.query(
            'SELECT * FROM leave_balances WHERE user_id = ? AND leave_type_code = ? AND year = 2026 FOR UPDATE',
            [employeeId, typeCode]
        );

        if (balances.length === 0) {
            await connection.rollback();
            return res.status(400).json({ error: `No balance found for leave type: ${typeCode}` });
        }

        const balance = balances[0];
        const available = parseFloat(balance.total_quota) - parseFloat(balance.used_days) - parseFloat(balance.pending_days);
        if (days > available) {
            await connection.rollback();
            return res.status(400).json({
                error: `Insufficient leave balance! Requested: ${days}d, Available: ${available}d`
            });
        }

        // 3. Update pending days
        await connection.query(
            'UPDATE leave_balances SET pending_days = pending_days + ? WHERE id = ?',
            [days, balance.id]
        );

        // 4. Insert new leave request
        const reqId = crypto.randomUUID();
        const requestNumber = `LEV-2026-${Math.floor(100 + Math.random() * 900)}`;

        await connection.query(
            `INSERT INTO leave_requests 
            (id, request_number, employee_id, employee_name, employee_role, employee_avatar_initials,
             leave_type_code, duration_type, start_date, end_date, total_days, reason,
             reliever_name, attachment_name, status, applied_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', NOW())`,
            [
                reqId,
                requestNumber,
                user.id,
                user.name,
                user.role,
                user.initials,
                typeCode,
                durType,
                startDate,
                endDate,
                days,
                reason || 'Personal leave request',
                relieverName,
                attachmentName
            ]
        );

        await connection.commit();

        res.status(201).json({
            success: true,
            message: 'Leave application submitted successfully',
            request: {
                id: reqId,
                requestNumber,
                status: 'Pending Approval',
                totalDays: days,
                leaveType: leaveTypeMap[typeCode]
            }
        });
    } catch (err) {
        await connection.rollback();
        console.error('Error applying for leave:', err);
        res.status(500).json({ error: 'Failed to submit leave request', details: err.message });
    } finally {
        connection.release();
    }
});

module.exports = router;
