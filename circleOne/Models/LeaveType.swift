import SwiftUI

public enum LeaveType: String, CaseIterable, Identifiable, Codable, Sendable {
    case annual = "Annual Leave"
    case medical = "Medical / Sick"
    case casual = "Casual / Emergency"
    case parental = "Parental Leave"
    case compassionate = "Compassionate"
    case unpaid = "Unpaid Leave"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .annual: return "sun.max.fill"
        case .medical: return "cross.case.fill"
        case .casual: return "bolt.fill"
        case .parental: return "figure.2.and.child.holdinghands"
        case .compassionate: return "heart.fill"
        case .unpaid: return "clock.arrow.circlepath"
        }
    }
    
    public var tintColor: Color {
        switch self {
        case .annual: return Color.blue
        case .medical: return Color.red
        case .casual: return Color.orange
        case .parental: return Color.pink
        case .compassionate: return Color.purple
        case .unpaid: return Color.secondary
        }
    }
    
    public var description: String {
        switch self {
        case .annual: return "Vacation, personal holidays & rest"
        case .medical: return "Illness, doctor visits & medical checkups"
        case .casual: return "Unexpected urgent personal responsibilities"
        case .parental: return "Maternity, paternity & childcare care"
        case .compassionate: return "Bereavement or severe family emergencies"
        case .unpaid: return "Extended leave without monthly compensation"
        }
    }
    
    public var requiresAttachment: Bool {
        switch self {
        case .medical, .compassionate: return true
        default: return false
        }
    }
    
    public var maxDefaultDays: Double {
        switch self {
        case .annual: return 18.0
        case .medical: return 14.0
        case .casual: return 5.0
        case .parental: return 30.0
        case .compassionate: return 3.0
        case .unpaid: return 30.0
        }
    }
}
