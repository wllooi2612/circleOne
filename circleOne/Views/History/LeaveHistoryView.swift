import SwiftUI

public struct LeaveHistoryView: View {
    @Environment(LeaveStore.self) private var store
    
    @State private var selectedFilter: HistoryFilter = .all
    @State private var searchText: String = ""
    @State private var selectedRequestForDetail: LeaveRequest? = nil
    
    public init() {}
    
    public enum HistoryFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case pending = "Pending"
        case approved = "Approved"
        case past = "Past / Other"
        
        public var id: String { rawValue }
    }
    
    private var filteredRequests: [LeaveRequest] {
        let list = store.currentUserRequests
        
        let filteredByTab: [LeaveRequest]
        switch selectedFilter {
        case .all:
            filteredByTab = list
        case .pending:
            filteredByTab = list.filter { $0.status == .pending }
        case .approved:
            filteredByTab = list.filter { $0.status == .approved }
        case .past:
            filteredByTab = list.filter { $0.status == .cancelled || $0.status == .rejected }
        }
        
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return filteredByTab
        } else {
            let query = searchText.lowercased()
            return filteredByTab.filter {
                $0.leaveType.rawValue.lowercased().contains(query) ||
                $0.reason.lowercased().contains(query) ||
                $0.requestNumber.lowercased().contains(query) ||
                ($0.relieverName?.lowercased().contains(query) ?? false)
            }
        }
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Segmented Control
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(HistoryFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.circleCardBackground)
                
                if filteredRequests.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredRequests) { req in
                            LeaveHistoryRow(request: req) {
                                selectedRequestForDetail = req
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if req.status == .pending {
                                    Button(role: .destructive) {
                                        store.cancelLeave(requestId: req.id)
                                    } label: {
                                        Label("Cancel", systemImage: "trash")
                                    }
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.circleBackground.ignoresSafeArea())
            .navigationTitle("Leave History")
            .circleNavigationTitleDisplayModeLarge()
            .searchable(text: $searchText, prompt: "Search by type, reason, or code...")
            .sheet(item: $selectedRequestForDetail) { req in
                LeaveDetailView(request: req)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No Leave Records")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.primary)
            
            Text(searchText.isEmpty ? "You have no records under '\(selectedFilter.rawValue)'." : "No records match '\(searchText)'.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

private struct LeaveHistoryRow: View {
    let request: LeaveRequest
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Circle()
                    .fill(request.leaveType.tintColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: request.leaveType.iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(request.leaveType.tintColor)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(request.leaveType.rawValue)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("• \(request.requestNumber)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(request.formattedDateRange)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if let reliever = request.relieverName {
                        Text("Cover: \(reliever)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(formatDays(request.totalDays))d")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    StatusBadge(status: request.status, isCompact: true)
                }
            }
            .padding(14)
            .background(Color.circleCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
    
    private func formatDays(_ days: Double) -> String {
        days.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(days))" : String(format: "%.1f", days)
    }
}
