import SwiftUI

public struct UpcomingLeavesCard: View {
    public let requests: [LeaveRequest]
    public var onSeeAll: (() -> Void)? = nil
    
    public init(requests: [LeaveRequest], onSeeAll: (() -> Void)? = nil) {
        self.requests = requests
        self.onSeeAll = onSeeAll
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.blue)
                    Text("Your Upcoming Time Off")
                        .font(.system(size: 17, weight: .bold))
                }
                
                Spacer()
                
                if !requests.isEmpty {
                    Button("See All") {
                        onSeeAll?()
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.blue)
                }
            }
            
            if requests.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "sun.horizon")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary)
                        Text("No upcoming time off booked")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                ForEach(requests.prefix(3)) { req in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(req.leaveType.tintColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: req.leaveType.iconName)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(req.leaveType.tintColor)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(req.leaveType.rawValue)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(req.formattedDateRange)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("\(formatDays(req.totalDays)) days")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                            
                            StatusBadge(status: req.status, isCompact: true)
                        }
                    }
                    .padding(10)
                    .background(Color.circleSubCardBackground.opacity(0.6))
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.circleCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
    
    private func formatDays(_ days: Double) -> String {
        days.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(days))" : String(format: "%.1f", days)
    }
}
