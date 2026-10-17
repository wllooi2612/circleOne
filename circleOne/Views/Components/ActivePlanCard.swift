import SwiftUI

public struct ActivePlanCard: View {
    public let plan: PostpaidPlan
    public let onPlanDetailTap: () -> Void
    public let onUpgradeTap: () -> Void
    
    public init(
        plan: PostpaidPlan,
        onPlanDetailTap: @escaping () -> Void,
        onUpgradeTap: @escaping () -> Void
    ) {
        self.plan = plan
        self.onPlanDetailTap = onPlanDetailTap
        self.onUpgradeTap = onUpgradeTap
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Row
            Button(action: onPlanDetailTap) {
                HStack {
                    Text(plan.planName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.circle")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)
            
            // Divider 1
            Rectangle()
                .fill(Color.white.opacity(0.18))
                .frame(height: 0.8)
            
            // Middle Content: Data Quota & Progress
            VStack(alignment: .leading, spacing: 12) {
                Text(plan.planSubtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.92))
                
                HStack(alignment: .lastTextBaseline, spacing: 1) {
                    Text(plan.formattedUsedData)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(" /\(plan.formattedTotalData)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.85))
                    
                    Spacer()
                }
                
                // Progress Slider Bar with Thumb Dot
                GeometryReader { geo in
                    let totalWidth = geo.size.width
                    // 6.29 / 500GB is ~1.26%, clamp minimum so thumb is visible
                    let clampedRatio = max(0.03, min(1.0, plan.usedDataGB / plan.totalDataGB))
                    let activeWidth = totalWidth * clampedRatio
                    
                    ZStack(alignment: .leading) {
                        // Track
                        Capsule()
                            .fill(Color.white.opacity(0.24))
                            .frame(height: 5)
                        
                        // Active Fill
                        Capsule()
                            .fill(Color.white)
                            .frame(width: activeWidth, height: 5)
                        
                        // Thumb Dot
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .offset(x: max(0, activeWidth - 6))
                    }
                }
                .frame(height: 14)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 16)
            
            // Divider 2
            Rectangle()
                .fill(Color.white.opacity(0.18))
                .frame(height: 0.8)
            
            // Bottom Action Row: Upgrade Plan Now
            Button(action: onUpgradeTap) {
                HStack {
                    Text("Upgrade Plan Now")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.circle")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.black.opacity(0.32))
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}
