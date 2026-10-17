import SwiftUI

public struct UMobileBottomBar: View {
    @Binding public var selectedTab: Int
    public let onBuyTap: () -> Void
    
    public init(selectedTab: Binding<Int>, onBuyTap: @escaping () -> Void) {
        self._selectedTab = selectedTab
        self.onBuyTap = onBuyTap
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Main White Bar
            VStack(spacing: 0) {
                // Subtle top border hairline
                Rectangle()
                    .fill(Color.gray.opacity(0.18))
                    .frame(height: 0.8)
                
                HStack(alignment: .bottom, spacing: 0) {
                    // Tab 0: Home
                    tabItem(
                        index: 0,
                        title: "Home",
                        icon: "house.fill",
                        isCustomImage: false
                    )
                    
                    // Tab 1: My Plan
                    tabItem(
                        index: 1,
                        title: "My Plan",
                        icon: "line.3.horizontal",
                        isCustomImage: false
                    )
                    
                    // Center Slot Spacer for Floating Buy Button
                    VStack(spacing: 4) {
                        Spacer().frame(height: 28)
                        Text("Buy")
                            .font(.system(size: 11, weight: selectedTab == 2 ? .bold : .medium))
                            .foregroundColor(selectedTab == 2 ? UMobileTheme.uOrange : UMobileTheme.uTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Tab 3: Rewards
                    tabItem(
                        index: 3,
                        title: "Rewards",
                        icon: "gift",
                        isCustomImage: false
                    )
                    
                    // Tab 4: Upgrade
                    tabItem(
                        index: 4,
                        title: "Upgrade",
                        icon: "arrow.up.doc",
                        isCustomImage: false
                    )
                }
                .padding(.top, 8)
                .padding(.bottom, 6)
            }
            .frame(height: 64)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -3)
            
            // Center Floating "Buy" Button
            Button(action: {
                selectedTab = 2
                onBuyTap()
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [UMobileTheme.uOrange, UMobileTheme.uDeepOrange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: UMobileTheme.uOrange.opacity(0.45), radius: 8, x: 0, y: 4)
                    
                    // Stylized "u" logo
                    Text("u")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .italic()
                        .offset(y: -2)
                }
            }
            .buttonStyle(.plain)
            .offset(y: -18)
        }
    }
    
    @ViewBuilder
    private func tabItem(index: Int, title: String, icon: String, isCustomImage: Bool) -> some View {
        Button(action: {
            selectedTab = index
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: selectedTab == index ? .bold : .medium))
                    .foregroundColor(selectedTab == index ? UMobileTheme.uOrange : UMobileTheme.uTextSecondary)
                    .frame(height: 24)
                
                Text(title)
                    .font(.system(size: 11, weight: selectedTab == index ? .bold : .medium))
                    .foregroundColor(selectedTab == index ? UMobileTheme.uOrange : UMobileTheme.uTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
