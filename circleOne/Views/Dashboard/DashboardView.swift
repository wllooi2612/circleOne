import SwiftUI

public struct DashboardView: View {
    @Environment(LeaveStore.self) private var store
    @Binding var selectedTab: Int
    @State private var showingApplySheet: Bool = false
    @State private var selectedBalanceDetail: LeaveBalance? = nil
    
    public init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Top User Header & Role Toggle
                    userHeaderSection
                    
                    // Hero Annual Leave Banner
                    heroBalanceBanner
                    
                    // Quick Action Apply Button
                    applyQuickActionButton
                    
                    // Key Metrics Row
                    quickMetricsRow
                    
                    // Upcoming Leaves Section
                    UpcomingLeavesCard(requests: store.upcomingLeaves) {
                        selectedTab = 2 // Switch to History
                    }
                    
                    // Leave Balances Breakdown
                    balancesSection
                    
                    // Team Pulse / Who's away today
                    teamPulseSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color.circleBackground.ignoresSafeArea())
            .navigationTitle("circleOne")
            .circleNavigationTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .circleLeading) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.teal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 10, height: 10)
                        
                        Text("Live Workspace")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .circleTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            store.toggleRole()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: store.currentUser.activeRole == .employee ? "person.fill" : "shield.lefthalf.filled")
                                .font(.system(size: 11, weight: .bold))
                            
                            Text(store.currentUser.activeRole == .employee ? "Employee" : "Manager")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundColor(store.currentUser.activeRole == .employee ? .blue : .purple)
                        .background(
                            Capsule()
                                .fill((store.currentUser.activeRole == .employee ? Color.blue : Color.purple).opacity(0.12))
                        )
                    }
                }
            }
            .sheet(isPresented: $showingApplySheet) {
                ApplyLeaveView(initialType: .annual)
            }
        }
    }
    
    // MARK: - Subviews
    private var userHeaderSection: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue, Color.indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 52, height: 52)
                .overlay(
                    Text(store.currentUser.initials)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Hello, \(store.currentUser.name)")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Text("\(store.currentUser.role) • \(store.currentUser.department)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var heroBalanceBanner: some View {
        let annualBalance = store.balances.first(where: { $0.type == .annual }) ?? LeaveBalance(type: .annual, totalQuota: 18, usedDays: 5)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.10, green: 0.22, blue: 0.42),
                            Color(red: 0.08, green: 0.35, blue: 0.45)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.orange)
                        Text("ANNUAL LEAVE QUOTA")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(0.8)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(annualBalance.formattedAvailable)
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("days left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("\(annualBalance.formattedTotal) days total • \(Int(annualBalance.usedDays)) used • \(Int(annualBalance.pendingDays)) pending")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 8)
                        .frame(width: 74, height: 74)
                    
                    let ratio = annualBalance.totalQuota > 0 ? (annualBalance.usedDays + annualBalance.pendingDays) / annualBalance.totalQuota : 0
                    Circle()
                        .trim(from: 0, to: CGFloat(min(1.0, ratio)))
                        .stroke(
                            Color.teal,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 74, height: 74)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int((annualBalance.availableDays / max(1, annualBalance.totalQuota)) * 100))%")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(20)
        }
        .shadow(color: Color.blue.opacity(0.15), radius: 12, x: 0, y: 6)
    }
    
    private var applyQuickActionButton: some View {
        Button {
            showingApplySheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                
                Text("Apply For Leave")
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color(red: 0.15, green: 0.50, blue: 0.95)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.blue.opacity(0.28), radius: 8, x: 0, y: 4)
        }
    }
    
    private var quickMetricsRow: some View {
        let totalUsed = store.balances.reduce(0) { $0 + $1.usedDays }
        let pendingCount = store.currentUserRequests.filter { $0.status == .pending }.count
        
        return HStack(spacing: 12) {
            StatMetricCard(
                title: "Used YTD",
                value: "\(Int(totalUsed))d",
                subtitle: "Across all categories",
                systemImage: "calendar.badge.minus",
                tintColor: .indigo
            )
            
            StatMetricCard(
                title: "In Review",
                value: "\(pendingCount)",
                subtitle: "Pending manager",
                systemImage: "hourglass",
                tintColor: .orange
            )
            
            StatMetricCard(
                title: "Holidays",
                value: "7d",
                subtitle: "Remaining in 2026",
                systemImage: "flag.fill",
                tintColor: .teal
            )
        }
    }
    
    private var balancesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Leave Entitlements")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
            }
            
            VStack(spacing: 10) {
                ForEach(store.balances) { balance in
                    LeaveBalanceCard(balance: balance) {
                        showingApplySheet = true
                    }
                }
            }
        }
    }
    
    private var teamPulseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.teal)
                    Text("Team Circle Pulse")
                        .font(.system(size: 17, weight: .bold))
                }
                
                Spacer()
                
                Button("View Calendar") {
                    selectedTab = 3 // Switch to Team Calendar
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                ForEach(store.teamMembers.prefix(3)) { member in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(member.avatarColor)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text(member.initials)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.name)
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text(member.role)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text("Available")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(10)
                    .background(Color.circleCardBackground)
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
}
