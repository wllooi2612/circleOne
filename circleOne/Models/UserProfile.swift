import SwiftUI

public struct TeamMember: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var name: String
    public var role: String
    public var department: String
    public var initials: String
    public var email: String
    public var accentColorName: String
    
    public init(id: String, name: String, role: String, department: String, initials: String, email: String, accentColorName: String = "blue") {
        self.id = id
        self.name = name
        self.role = role
        self.department = department
        self.initials = initials
        self.email = email
        self.accentColorName = accentColorName
    }
    
    public var avatarColor: Color {
        switch accentColorName {
        case "teal": return Color.teal
        case "indigo": return Color.indigo
        case "purple": return Color.purple
        case "orange": return Color.orange
        case "green": return Color.green
        case "pink": return Color.pink
        default: return Color.blue
        }
    }
}

public enum AppUserRole: String, CaseIterable, Identifiable, Codable, Sendable {
    case employee = "Team Member (Employee)"
    case manager = "Team Lead / Approver (Manager)"
    
    public var id: String { rawValue }
    
    public var badgeTitle: String {
        switch self {
        case .employee: return "Employee Mode"
        case .manager: return "Manager Mode"
        }
    }
}

public struct UserProfile: Identifiable, Codable, Sendable {
    public let id: String
    public var name: String
    public var role: String
    public var department: String
    public var employeeCode: String
    public var managerName: String
    public var initials: String
    public var activeRole: AppUserRole
    
    public init(
        id: String = "EMP-9402",
        name: String = "Alex Chen",
        role: String = "Senior Product Designer",
        department: String = "Design & Experience",
        employeeCode: String = "CO-9402",
        managerName: String = "Sarah Jenkins",
        initials: String = "AC",
        activeRole: AppUserRole = .employee
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.department = department
        self.employeeCode = employeeCode
        self.managerName = managerName
        self.initials = initials
        self.activeRole = activeRole
    }
}
