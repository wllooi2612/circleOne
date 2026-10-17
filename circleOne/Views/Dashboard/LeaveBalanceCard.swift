import SwiftUI

public struct LeaveBalanceCard: View {
    public let balance: LeaveBalance
    public var onSelect: (() -> Void)? = nil
    
    public init(balance: LeaveBalance, onSelect: (() -> Void)? = nil) {
        self.balance = balance
        self.onSelect = onSelect
    }
    
    public var body: some View {
        Button {
            onSelect?()
        } label: {
            HStack(spacing: 16) {
                BalanceRingView(balance: balance, ringSize: 64, lineWidth: 7)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: balance.type.iconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(balance.type.tintColor)
                        
                        Text(balance.type.rawValue)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Text("\(balance.formattedTotal) days annual quota")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(balance.type.tintColor)
                                .frame(width: 6, height: 6)
                            Text("Used: \(formatNum(balance.usedDays))")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        
                        if balance.pendingDays > 0 {
                            HStack(spacing: 3) {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 6, height: 6)
                                Text("Pending: \(formatNum(balance.pendingDays))")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.secondary.opacity(0.5))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.circleCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func formatNum(_ val: Double) -> String {
        val.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(val))" : String(format: "%.1f", val)
    }
}
