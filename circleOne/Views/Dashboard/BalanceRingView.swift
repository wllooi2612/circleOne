import SwiftUI

public struct BalanceRingView: View {
    public let balance: LeaveBalance
    public var ringSize: CGFloat = 80
    public var lineWidth: CGFloat = 8
    
    public init(balance: LeaveBalance, ringSize: CGFloat = 80, lineWidth: CGFloat = 8) {
        self.balance = balance
        self.ringSize = ringSize
        self.lineWidth = lineWidth
    }
    
    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    balance.type.tintColor.opacity(0.15),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            // Pending proportion (if any)
            if balance.totalQuota > 0 && balance.pendingDays > 0 {
                let pendingRatio = (balance.usedDays + balance.pendingDays) / balance.totalQuota
                Circle()
                    .trim(from: 0, to: min(1.0, CGFloat(pendingRatio)))
                    .stroke(
                        Color.orange.opacity(0.6),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            
            // Used proportion
            if balance.totalQuota > 0 {
                let usedRatio = balance.usedDays / balance.totalQuota
                Circle()
                    .trim(from: 0, to: min(1.0, CGFloat(usedRatio)))
                    .stroke(
                        balance.type.tintColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: balance.usedDays)
            }
            
            // Center content
            VStack(spacing: 0) {
                Text(balance.formattedAvailable)
                    .font(.system(size: ringSize * 0.28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("left")
                    .font(.system(size: ringSize * 0.12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: ringSize, height: ringSize)
    }
}
