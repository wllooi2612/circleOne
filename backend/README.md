# circleOne 🌿 Web API (Backend Service)

Node.js + Express + MySQL 8/9 backend API service for the **circleOne** iOS Leave Application & Management App.

---

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment (`.env`)
```ini
PORT=3000
DB_HOST=127.0.0.1
DB_USER=root
DB_PASSWORD=
DB_NAME=circleone_db
DB_PORT=3306
```

### 3. Run the API Server
- **Production mode:**
  ```bash
  npm start
  ```
- **Hot-reloading Development mode:**
  ```bash
  npm run dev
  ```

Server will run on: `http://localhost:3000`

---

## 📡 RESTful Endpoints Reference

### 1. System Health
- **`GET /api/health`**
  - Check MySQL connectivity and server status.

### 2. Users & Team
- **`GET /api/users/profile?userId=EMP-9402`**
  - Returns current user profile (matches Swift `UserProfile`).
- **`POST /api/users/role`**
  - Switch active role between `'employee'` and `'manager'`.
- **`GET /api/users/team`**
  - Returns list of colleagues for handover (matches Swift `TeamMember`).

### 3. Leave Balances & Types
- **`GET /api/leaves/types`**
  - List all leave categories and policy rules.
- **`GET /api/leaves/balances?userId=EMP-9402&year=2026`**
  - Returns dynamic leave quotas and circular ring metrics (matches Swift `LeaveBalance`).

### 4. Leave Application Flow
- **`GET /api/leaves/requests?userId=EMP-9402`**
  - Returns employee's submitted requests history (matches Swift `LeaveRequest`).
- **`POST /api/leaves/apply`**
  - Submit a leave request with automatic balance checking and pending deduction.
  - Body:
    ```json
    {
      "employeeId": "EMP-9402",
      "leaveType": "Annual Leave",
      "durationType": "Multiple Days",
      "startDate": "2026-11-02",
      "endDate": "2026-11-03",
      "totalDays": 2.0,
      "reason": "Personal rest and recovery",
      "relieverName": "Elena Rostova"
    }
    ```

### 5. Manager Review Portal
- **`GET /api/manager/requests?status=pending`**
  - Inbox for manager review (filter by `pending` or `resolved`).
- **`POST /api/manager/review`**
  - Approve or reject a request with atomic quota deduction.
  - Body:
    ```json
    {
      "requestId": "LEV-2026-092",
      "action": "approve",
      "comment": "Approved! Make sure projects are covered.",
      "managerName": "Sarah Jenkins"
    }
    ```
