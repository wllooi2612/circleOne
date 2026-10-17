import SwiftUI

public struct ContentView: View {
    @Environment(LeaveStore.self) private var store
    @State private var selectedTab: Int = 0
    @State private var showingProfileSheet: Bool = false
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 0: Dashboard (Leave Entitlements & Balances)
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tab 1: Apply Leave
            ApplyLeaveView()
                .tabItem {
                    Label("Apply", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            // Tab 2: Leave History
            LeaveHistoryView()
                .tabItem {
                    Label("My Leaves", systemImage: "clock.arrow.circlepath")
                }
                .tag(2)
            
            // Tab 3: Team Absence Calendar
            TeamCalendarView()
                .tabItem {
                    Label("Team Calendar", systemImage: "calendar")
                }
                .tag(3)
            
            // Tab 4: Approvals
            ManagerApprovalView()
                .tabItem {
                    Label("Approvals", systemImage: "checkmark.shield.fill")
                }
                .badge(store.pendingApprovalsForManager.count)
                .tag(4)
            
            // Tab 5: Profile & Settings
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(5)
        }
        .tint(.blue)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(LeaveStore())
    }
}
#endif
