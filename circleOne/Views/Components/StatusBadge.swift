import SwiftUI

public struct StatusBadge: View {
    public let status: LeaveStatus
    public var isCompact: Bool = false
    
    public init(status: LeaveStatus, isCompact: Bool = false) {
        self.status = status
        self.isCompact = isCompact
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .font(.system(size: isCompact ? 10 : 12, weight: .semibold))
            
            Text(status.rawValue)
                .font(.system(size: isCompact ? 11 : 13, weight: .semibold))
        }
        .padding(.horizontal, isCompact ? 8 : 10)
        .padding(.vertical, isCompact ? 4 : 5)
        .foregroundColor(status.tintColor)
        .background(
            Capsule()
                .fill(status.tintColor.opacity(0.14))
        )
        .overlay(
            Capsule()
                .stroke(status.tintColor.opacity(0.25), lineWidth: 0.8)
        )
    }
}

#if DEBUG
struct StatusBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            StatusBadge(status: .pending)
            StatusBadge(status: .approved)
            StatusBadge(status: .rejected)
            StatusBadge(status: .cancelled)
        }
        .padding()
    }
}
#endif
