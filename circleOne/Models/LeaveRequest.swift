import SwiftUI

public enum LeaveDurationType: String, CaseIterable, Identifiable, Codable, Sendable {
    case fullDay = "Full Day (1.0)"
    case halfDayAM = "Morning AM (0.5)"
    case halfDayPM = "Afternoon PM (0.5)"
    case multiDay = "Multiple Days"
    
    public var id: String { rawValue }
    
    public var dayValue: Double {
        switch self {
        case .fullDay: return 1.0
        case .halfDayAM, .halfDayPM: return 0.5
        case .multiDay: return 0.0 // Computed from date range
        }
    }
}

public enum LeaveStatus: String, CaseIterable, Identifiable, Codable, Sendable {
    case pending = "Pending Approval"
    case approved = "Approved"
    case rejected = "Rejected"
    case cancelled = "Cancelled"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .pending: return "hourglass"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .cancelled: return "slash.circle.fill"
        }
    }
    
    public var tintColor: Color {
        switch self {
        case .pending: return Color.orange
        case .approved: return Color.green
        case .rejected: return Color.red
        case .cancelled: return Color.secondary
        }
    }
}

public struct LeaveRequest: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var requestNumber: String
    public var employeeId: String
    public var employeeName: String
    public var employeeRole: String
    public var employeeAvatarInitials: String
    public var leaveType: LeaveType
    public var durationType: LeaveDurationType
    public var startDate: Date
    public var endDate: Date
    public var totalDays: Double
    public var reason: String
    public var relieverName: String?
    public var attachmentName: String?
    public var status: LeaveStatus
    public var appliedAt: Date
    public var reviewedBy: String?
    public var reviewedAt: Date?
    public var reviewComment: String?
    
    public init(
        id: UUID = UUID(),
        requestNumber: String = "LEV-\(Int.random(in: 1000...9999))",
        employeeId: String,
        employeeName: String,
        employeeRole: String,
        employeeAvatarInitials: String,
        leaveType: LeaveType,
        durationType: LeaveDurationType,
        startDate: Date,
        endDate: Date,
        totalDays: Double,
        reason: String,
        relieverName: String? = nil,
        attachmentName: String? = nil,
        status: LeaveStatus = .pending,
        appliedAt: Date = Date(),
        reviewedBy: String? = nil,
        reviewedAt: Date? = nil,
        reviewComment: String? = nil
    ) {
        self.id = id
        self.requestNumber = requestNumber
        self.employeeId = employeeId
        self.employeeName = employeeName
        self.employeeRole = employeeRole
        self.employeeAvatarInitials = employeeAvatarInitials
        self.leaveType = leaveType
        self.durationType = durationType
        self.startDate = startDate
        self.endDate = endDate
        self.totalDays = totalDays
        self.reason = reason
        self.relieverName = relieverName
        self.attachmentName = attachmentName
        self.status = status
        self.appliedAt = appliedAt
        self.reviewedBy = reviewedBy
        self.reviewedAt = reviewedAt
        self.reviewComment = reviewComment
    }
    
    public var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        
        let cal = Calendar.current
        if cal.isDate(startDate, inSameDayAs: endDate) {
            return formatter.string(from: startDate)
        } else {
            let startFormatter = DateFormatter()
            startFormatter.dateFormat = "MMM d"
            return "\(startFormatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }
}
