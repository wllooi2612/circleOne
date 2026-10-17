const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const db = require('../db');

const leaveTypeMap = {
    'annual': 'Annual Leave',
    'medical': 'Medical / Sick',
    'casual': 'Casual / Emergency',
    'parental': 'Parental Leave',
    'compassionate': 'Compassionate',
    'unpaid': 'Unpaid Leave'
};

const durationTypeMap = {
    'fullDay': 'Full Day (1.0)',
    'halfDayAM': 'Morning AM (0.5)',
    'halfDayPM': 'Afternoon PM (0.5)',
    'multiDay': 'Multiple Days'
};

const statusMap = {
    'pending': 'Pending Approval',
    'approved': 'Approved',
    'rejected': 'Rejected',
    'cancelled': 'Cancelled'
};

function toUUID(str) {
    if (/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(str)) {
        return str;
    }
    const hash = crypto.createHash('md5').update(str).digest('hex');
    return `${hash.substring(0,8)}-${hash.substring(8,12)}-4${hash.substring(13,16)}-a${hash.substring(17,20)}-${hash.substring(20,32)}`;
}

/**
 * GET /api/manager/requests
 * Query: ?status=pending (or 'all', 'resolved')
 * Returns requests requiring manager attention or historical approvals
 */
router.get('/requests', async (req, res) => {
    try {
        const { status = 'all' } = req.query;
        let query = `
            SELECT lr.*, lt.name as leave_type_name
            FROM leave_requests lr
            JOIN leave_types lt ON lr.leave_type_code = lt.code
        `;
        const params = [];

        if (status === 'pending') {
            query += ' WHERE lr.status = ? ';
            params.push('pending');
        } else if (status === 'resolved') {
            query += ' WHERE lr.status IN (?, ?) ';
            params.push('approved', 'rejected');
        }

        query += ' ORDER BY lr.applied_at DESC';

        const [rows] = await db.query(query, params);

        const formatted = rows.map(req => ({
            id: toUUID(req.id),
            rawId: req.id,
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

        res.json(formatted);
    } catch (err) {
        console.error('Error fetching manager requests:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
});

/**
 * POST /api/manager/review
 * Body: { requestId, action: 'approve' | 'reject', comment, managerName }
 * Approves or rejects a leave request and updates balances atomically
 */
router.post('/review', async (req, res) => {
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        const {
            requestId,
            action, // 'approve' or 'reject'
            comment = '',
            managerName = 'Sarah Jenkins'
        } = req.body;

        if (!requestId || !action) {
            await connection.rollback();
            return res.status(400).json({ error: 'requestId and action (approve/reject) are required' });
        }

        // 1. Fetch current request state
        const [requests] = await connection.query(
            'SELECT * FROM leave_requests WHERE id = ? OR id = ? FOR UPDATE',
            [requestId, requestId.replace(/-/g, '')]
        );

        if (requests.length === 0) {
            await connection.rollback();
            return res.status(404).json({ error: 'Leave request not found' });
        }

        const request = requests[0];
        if (request.status !== 'pending') {
            await connection.rollback();
            return res.status(400).json({ error: `Request has already been processed with status: ${request.status}` });
        }

        const totalDays = parseFloat(request.total_days);
        const employeeId = request.employee_id;
        const leaveTypeCode = request.leave_type_code;

        if (action.toLowerCase() === 'approve') {
            // Update request
            await connection.query(
                `UPDATE leave_requests 
                 SET status = 'approved', reviewed_by = ?, reviewed_at = NOW(), review_comment = ?
                 WHERE id = ?`,
                [managerName, comment || 'Approved.', request.id]
            );

            // Update balance: deduct pending, increment used
            await connection.query(
                `UPDATE leave_balances 
                 SET pending_days = GREATEST(0, pending_days - ?), used_days = used_days + ?
                 WHERE user_id = ? AND leave_type_code = ? AND year = 2026`,
                [totalDays, totalDays, employeeId, leaveTypeCode]
            );
        } else if (action.toLowerCase() === 'reject') {
            // Update request
            await connection.query(
                `UPDATE leave_requests 
                 SET status = 'rejected', reviewed_by = ?, reviewed_at = NOW(), review_comment = ?
                 WHERE id = ?`,
                [managerName, comment || 'Rejected.', request.id]
            );

            // Update balance: release pending days
            await connection.query(
                `UPDATE leave_balances 
                 SET pending_days = GREATEST(0, pending_days - ?)
                 WHERE user_id = ? AND leave_type_code = ? AND year = 2026`,
                [totalDays, employeeId, leaveTypeCode]
            );
        } else {
            await connection.rollback();
            return res.status(400).json({ error: 'Invalid action. Expected "approve" or "reject"' });
        }

        await connection.commit();

        res.json({
            success: true,
            action,
            requestNumber: request.request_number,
            status: action.toLowerCase() === 'approve' ? 'Approved' : 'Rejected'
        });
    } catch (err) {
        await connection.rollback();
        console.error('Error reviewing leave request:', err);
        res.status(500).json({ error: 'Failed to process review', details: err.message });
    } finally {
        connection.release();
    }
});

module.exports = router;
