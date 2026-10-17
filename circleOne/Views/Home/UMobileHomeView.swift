import SwiftUI

public struct UMobileHomeView: View {
    @Environment(UMobileStore.self) private var store
    
    public init() {}
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // MARK: - Hero Top Header with Photographic Background
                ZStack(alignment: .top) {
                    // Photographic Background Image
                    heroBackgroundImage
                        .frame(height: 460)
                        .clipped()
                    
                    // Dark Gradient Overlays for Readability
                    VStack(spacing: 0) {
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.70),
                                Color.black.opacity(0.40),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 220)
                        
                        Spacer()
                        
                        // Bottom fade to clean background
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.white
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 80)
                    }
                    .frame(height: 460)
                    
                    // Top Bar & Hero Account Information
                    VStack(spacing: 20) {
                        // Top Navigation Icons & Phone Number Dropdown
                        topHeaderBar
                            .padding(.top, 14)
                        
                        // Total Due & View Bill Pill Button
                        totalDueSection
                            .padding(.top, 8)
                        
                        // Floating Active Plan Glassmorphic Card
                        ActivePlanCard(
                            plan: store.activePlan,
                            onPlanDetailTap: {
                                store.selectedTab = 1
                            },
                            onUpgradeTap: {
                                store.selectedTab = 4
                            }
                        )
                        .padding(.top, 6)
                        
                        // Page Indicator Pills (Capsule + Dot)
                        HStack(spacing: 6) {
                            Capsule()
                                .fill(Color.white)
                                .frame(width: 24, height: 4.5)
                            
                            Circle()
                                .fill(Color.white.opacity(0.45))
                                .frame(width: 5, height: 5)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 460)
                
                // MARK: - Content Body (White Background)
                VStack(spacing: 28) {
                    // Section 1: All Services
                    allServicesSection
                    
                    // Section 2: Deals For U
                    dealsForUSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 100) // Padding for bottom floating tab bar
                .background(Color.white)
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
    }
    
    // MARK: - Hero Background Image
    @ViewBuilder
    private var heroBackgroundImage: some View {
        if let customImage = ImageHelper.loadCustomImage(named: "hero_background") {
            customImage
                .resizable()
                .scaledToFill()
        } else {
            // High fidelity fallback gradient if image is unavailable
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.18, blue: 0.22),
                        Color(red: 0.35, green: 0.30, blue: 0.28),
                        Color(red: 0.70, green: 0.55, blue: 0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Subtle airplane window silhouette
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 30)
                    .frame(width: 280, height: 280)
                    .offset(x: 100, y: -20)
            }
        }
    }
    
    // MARK: - Top Header Bar
    private var topHeaderBar: some View {
        HStack {
            // Profile Button
            Button(action: {
                store.activeSheet = .accountSwitcher
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Phone Number Dropdown
            Button(action: {
                store.activeSheet = .accountSwitcher
            }) {
                HStack(spacing: 6) {
                    Text(store.currentAccount.phoneNumber)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Notification Bell with Orange Dot
            Button(action: {
                store.activeSheet = .notifications
            }) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.black.opacity(0.35))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: "bell.fill")
                        .font(.system(size: 19))
                        .foregroundColor(.white)
                        .frame(width: 42, height: 42)
                    
                    if store.unreadNotificationsCount > 0 {
                        Circle()
                            .fill(UMobileTheme.uOrange)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(Color.black, lineWidth: 1.5))
                            .offset(x: -3, y: 3)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Total Due Section
    private var totalDueSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Total Due")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.88))
                
                Text(String(format: "RM%.2f", store.currentAccount.totalDue))
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(-0.5)
                
                Text("Payment due on \(store.currentAccount.dueDate)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.85))
            }
            
            Spacer()
            
            // View Bill Pill Button
            Button(action: {
                store.activeSheet = .viewBill
            }) {
                Text("View Bill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(UMobileTheme.uTextDark)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 11)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - All Services Section
    private var allServicesSection: some View {
        VStack(spacing: 16) {
            // Header Row
            HStack {
                Text("All Services")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(UMobileTheme.uTextDark)
                
                Spacer()
                
                Button(action: {
                    store.selectedTab = 1
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.12))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(UMobileTheme.uTextDark.opacity(0.75))
                    }
                }
                .buttonStyle(.plain)
            }
            
            // 5 Service Action Tiles
            HStack(alignment: .top, spacing: 0) {
                // 1. Pay Bill for Self
                ServiceTileButton(type: .payBill) {
                    store.activeSheet = .payBill
                }
                .frame(maxWidth: .infinity)
                
                // 2. Roaming
                ServiceTileButton(type: .roaming) {
                    store.activeSheet = .roaming
                }
                .frame(maxWidth: .infinity)
                
                // 3. Add-Ons
                ServiceTileButton(type: .addOns) {
                    store.activeSheet = .addOns
                }
                .frame(maxWidth: .infinity)
                
                // 4. Transaction History
                ServiceTileButton(type: .transactionHistory) {
                    store.activeSheet = .transactionHistory
                }
                .frame(maxWidth: .infinity)
                
                // 5. Upgrade Plan
                ServiceTileButton(type: .upgradePlan) {
                    store.selectedTab = 4
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Deals For U Section
    private var dealsForUSection: some View {
        VStack(spacing: 14) {
            // Header Row
            HStack {
                Text("Deals For U")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(UMobileTheme.uTextDark)
                
                Spacer()
                
                Button(action: {
                    store.selectedTab = 2
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.12))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(UMobileTheme.uTextDark.opacity(0.75))
                    }
                }
                .buttonStyle(.plain)
            }
            
            // Promotional Banner Card
            if let firstDeal = store.deals.first {
                Button(action: {
                    store.activeSheet = .dealDetail(firstDeal)
                }) {
                    ZStack(alignment: .bottomLeading) {
                        if let dealImage = ImageHelper.loadCustomImage(named: firstDeal.imageName) {
                            dealImage
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                        } else {
                            // Fallback Graphic Card
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("ULTRA-FAST 5G")
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(UMobileTheme.uOrange)
                                    Spacer()
                                    Text("FREE 3 MONTHS")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(UMobileTheme.uOrange)
                                        .clipShape(Capsule())
                                }
                                Text("FAST INTERNET\nSMARTER HOME")
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundColor(UMobileTheme.uTextDark)
                                Text("Sign up U Home 5G today with zero upfront payment.")
                                    .font(.system(size: 13))
                                    .foregroundColor(UMobileTheme.uTextSecondary)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                LinearGradient(
                                    colors: [Color.white, UMobileTheme.uLightOrange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(UMobileTheme.uOrange.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
