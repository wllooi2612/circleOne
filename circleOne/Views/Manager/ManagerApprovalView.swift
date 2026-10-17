import SwiftUI

public struct ManagerApprovalView: View {
    @Environment(LeaveStore.self) private var store
    
    @State private var selectedRequest: LeaveRequest? = nil
    @State private var reviewAction: ReviewActionType = .approve
    @State private var managerComment: String = ""
    @State private var showActionDialog: Bool = false
    @State private var filterMode: ManagerFilterMode = .pending
    
    public enum ManagerFilterMode: String, CaseIterable, Identifiable {
        case pending = "Needs Review"
        case resolved = "Reviewed"
        
        public var id: String { rawValue }
    }
    
    public enum ReviewActionType {
        case approve
        case reject
    }
    
    private var displayedRequests: [LeaveRequest] {
        switch filterMode {
        case .pending:
            return store.requests.filter { $0.status == .pending }
        case .resolved:
            return store.requests.filter { $0.status == .approved || $0.status == .rejected }
        }
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode switcher
                Picker("Filter", selection: $filterMode) {
                    ForEach(ManagerFilterMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.circleCardBackground)
                
                if displayedRequests.isEmpty {
                    emptyManagerView
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(displayedRequests) { req in
                                managerRequestCard(req)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(Color.circleBackground.ignoresSafeArea())
            .navigationTitle("Manager Approvals")
            .circleNavigationTitleDisplayModeLarge()
            .sheet(isPresented: $showActionDialog) {
                if let req = selectedRequest {
                    actionSheetView(for: req)
                }
            }
        }
    }
    
    private func managerRequestCard(_ req: LeaveRequest) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Employee Info & Leave Type
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(req.employeeAvatarInitials)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.purple)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(req.employeeName)
                        .font(.system(size: 16, weight: .bold))
                    
                    Text(req.employeeRole)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: req.status, isCompact: true)
            }
            
            Divider()
            
            // Dates & Duration
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                    Text(req.formattedDateRange)
                        .font(.system(size: 13, weight: .medium))
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                    Text("\(formatDays(req.totalDays)) days (\(req.leaveType.rawValue))")
                        .font(.system(size: 13, weight: .medium))
                }
            }
            
            // Reliever
            if let reliever = req.relieverName {
                HStack(spacing: 6) {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("Designated handover: \(reliever)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            // Reason
            Text(req.reason)
                .font(.system(size: 13))
                .foregroundColor(.primary.opacity(0.85))
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.circleSubCardBackground.opacity(0.5))
                .cornerRadius(10)
            
            // Action Buttons (only if pending)
            if req.status == .pending {
                HStack(spacing: 12) {
                    Button {
                        selectedRequest = req
                        reviewAction = .reject
                        managerComment = ""
                        showActionDialog = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                            Text("Decline")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Button {
                        selectedRequest = req
                        reviewAction = .approve
                        managerComment = ""
                        showActionDialog = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                            Text("Approve")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                }
                .padding(.top, 4)
            } else if let reviewer = req.reviewedBy, let reviewedAt = req.reviewedAt {
                Text("Reviewed by \(reviewer) on \(formatDateShort(reviewedAt))")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.circleCardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
    
    private func actionSheetView(for req: LeaveRequest) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: reviewAction == .approve ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(reviewAction == .approve ? .green : .red)
                    
                    Text(reviewAction == .approve ? "Approve Leave Request" : "Decline Leave Request")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("\(req.employeeName) • \(req.leaveType.rawValue) (\(formatDays(req.totalDays)) days)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Add a note / comment (optional):")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField(reviewAction == .approve ? "e.g. Have a great vacation! Team has full coverage." : "e.g. Please reschedule due to Q3 sprint release.", text: $managerComment, axis: .vertical)
                        .lineLimit(3...4)
                        .padding(12)
                        .background(Color.circleCardBackground)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button {
                    if reviewAction == .approve {
                        store.approveLeave(requestId: req.id, comment: managerComment)
                    } else {
                        store.rejectLeave(requestId: req.id, comment: managerComment)
                    }
                    showActionDialog = false
                } label: {
                    Text(reviewAction == .approve ? "Confirm Approval" : "Confirm Decline")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(reviewAction == .approve ? Color.green : Color.red)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.circleBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .circleLeading) {
                    Button("Cancel") {
                        showActionDialog = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var emptyManagerView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal")
                .font(.system(size: 48))
                .foregroundColor(.green.opacity(0.8))
            Text("All Caught Up!")
                .font(.system(size: 18, weight: .bold))
            Text("There are no pending leave requests awaiting approval at this time.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
    
    private func formatDays(_ days: Double) -> String {
        days.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(days))" : String(format: "%.1f", days)
    }
    
    private func formatDateShort(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }
}
