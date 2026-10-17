import SwiftUI

public struct UMobileRootView: View {
    @Environment(UMobileStore.self) private var store
    @State private var isPhoneFrameMode: Bool = true
    
    public init() {}
    
    public var body: some View {
        #if os(macOS)
        ZStack {
            // macOS Desktop Background
            Color(red: 0.12, green: 0.13, blue: 0.16)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // Top Toolbar for macOS testing & viewport options
                macToolbar
                
                // Device Frame or Full View
                if isPhoneFrameMode {
                    phoneFrameContainer
                } else {
                    mainAppContent
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 16)
        }
        .attachSheets(store: store)
        #else
        // iOS Native View
        mainAppContent
            .ignoresSafeArea(.keyboard)
            .attachSheets(store: store)
        #endif
    }
    
    // MARK: - Main Application Mobile Content
    private var mainAppContent: some View {
        ZStack(alignment: .bottom) {
            // Active Tab Content
            Group {
                switch store.selectedTab {
                case 0:
                    UMobileHomeView()
                case 1:
                    MyPlanView()
                case 2:
                    BuyView()
                case 3:
                    RewardsView()
                case 4:
                    UpgradeView()
                default:
                    UMobileHomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Tab Navigation Bar with Elevated Orange "Buy" Button
            UMobileBottomBar(
                selectedTab: Binding(
                    get: { store.selectedTab },
                    set: { store.selectedTab = $0 }
                ),
                onBuyTap: {
                    store.selectedTab = 2
                }
            )
        }
        .background(Color.white)
    }
    
    #if os(macOS)
    // MARK: - Realistic iPhone Device Frame on macOS
    private var phoneFrameContainer: some View {
        VStack(spacing: 0) {
            // Realistic iPhone Status Bar (8:07, 5G, Battery)
            phoneStatusBar
            
            // Screen Content
            mainAppContent
            
            // Home Indicator Bar
            phoneHomeIndicator
        }
        .frame(width: 393, height: 830)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
        .overlay(
            // Aluminum chassis bezel
            RoundedRectangle(cornerRadius: 48, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.black.opacity(0.7),
                            Color.white.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
        )
        .shadow(color: Color.black.opacity(0.45), radius: 30, x: 0, y: 15)
    }
    
    // MARK: - iPhone Status Bar
    private var phoneStatusBar: some View {
        ZStack {
            // Top background to blend with dark hero image
            Color.black.opacity(0.85)
            
            HStack {
                // Time & Focus Icon (8:07 with person silhouette)
                HStack(spacing: 4) {
                    Text("8:07")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "person.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Dynamic Island / Speaker Pill
                Capsule()
                    .fill(Color.black)
                    .frame(width: 90, height: 24)
                    .overlay(
                        HStack(spacing: 4) {
                            Circle().fill(Color(red: 0.1, green: 0.2, blue: 0.4)).frame(width: 8, height: 8)
                            Spacer()
                            Circle().fill(Color.black).frame(width: 9, height: 9)
                        }
                        .padding(.horizontal, 8)
                    )
                
                Spacer()
                
                // Cellular, WiFi, Battery
                HStack(spacing: 5) {
                    Image(systemName: "cellularbars")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                    Image(systemName: "wifi")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                    Image(systemName: "battery.100")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 44)
    }
    
    // MARK: - iPhone Home Indicator
    private var phoneHomeIndicator: some View {
        ZStack {
            Color.white
            Capsule()
                .fill(Color.black.opacity(0.75))
                .frame(width: 134, height: 5)
        }
        .frame(height: 20)
    }
    
    // MARK: - macOS Top Control Bar
    private var macToolbar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(UMobileTheme.uOrange)
                        .frame(width: 24, height: 24)
                    Text("u")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .italic()
                }
                Text("U Mobile — circleOne")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // View Mode Toggle
            Picker("View Mode", selection: $isPhoneFrameMode) {
                Text("iPhone View").tag(true)
                Text("Expanded View").tag(false)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
            
            // Quick Action Buttons
            Button("Pay Bill") {
                store.activeSheet = .payBill
            }
            .buttonStyle(.bordered)
            .tint(UMobileTheme.uOrange)
            
            Button("View Bill") {
                store.activeSheet = .viewBill
            }
            .buttonStyle(.bordered)
            .tint(.white)
        }
        .padding(.horizontal, 28)
        .frame(height: 38)
    }
    #endif
}

// MARK: - Sheet Attachment View Extension
extension View {
    public func attachSheets(store: UMobileStore) -> some View {
        self
            .sheet(item: Binding(
                get: { store.activeSheet },
                set: { store.activeSheet = $0 }
            )) { sheet in
                switch sheet {
                case .viewBill:
                    ViewBillSheet()
                        .environment(store)
                case .payBill:
                    PaymentSheet()
                        .environment(store)
                case .roaming:
                    RoamingSheet()
                case .addOns:
                    AddOnsSheet()
                case .transactionHistory:
                    TransactionHistorySheet()
                        .environment(store)
                case .upgradePlan:
                    UpgradeView()
                        .environment(store)
                case .accountSwitcher:
                    AccountSwitcherSheet()
                        .environment(store)
                case .notifications:
                    NotificationsSheet()
                case .dealDetail(let deal):
                    NavigationStack {
                        VStack(spacing: 16) {
                            Text(deal.title)
                                .font(.system(size: 22, weight: .bold))
                            Text(deal.subtitle)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(20)
                        .navigationTitle("Offer Details")
                    }
                }
            }
    }
}
