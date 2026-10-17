import SwiftUI

// MARK: - My Plan Tab
public struct MyPlanView: View {
    @Environment(UMobileStore.self) private var store
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Plan Banner
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(store.activePlan.planName)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(UMobileTheme.uTextDark)
                                Text(store.currentAccount.phoneNumber)
                                    .font(.system(size: 14))
                                    .foregroundColor(UMobileTheme.uTextSecondary)
                            }
                            Spacer()
                            Text("ACTIVE")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        
                        Divider()
                        
                        // Quota usage breakdown
                        VStack(spacing: 12) {
                            quotaRow(title: "Base 5G/4G Data", used: "\(store.activePlan.formattedUsedData) GB", total: store.activePlan.formattedTotalData, ratio: store.activePlan.usedDataGB / store.activePlan.totalDataGB)
                            quotaRow(title: "Hotspot Quota", used: "\(String(format: "%.2f", store.activePlan.hotspotUsedGB)) GB", total: "\(Int(store.activePlan.hotspotTotalGB))GB", ratio: store.activePlan.hotspotUsedGB / store.activePlan.hotspotTotalGB)
                            quotaRow(title: "Free Global Roaming", used: "0 GB", total: "15GB (63 Countries)", ratio: 0.0)
                            quotaRow(title: "Domestic Calls & SMS", used: "Unlimited", total: "Included", ratio: 0.1)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    // Manage Plan Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Plan Actions")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(UMobileTheme.uTextDark)
                        
                        Button(action: {
                            store.activeSheet = .addOns
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(UMobileTheme.uOrange)
                                Text("Get Extra High-Speed Data Booster")
                                    .foregroundColor(UMobileTheme.uTextDark)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(UMobileTheme.uTextSecondary)
                            }
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            store.activeSheet = .upgradePlan
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(UMobileTheme.uOrange)
                                Text("Change or Upgrade Postpaid Plan")
                                    .foregroundColor(UMobileTheme.uTextDark)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(UMobileTheme.uTextSecondary)
                            }
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
            }
            .background(UMobileTheme.uCreamTile.opacity(0.5))
            .navigationTitle("My Plan")
        }
    }
    
    private func quotaRow(title: String, used: String, total: String, ratio: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(UMobileTheme.uTextDark)
                Spacer()
                Text("\(used) / \(total)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(UMobileTheme.uTextSecondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)
                    Capsule()
                        .fill(UMobileTheme.uOrange)
                        .frame(width: max(8, geo.size.width * CGFloat(min(max(ratio, 0.0), 1.0))), height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Buy Tab
public struct BuyView: View {
    @Environment(UMobileStore.self) private var store
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Categories
                    HStack(spacing: 12) {
                        categoryTile(title: "5G Devices", icon: "iphone.gen3")
                        categoryTile(title: "Home 5G", icon: "wifi.router")
                        categoryTile(title: "Prepaid", icon: "simcard")
                        categoryTile(title: "Fibre", icon: "cable.connector")
                    }
                    
                    // Device Highlights
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Latest 5G Phones on U Postpaid")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(UMobileTheme.uTextDark)
                        
                        deviceCard(name: "iPhone 16 Pro 128GB", plan: "With U Postpaid 98", price: "RM 0 Upfront*", badge: "HOT")
                        deviceCard(name: "Samsung Galaxy S24 Ultra", plan: "With U Postpaid 98", price: "From RM78/month", badge: "0% APR")
                        deviceCard(name: "Honor Magic V3", plan: "With U Postpaid 68", price: "Special Rebate RM500", badge: "EXCLUSIVE")
                    }
                }
                .padding(18)
            }
            .background(UMobileTheme.uCreamTile.opacity(0.5))
            .navigationTitle("Buy & Shop")
        }
    }
    
    private func categoryTile(title: String, icon: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(UMobileTheme.uLightOrange)
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(UMobileTheme.uOrange)
            }
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(UMobileTheme.uTextDark)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func deviceCard(name: String, plan: String, price: String, badge: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(badge)
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(UMobileTheme.uOrange)
                        .clipShape(Capsule())
                    Text(name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(UMobileTheme.uTextDark)
                }
                Text(plan)
                    .font(.system(size: 13))
                    .foregroundColor(UMobileTheme.uTextSecondary)
                Text(price)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(UMobileTheme.uOrange)
            }
            Spacer()
            Button("Order") {}
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(UMobileTheme.uOrange)
                .clipShape(Capsule())
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Rewards Tab
public struct RewardsView: View {
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    // Points Card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("U REWARDS POINTS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                                .tracking(1)
                            Text("2,480 Pts")
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            Text("Tier: Gold Member")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        Spacer()
                        Image(systemName: "sparkles")
                            .font(.system(size: 38))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [UMobileTheme.uOrange, Color(red: 0.9, green: 0.2, blue: 0.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: UMobileTheme.uOrange.opacity(0.35), radius: 8, y: 4)
                    
                    // Deals
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Featured Lifestyle Vouchers")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(UMobileTheme.uTextDark)
                        
                        rewardVoucher(brand: "Inside Scoop", discount: "RM5 Off Any Double Scoop", points: "200 Pts", icon: "cup.and.saucer.fill")
                        rewardVoucher(brand: "GSC Cinemas", discount: "Buy 1 Free 1 Movie Ticket", points: "500 Pts", icon: "popcorn.fill")
                        rewardVoucher(brand: "ZUS Coffee", discount: "Buy 1 Get 2nd Cup 50% Off", points: "150 Pts", icon: "mug.fill")
                        rewardVoucher(brand: "GrabFood", discount: "RM10 Off Minimum Spend RM30", points: "350 Pts", icon: "fork.knife")
                    }
                }
                .padding(18)
            }
            .background(UMobileTheme.uCreamTile.opacity(0.5))
            .navigationTitle("Rewards")
        }
    }
    
    private func rewardVoucher(brand: String, discount: String, points: String, icon: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(UMobileTheme.uLightOrange)
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(UMobileTheme.uOrange)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(brand)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(UMobileTheme.uTextDark)
                Text(discount)
                    .font(.system(size: 13))
                    .foregroundColor(UMobileTheme.uTextSecondary)
            }
            
            Spacer()
            
            Button("Claim") {}
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(UMobileTheme.uOrange)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(UMobileTheme.uLightOrange)
                .clipShape(Capsule())
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Upgrade Tab
public struct UpgradeView: View {
    @Environment(UMobileStore.self) private var store
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Text("Choose Your 5G Postpaid Plan")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(UMobileTheme.uTextDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    planOptionCard(
                        name: "U Postpaid 68",
                        price: "RM68/mo",
                        data: "500GB 5G/4G Data",
                        hotspot: "Ultra-fast hotspot data sharing",
                        roaming: "FREE 15GB Roaming across 63 destinations",
                        isCurrent: true
                    )
                    
                    planOptionCard(
                        name: "U Postpaid 98",
                        price: "RM98/mo",
                        data: "1,000GB (1TB) 5G/4G Data",
                        hotspot: "Uncapped sharing speed",
                        roaming: "FREE 15GB Global Roaming in 63 countries + free roaming calls",
                        isCurrent: false,
                        badge: "MOST POPULAR"
                    )
                    
                    planOptionCard(
                        name: "U Postpaid 128 (Ultra 5G)",
                        price: "RM128/mo",
                        data: "Unlimited Uncapped 5G Data",
                        hotspot: "100GB Dedicated Hotspot",
                        roaming: "FREE 30GB Global Roaming + Priority VIP Concierge",
                        isCurrent: false,
                        badge: "VIP EXPERIENCE"
                    )
                }
                .padding(18)
            }
            .background(UMobileTheme.uCreamTile.opacity(0.5))
            .navigationTitle("Upgrade Plan")
        }
    }
    
    private func planOptionCard(
        name: String,
        price: String,
        data: String,
        hotspot: String,
        roaming: String,
        isCurrent: Bool,
        badge: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(UMobileTheme.uOrange)
                            .clipShape(Capsule())
                    }
                    Text(name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(UMobileTheme.uTextDark)
                }
                Spacer()
                Text(price)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(UMobileTheme.uOrange)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                featureCheck(data)
                featureCheck(hotspot)
                featureCheck(roaming)
            }
            
            if isCurrent {
                Text("Current Active Plan")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(UMobileTheme.uTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Button(action: {
                    store.activePlan.planName = name
                    store.activePlan.monthlyFee = name.contains("98") ? 98.0 : 128.0
                    store.activePlan.totalDataGB = name.contains("98") ? 1000.0 : 2000.0
                }) {
                    Text("Select This Plan")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(UMobileTheme.orangeGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isCurrent ? UMobileTheme.uOrange.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
    
    private func featureCheck(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(UMobileTheme.uTextDark)
        }
    }
}
