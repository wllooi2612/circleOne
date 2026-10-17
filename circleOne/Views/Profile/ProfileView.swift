import SwiftUI

public struct ProfileView: View {
    @Environment(LeaveStore.self) private var store
    @State private var showingPolicySheet: Bool = false
    @State private var pushNotificationsEnabled: Bool = true
    @State private var emailSummariesEnabled: Bool = true
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                // Identity Card Section
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(store.currentUser.initials)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.currentUser.name)
                                .font(.system(size: 18, weight: .bold))
                            
                            Text(store.currentUser.role)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 6) {
                                Text(store.currentUser.department)
                                    .font(.system(size: 11, weight: .semibold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)
                                
                                Text(store.currentUser.employeeCode)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                // Active Role Switcher
                Section(header: Text("Workspace Role Simulation"), footer: Text("Switch modes to experience employee leave applications versus manager approval workflows.")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Current View Mode")
                                .font(.system(size: 15, weight: .semibold))
                            Text(store.currentUser.activeRole.rawValue)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                store.toggleRole()
                            }
                        } label: {
                            Text(store.currentUser.activeRole == .employee ? "Switch to Manager" : "Switch to Employee")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(store.currentUser.activeRole == .employee ? .purple : .blue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background((store.currentUser.activeRole == .employee ? Color.purple : Color.blue).opacity(0.12))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Reporting Structure
                Section(header: Text("Organizational Hierarchy")) {
                    HStack {
                        Label("Approving Manager", systemImage: "person.crop.circle.badge.checkmark")
                        Spacer()
                        Text(store.currentUser.managerName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Leave Cycle Year", systemImage: "calendar")
                        Spacer()
                        Text("Jan 1 – Dec 31, 2026")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Detailed Entitlement Breakdown
                Section(header: Text("2026 Entitlement Breakdown")) {
                    ForEach(store.balances) { b in
                        HStack {
                            Image(systemName: b.type.iconName)
                                .foregroundColor(b.type.tintColor)
                                .frame(width: 24)
                            
                            Text(b.type.rawValue)
                                .font(.system(size: 14, weight: .medium))
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(b.formattedAvailable) available")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("\(Int(b.usedDays)) used of \(b.formattedTotal)d")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Notifications & Policies
                Section(header: Text("Preferences & Policy")) {
                    Toggle(isOn: $pushNotificationsEnabled) {
                        Label("Push Notification Alerts", systemImage: "bell.badge")
                    }
                    
                    Toggle(isOn: $emailSummariesEnabled) {
                        Label("Email Weekly Digest", systemImage: "envelope")
                    }
                    
                    Button {
                        showingPolicySheet = true
                    } label: {
                        HStack {
                            Label("Company Leave Policy Handbook", systemImage: "book.closed")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // App Info
                Section {
                    HStack {
                        Text("circleOne Version")
                        Spacer()
                        Text("1.0.0 (Build 2026.1)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .circleGroupedListStyle()
            .circleNavigationTitleDisplayModeLarge()
            .navigationTitle("Profile & Settings")
            .sheet(isPresented: $showingPolicySheet) {
                LeavePolicyView()
            }
        }
    }
}
