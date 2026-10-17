import SwiftUI

public struct LeaveBalance: Identifiable, Codable, Sendable {
    public let id: UUID
    public let type: LeaveType
    public var totalQuota: Double
    public var usedDays: Double
    public var pendingDays: Double
    
    public init(id: UUID = UUID(), type: LeaveType, totalQuota: Double, usedDays: Double, pendingDays: Double = 0.0) {
        self.id = id
        self.type = type
        self.totalQuota = totalQuota
        self.usedDays = usedDays
        self.pendingDays = pendingDays
    }
    
    public var availableDays: Double {
        max(0, totalQuota - usedDays - pendingDays)
    }
    
    public var usagePercentage: Double {
        guard totalQuota > 0 else { return 0 }
        return min(1.0, (usedDays + pendingDays) / totalQuota)
    }
    
    public var formattedAvailable: String {
        if availableDays.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(availableDays))"
        } else {
            return String(format: "%.1f", availableDays)
        }
    }
    
    public var formattedTotal: String {
        if totalQuota.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(totalQuota))"
        } else {
            return String(format: "%.1f", totalQuota)
        }
    }
}
