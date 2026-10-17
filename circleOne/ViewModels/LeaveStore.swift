import SwiftUI
import Foundation
import Observation

public enum LeaveSubmissionError: LocalizedError, Sendable {
    case message(String)
    
    public var errorDescription: String? {
        switch self {
        case .message(let text):
            return text
        }
    }
}

@Observable
public final class LeaveStore {
    public var currentUser: UserProfile
    public var balances: [LeaveBalance]
    public var requests: [LeaveRequest]
    public var teamMembers: [TeamMember]
    
    // UI Feedback state
    public var lastSubmittedRequest: LeaveRequest?
    public var showSubmissionSuccessAlert: Bool = false
    public var alertMessage: String = ""
    
    public init() {
        self.currentUser = UserProfile(
            id: "EMP-9402",
            name: "Alex Chen",
            role: "Senior Product Designer",
            department: "Design & UX",
            employeeCode: "CO-9402",
            managerName: "Sarah Jenkins",
            initials: "AC",
            activeRole: .employee
        )
        
        self.balances = [
            LeaveBalance(type: .annual, totalQuota: 18.0, usedDays: 5.0, pendingDays: 2.0),
            LeaveBalance(type: .medical, totalQuota: 14.0, usedDays: 2.0, pendingDays: 0.0),
            LeaveBalance(type: .casual, totalQuota: 5.0, usedDays: 1.0, pendingDays: 0.0),
            LeaveBalance(type: .parental, totalQuota: 30.0, usedDays: 0.0, pendingDays: 0.0),
            LeaveBalance(type: .compassionate, totalQuota: 3.0, usedDays: 0.0, pendingDays: 0.0),
            LeaveBalance(type: .unpaid, totalQuota: 30.0, usedDays: 0.0, pendingDays: 0.0)
        ]
        
        self.teamMembers = [
            TeamMember(id: "TM-101", name: "Sarah Jenkins", role: "Design Director (Approver)", department: "Design & UX", initials: "SJ", email: "sarah.j@circleone.co", accentColorName: "purple"),
            TeamMember(id: "TM-102", name: "Marcus Vance", role: "Lead Systems Architect", department: "Engineering", initials: "MV", email: "marcus.v@circleone.co", accentColorName: "indigo"),
            TeamMember(id: "TM-103", name: "Priya Patel", role: "Product Manager", department: "Product", initials: "PP", email: "priya.p@circleone.co", accentColorName: "teal"),
            TeamMember(id: "TM-104", name: "Liam Ross", role: "Senior iOS Engineer", department: "Mobile", initials: "LR", email: "liam.r@circleone.co", accentColorName: "green"),
            TeamMember(id: "TM-105", name: "Elena Rostova", role: "Brand Experience Lead", department: "Design & UX", initials: "ER", email: "elena.r@circleone.co", accentColorName: "pink")
        ]
        
        let cal = Calendar.current
        let today = Date()
        
        // Seed past & upcoming leave requests
        let date1 = cal.date(byAdding: .day, value: 5, to: today) ?? today
        let date2 = cal.date(byAdding: .day, value: 6, to: today) ?? today
        
        let pastDateStart = cal.date(byAdding: .day, value: -20, to: today) ?? today
        let pastDateEnd = cal.date(byAdding: .day, value: -18, to: today) ?? today
        
        let teamPendingStart = cal.date(byAdding: .day, value: 2, to: today) ?? today
        let teamPendingEnd = cal.date(byAdding: .day, value: 3, to: today) ?? today
        
        let teamPendingStart2 = cal.date(byAdding: .day, value: 7, to: today) ?? today

        self.requests = [
            // Current User's pending request
            LeaveRequest(
                requestNumber: "LEV-2026-092",
                employeeId: "EMP-9402",
                employeeName: "Alex Chen",
                employeeRole: "Senior Product Designer",
                employeeAvatarInitials: "AC",
                leaveType: .annual,
                durationType: .multiDay,
                startDate: date1,
                endDate: date2,
                totalDays: 2.0,
                reason: "Family trip and personal milestone celebration.",
                relieverName: "Elena Rostova",
                status: .pending,
                appliedAt: cal.date(byAdding: .hour, value: -4, to: today) ?? today
            ),
            // Current User's past approved request
            LeaveRequest(
                requestNumber: "LEV-2026-041",
                employeeId: "EMP-9402",
                employeeName: "Alex Chen",
                employeeRole: "Senior Product Designer",
                employeeAvatarInitials: "AC",
                leaveType: .annual,
                durationType: .multiDay,
                startDate: pastDateStart,
                endDate: pastDateEnd,
                totalDays: 3.0,
                reason: "Annual summer rejuvenation break.",
                relieverName: "Elena Rostova",
                status: .approved,
                appliedAt: cal.date(byAdding: .day, value: -25, to: today) ?? today,
                reviewedBy: "Sarah Jenkins",
                reviewedAt: cal.date(byAdding: .day, value: -24, to: today),
                reviewComment: "Approved. Enjoy your time off Alex!"
            ),
            // Current User's past medical leave
            LeaveRequest(
                requestNumber: "LEV-2026-033",
                employeeId: "EMP-9402",
                employeeName: "Alex Chen",
                employeeRole: "Senior Product Designer",
                employeeAvatarInitials: "AC",
                leaveType: .medical,
                durationType: .fullDay,
                startDate: cal.date(byAdding: .day, value: -40, to: today) ?? today,
                endDate: cal.date(byAdding: .day, value: -39, to: today) ?? today,
                totalDays: 2.0,
                reason: "Seasonal flu recovery as advised by clinic.",
                relieverName: "Priya Patel",
                attachmentName: "Medical_Certificate_AC.pdf",
                status: .approved,
                appliedAt: cal.date(byAdding: .day, value: -41, to: today) ?? today,
                reviewedBy: "Sarah Jenkins",
                reviewedAt: cal.date(byAdding: .day, value: -40, to: today),
                reviewComment: "Get well soon."
            ),
            // Teammate 1 pending request (for manager approval view)
            LeaveRequest(
                requestNumber: "LEV-2026-105",
                employeeId: "TM-104",
                employeeName: "Liam Ross",
                employeeRole: "Senior iOS Engineer",
                employeeAvatarInitials: "LR",
                leaveType: .annual,
                durationType: .multiDay,
                startDate: teamPendingStart,
                endDate: teamPendingEnd,
                totalDays: 2.0,
                reason: "Attending Swift Developer Summit & regional workshop.",
                relieverName: "Marcus Vance",
                status: .pending,
                appliedAt: cal.date(byAdding: .hour, value: -12, to: today) ?? today
            ),
            // Teammate 2 pending request (for manager approval view)
            LeaveRequest(
                requestNumber: "LEV-2026-108",
                employeeId: "TM-105",
                employeeName: "Elena Rostova",
                employeeRole: "Brand Experience Lead",
                employeeAvatarInitials: "ER",
                leaveType: .casual,
                durationType: .halfDayAM,
                startDate: teamPendingStart2,
                endDate: teamPendingStart2,
                totalDays: 0.5,
                reason: "Urgent residential utility maintenance inspection.",
                relieverName: "Alex Chen",
                status: .pending,
                appliedAt: cal.date(byAdding: .hour, value: -2, to: today) ?? today
            ),
            // Teammate 3 approved request
            LeaveRequest(
                requestNumber: "LEV-2026-077",
                employeeId: "TM-103",
                employeeName: "Priya Patel",
                employeeRole: "Product Manager",
                employeeAvatarInitials: "PP",
                leaveType: .annual,
                durationType: .multiDay,
                startDate: cal.date(byAdding: .day, value: 1, to: today) ?? today,
                endDate: cal.date(byAdding: .day, value: 4, to: today) ?? today,
                totalDays: 4.0,
                reason: "Quarterly family reunion.",
                relieverName: "Marcus Vance",
                status: .approved,
                appliedAt: cal.date(byAdding: .day, value: -5, to: today) ?? today,
                reviewedBy: "Sarah Jenkins",
                reviewedAt: cal.date(byAdding: .day, value: -4, to: today),
                reviewComment: "Approved. Marcus will handle urgent syncs."
            )
        ]
    }
    
    // MARK: - Working Days Calculation
    public func calculateWorkingDays(from start: Date, to end: Date, duration: LeaveDurationType) -> Double {
        if duration == .halfDayAM || duration == .halfDayPM {
            return 0.5
        }
        
        let cal = Calendar.current
        var current = cal.startOfDay(for: start)
        let finish = cal.startOfDay(for: end)
        
        if current > finish {
            return 0.0
        }
        
        var count: Double = 0.0
        while current <= finish {
            let weekday = cal.component(.weekday, from: current)
            // 1 = Sunday, 7 = Saturday
            if weekday != 1 && weekday != 7 {
                count += 1.0
            }
            guard let next = cal.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        
        return count
    }
    
    // MARK: - Balance Helper
    public func balance(for type: LeaveType) -> LeaveBalance? {
        balances.first(where: { $0.type == type })
    }
    
    // MARK: - Leave Application Submission
    @discardableResult
    public func submitLeave(
        type: LeaveType,
        duration: LeaveDurationType,
        startDate: Date,
        endDate: Date,
        reason: String,
        reliever: String?,
        attachmentName: String?
    ) -> Result<LeaveRequest, LeaveSubmissionError> {
        let trimmedReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedReason.isEmpty {
            return .failure(.message("Please provide a brief reason or note for your leave request."))
        }
        
        let totalDays = calculateWorkingDays(from: startDate, to: endDate, duration: duration)
        if totalDays <= 0 {
            return .failure(.message("Selected date range contains no working days (e.g., weekends only)."))
        }
        
        if let balance = balance(for: type) {
            if totalDays > balance.availableDays {
                return .failure(.message("Insufficient balance. You have \(balance.formattedAvailable) days available for \(type.rawValue), but requested \(totalDays) days."))
            }
        }
        
        if type.requiresAttachment && (attachmentName == nil || attachmentName?.isEmpty == true) {
            return .failure(.message("\(type.rawValue) requires supporting document (e.g. Medical Certificate)."))
        }
        
        let newRequest = LeaveRequest(
            employeeId: currentUser.id,
            employeeName: currentUser.name,
            employeeRole: currentUser.role,
            employeeAvatarInitials: currentUser.initials,
            leaveType: type,
            durationType: duration,
            startDate: startDate,
            endDate: (duration == .halfDayAM || duration == .halfDayPM) ? startDate : endDate,
            totalDays: totalDays,
            reason: trimmedReason,
            relieverName: reliever,
            attachmentName: attachmentName,
            status: .pending,
            appliedAt: Date()
        )
        
        requests.insert(newRequest, at: 0)
        
        // Update user's pending balance
        if let idx = balances.firstIndex(where: { $0.type == type }) {
            balances[idx].pendingDays += totalDays
        }
        
        lastSubmittedRequest = newRequest
        showSubmissionSuccessAlert = true
        return .success(newRequest)
    }
    
    // MARK: - Cancel Leave Request
    public func cancelLeave(requestId: UUID) {
        guard let idx = requests.firstIndex(where: { $0.id == requestId }) else { return }
        let req = requests[idx]
        if req.status == .pending {
            // Refund pending days
            if let bIdx = balances.firstIndex(where: { $0.type == req.leaveType }) {
                balances[bIdx].pendingDays = max(0, balances[bIdx].pendingDays - req.totalDays)
            }
        } else if req.status == .approved {
            // If future approved leave, restore used days
            if req.startDate >= Date() {
                if let bIdx = balances.firstIndex(where: { $0.type == req.leaveType }) {
                    balances[bIdx].usedDays = max(0, balances[bIdx].usedDays - req.totalDays)
                }
            }
        }
        requests[idx].status = .cancelled
    }
    
    // MARK: - Manager Approvals
    public func approveLeave(requestId: UUID, comment: String? = nil) {
        guard let idx = requests.firstIndex(where: { $0.id == requestId }) else { return }
        requests[idx].status = .approved
        requests[idx].reviewedBy = currentUser.name
        requests[idx].reviewedAt = Date()
        requests[idx].reviewComment = comment
        
        // If it's the current user's request, update balances
        let req = requests[idx]
        if req.employeeId == currentUser.id {
            if let bIdx = balances.firstIndex(where: { $0.type == req.leaveType }) {
                balances[bIdx].pendingDays = max(0, balances[bIdx].pendingDays - req.totalDays)
                balances[bIdx].usedDays += req.totalDays
            }
        }
    }
    
    public func rejectLeave(requestId: UUID, comment: String? = nil) {
        guard let idx = requests.firstIndex(where: { $0.id == requestId }) else { return }
        let req = requests[idx]
        requests[idx].status = .rejected
        requests[idx].reviewedBy = currentUser.name
        requests[idx].reviewedAt = Date()
        requests[idx].reviewComment = comment
        
        if req.employeeId == currentUser.id {
            if let bIdx = balances.firstIndex(where: { $0.type == req.leaveType }) {
                balances[bIdx].pendingDays = max(0, balances[bIdx].pendingDays - req.totalDays)
            }
        }
    }
    
    // MARK: - Role Toggle
    public func toggleRole() {
        if currentUser.activeRole == .employee {
            currentUser.activeRole = .manager
        } else {
            currentUser.activeRole = .employee
        }
    }
    
    // MARK: - Queries
    public var pendingApprovalsForManager: [LeaveRequest] {
        requests.filter { $0.status == .pending }
    }
    
    public var currentUserRequests: [LeaveRequest] {
        requests.filter { $0.employeeId == currentUser.id }
    }
    
    public var upcomingLeaves: [LeaveRequest] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return requests
            .filter { $0.employeeId == currentUser.id && $0.status != .rejected && $0.status != .cancelled && $0.endDate >= today }
            .sorted { $0.startDate < $1.startDate }
    }
    
    public func leavesOn(date: Date) -> [LeaveRequest] {
        let cal = Calendar.current
        let target = cal.startOfDay(for: date)
        return requests.filter { req in
            guard req.status == .approved || req.status == .pending else { return false }
            let s = cal.startOfDay(for: req.startDate)
            let e = cal.startOfDay(for: req.endDate)
            return target >= s && target <= e
        }
    }
}
