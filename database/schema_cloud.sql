-- ============================================================
-- circleOne 🌿 Schema for Cloud (Railway)
-- Target Database: current selected database (e.g. railway)
-- ============================================================

-- 1. Users & Employees Table
CREATE TABLE IF NOT EXISTS `users` (
    `id` VARCHAR(50) NOT NULL PRIMARY KEY COMMENT '员工工号，如 EMP-9402',
    `name` VARCHAR(100) NOT NULL COMMENT '姓名',
    `email` VARCHAR(120) NOT NULL UNIQUE COMMENT '公司邮箱',
    `password_hash` VARCHAR(255) NULL COMMENT '密码哈希',
    `role` VARCHAR(100) NOT NULL COMMENT '职位头衔',
    `department` VARCHAR(100) NOT NULL COMMENT '所属部门',
    `employee_code` VARCHAR(50) NOT NULL COMMENT '员工卡号，如 CO-9402',
    `manager_id` VARCHAR(50) NULL COMMENT '直属主管ID',
    `manager_name` VARCHAR(100) NULL COMMENT '直属主管姓名',
    `initials` VARCHAR(10) NOT NULL COMMENT '头像缩写，如 AC',
    `active_role` ENUM('employee', 'manager') NOT NULL DEFAULT 'employee' COMMENT '当前视图角色',
    `avatar_color` VARCHAR(50) NOT NULL DEFAULT 'blue' COMMENT '头像主题色',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY `idx_department` (`department`),
    KEY `idx_manager_id` (`manager_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Leave Types Table
CREATE TABLE IF NOT EXISTS `leave_types` (
    `code` VARCHAR(50) NOT NULL PRIMARY KEY COMMENT '假种代码',
    `name` VARCHAR(100) NOT NULL COMMENT '假种名称',
    `description` VARCHAR(255) NULL COMMENT '说明与用途',
    `default_quota` DECIMAL(5,1) NOT NULL DEFAULT 0.0 COMMENT '默认年配额天数',
    `requires_attachment` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否强制要求凭证',
    `icon_name` VARCHAR(100) NOT NULL COMMENT 'SF Symbols 图标名',
    `tint_color` VARCHAR(50) NOT NULL COMMENT 'UI 颜色标识',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Leave Balances Table
CREATE TABLE IF NOT EXISTS `leave_balances` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` VARCHAR(50) NOT NULL COMMENT '所属员工ID',
    `leave_type_code` VARCHAR(50) NOT NULL COMMENT '假种代码',
    `year` INT NOT NULL DEFAULT 2026 COMMENT '年度',
    `total_quota` DECIMAL(5,1) NOT NULL DEFAULT 0.0 COMMENT '总配额天数',
    `used_days` DECIMAL(5,1) NOT NULL DEFAULT 0.0 COMMENT '已使用天数',
    `pending_days` DECIMAL(5,1) NOT NULL DEFAULT 0.0 COMMENT '待审批天数',
    `available_days` DECIMAL(5,1) GENERATED ALWAYS AS (total_quota - used_days - pending_days) STORED COMMENT '可用余额',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_leave_year` (`user_id`, `leave_type_code`, `year`),
    CONSTRAINT `fk_balance_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_balance_type` FOREIGN KEY (`leave_type_code`) REFERENCES `leave_types` (`code`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Leave Requests Table
CREATE TABLE IF NOT EXISTS `leave_requests` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY COMMENT 'UUID 主键',
    `request_number` VARCHAR(50) NOT NULL UNIQUE COMMENT '请假单编号',
    `employee_id` VARCHAR(50) NOT NULL COMMENT '申请人工号',
    `employee_name` VARCHAR(100) NOT NULL COMMENT '申请人姓名',
    `employee_role` VARCHAR(100) NOT NULL COMMENT '申请人职位',
    `employee_avatar_initials` VARCHAR(10) NOT NULL COMMENT '申请人头像缩写',
    `leave_type_code` VARCHAR(50) NOT NULL COMMENT '假种代码',
    `duration_type` ENUM('fullDay', 'halfDayAM', 'halfDayPM', 'multiDay') NOT NULL COMMENT '请假时长类型',
    `start_date` DATE NOT NULL COMMENT '开始日期',
    `end_date` DATE NOT NULL COMMENT '结束日期',
    `total_days` DECIMAL(5,1) NOT NULL COMMENT '实际工作日请假天数',
    `reason` TEXT NOT NULL COMMENT '请假事由',
    `reliever_id` VARCHAR(50) NULL COMMENT '工作交接人ID',
    `reliever_name` VARCHAR(100) NULL COMMENT '工作交接人姓名',
    `attachment_name` VARCHAR(255) NULL COMMENT '附件文件名',
    `attachment_url` VARCHAR(500) NULL COMMENT '附件存储URL或路径',
    `status` ENUM('pending', 'approved', 'rejected', 'cancelled') NOT NULL DEFAULT 'pending' COMMENT '审批状态',
    `applied_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请提交时间',
    `reviewed_by` VARCHAR(100) NULL COMMENT '审批主管姓名',
    `reviewed_at` DATETIME NULL COMMENT '审批时间',
    `review_comment` TEXT NULL COMMENT '主管批注/驳回原因',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY `idx_req_employee` (`employee_id`),
    KEY `idx_req_status` (`status`),
    KEY `idx_req_dates` (`start_date`, `end_date`),
    CONSTRAINT `fk_req_user` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_req_type` FOREIGN KEY (`leave_type_code`) REFERENCES `leave_types` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Public Holidays Table
CREATE TABLE IF NOT EXISTS `public_holidays` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL COMMENT '节日名称',
    `holiday_date` DATE NOT NULL UNIQUE COMMENT '休假日期',
    `year` INT NOT NULL COMMENT '年份',
    `description` VARCHAR(255) NULL COMMENT '节日说明'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Initial Seed Data
INSERT INTO `leave_types` (`code`, `name`, `description`, `default_quota`, `requires_attachment`, `icon_name`, `tint_color`) VALUES
('annual', 'Annual Leave', 'Vacation, personal holidays & rest', 18.0, 0, 'sun.max.fill', 'blue'),
('medical', 'Medical / Sick', 'Illness, doctor visits & medical checkups', 14.0, 1, 'cross.case.fill', 'red'),
('casual', 'Casual / Emergency', 'Unexpected urgent personal responsibilities', 5.0, 0, 'bolt.fill', 'orange'),
('parental', 'Parental Leave', 'Maternity, paternity & childcare care', 30.0, 0, 'figure.2.and.child.holdinghands', 'pink'),
('compassionate', 'Compassionate', 'Bereavement or severe family emergencies', 3.0, 1, 'heart.fill', 'purple'),
('unpaid', 'Unpaid Leave', 'Extended leave without monthly compensation', 30.0, 0, 'clock.arrow.circlepath', 'secondary')
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

INSERT INTO `users` (`id`, `name`, `email`, `role`, `department`, `employee_code`, `manager_id`, `manager_name`, `initials`, `active_role`, `avatar_color`) VALUES
('EMP-9402', 'Alex Chen', 'alex.c@circleone.co', 'Senior Product Designer', 'Design & UX', 'CO-9402', 'TM-101', 'Sarah Jenkins', 'AC', 'employee', 'blue'),
('TM-101', 'Sarah Jenkins', 'sarah.j@circleone.co', 'Design Director (Approver)', 'Design & UX', 'CO-101', NULL, NULL, 'SJ', 'manager', 'purple'),
('TM-102', 'Marcus Vance', 'marcus.v@circleone.co', 'Lead Systems Architect', 'Engineering', 'CO-102', 'TM-101', 'Sarah Jenkins', 'MV', 'employee', 'indigo'),
('TM-103', 'Priya Patel', 'priya.p@circleone.co', 'Product Manager', 'Product', 'CO-103', 'TM-101', 'Sarah Jenkins', 'PP', 'employee', 'teal'),
('TM-104', 'Liam Ross', 'liam.r@circleone.co', 'Senior iOS Engineer', 'Mobile', 'CO-104', 'TM-101', 'Sarah Jenkins', 'LR', 'employee', 'green'),
('TM-105', 'Elena Rostova', 'elena.r@circleone.co', 'Brand Experience Lead', 'Design & UX', 'CO-105', 'TM-101', 'Sarah Jenkins', 'ER', 'employee', 'pink')
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

INSERT INTO `leave_balances` (`user_id`, `leave_type_code`, `year`, `total_quota`, `used_days`, `pending_days`) VALUES
('EMP-9402', 'annual', 2026, 18.0, 5.0, 2.0),
('EMP-9402', 'medical', 2026, 14.0, 2.0, 0.0),
('EMP-9402', 'casual', 2026, 5.0, 1.0, 0.0),
('EMP-9402', 'parental', 2026, 30.0, 0.0, 0.0),
('EMP-9402', 'compassionate', 2026, 3.0, 0.0, 0.0),
('EMP-9402', 'unpaid', 2026, 30.0, 0.0, 0.0)
ON DUPLICATE KEY UPDATE `total_quota`=VALUES(`total_quota`), `used_days`=VALUES(`used_days`), `pending_days`=VALUES(`pending_days`);

INSERT INTO `public_holidays` (`name`, `holiday_date`, `year`, `description`) VALUES
('New Year\'s Day', '2026-01-01', 2026, 'Federal holiday'),
('Chinese New Year Day 1', '2026-02-17', 2026, 'Lunar New Year celebrations'),
('Chinese New Year Day 2', '2026-02-18', 2026, 'Lunar New Year celebrations'),
('Labor Day', '2026-05-01', 2026, 'International Workers\' Day'),
('National Day', '2026-08-31', 2026, 'Independence Day'),
('Christmas Day', '2026-12-25', 2026, 'Christmas celebration')
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

INSERT INTO `leave_requests` 
(`id`, `request_number`, `employee_id`, `employee_name`, `employee_role`, `employee_avatar_initials`, `leave_type_code`, `duration_type`, `start_date`, `end_date`, `total_days`, `reason`, `reliever_id`, `reliever_name`, `attachment_name`, `status`, `applied_at`, `reviewed_by`, `reviewed_at`, `review_comment`) VALUES
('req-001', 'LEV-2026-092', 'EMP-9402', 'Alex Chen', 'Senior Product Designer', 'AC', 'annual', 'multiDay', '2026-10-12', '2026-10-13', 2.0, 'Family trip and personal milestone celebration.', 'TM-105', 'Elena Rostova', NULL, 'pending', '2026-10-08 09:30:00', NULL, NULL, NULL),
('req-002', 'LEV-2026-041', 'EMP-9402', 'Alex Chen', 'Senior Product Designer', 'AC', 'annual', 'multiDay', '2026-09-14', '2026-09-16', 3.0, 'Design sprint recovery and personal time.', 'TM-105', 'Elena Rostova', NULL, 'approved', '2026-09-10 14:00:00', 'Sarah Jenkins', '2026-09-11 10:15:00', 'Approved. Please make sure design specs are handed over to Elena.'),
('req-003', 'LEV-2026-015', 'EMP-9402', 'Alex Chen', 'Senior Product Designer', 'AC', 'medical', 'multiDay', '2026-08-04', '2026-08-05', 2.0, 'Seasonal viral flu and high fever.', 'TM-102', 'Marcus Vance', 'doctor_slip_ac.pdf', 'approved', '2026-08-04 08:30:00', 'Sarah Jenkins', '2026-08-04 11:20:00', 'Rest well! Digital MC confirmed.')
ON DUPLICATE KEY UPDATE `status`=VALUES(`status`);
