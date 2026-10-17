const express = require('express');
const router = express.Router();
const db = require('../db');

// Helper to format active role for Swift iOS App
function mapActiveRole(role) {
    if (role === 'manager' || role === 'Team Lead / Approver (Manager)') {
        return 'Team Lead / Approver (Manager)';
    }
    return 'Team Member (Employee)';
}

/**
 * GET /api/users/profile
 * Query: ?userId=EMP-9402 (defaults to 'EMP-9402')
 * Returns UserProfile matching Swift model
 */
router.get('/profile', async (req, res) => {
    try {
        const userId = req.query.userId || 'EMP-9402';
        const [rows] = await db.query(
            'SELECT * FROM users WHERE id = ?',
            [userId]
        );

        if (rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const user = rows[0];
        res.json({
            id: user.id,
            name: user.name,
            role: user.role,
            department: user.department,
            employeeCode: user.employee_code,
            managerName: user.manager_name || 'Sarah Jenkins',
            initials: user.initials,
            activeRole: mapActiveRole(user.active_role),
            email: user.email,
            avatarColor: user.avatar_color
        });
    } catch (err) {
        console.error('Error fetching profile:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
});

/**
 * POST /api/users/role
 * Body: { userId: 'EMP-9402', role: 'employee' | 'manager' }
 * Toggles or updates the user's active role mode
 */
router.post('/role', async (req, res) => {
    try {
        const { userId = 'EMP-9402', role } = req.body;
        const normalizedRole = (role && role.toLowerCase().includes('manager')) ? 'manager' : 'employee';

        await db.query(
            'UPDATE users SET active_role = ? WHERE id = ?',
            [normalizedRole, userId]
        );

        res.json({
            success: true,
            activeRole: mapActiveRole(normalizedRole)
        });
    } catch (err) {
        console.error('Error updating role:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
});

/**
 * GET /api/users/team
 * Returns list of team members matching Swift TeamMember model
 */
router.get('/team', async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT id, name, role, department, initials, email, avatar_color AS accentColorName FROM users ORDER BY id'
        );

        res.json(rows);
    } catch (err) {
        console.error('Error fetching team members:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
});

module.exports = router;
