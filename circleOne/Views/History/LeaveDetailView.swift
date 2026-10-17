import SwiftUI

public struct LeaveDetailView: View {
    @Environment(LeaveStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    public let request: LeaveRequest
    @State private var showingCancelConfirm: Bool = false
    
    public init(request: LeaveRequest) {
        self.request = request
    }
    
    private var currentRequest: LeaveRequest {
        store.requests.first(where: { $0.id == request.id }) ?? request
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Status Card
                    headerCard
                    
                    // Key Details Grid
                    detailsCard
                    
                    // Workflow Timeline
                    approvalTimelineCard
                    
                    // Attachment if any
                    if let attachment = currentRequest.attachmentName {
                        attachmentCard(filename: attachment)
                    }
                    
                    // Action Buttons (e.g. Cancel request if pending or upcoming)
                    if currentRequest.status == .pending || (currentRequest.status == .approved && currentRequest.startDate > Date()) {
                        Button(role: .destructive) {
                            showingCancelConfirm = true
                        } label: {
                            HStack {
                                Image(systemName: "slash.circle")
                                Text("Withdraw / Cancel Leave Request")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color.circleBackground.ignoresSafeArea())
            .navigationTitle(currentRequest.requestNumber)
            .circleNavigationTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .circleTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Cancel this leave request?", isPresented: $showingCancelConfirm) {
                Button("Confirm Cancellation", role: .destructive) {
                    store.cancelLeave(requestId: currentRequest.id)
                    dismiss()
                }
                Button("Keep Request", role: .cancel) {}
            } message: {
                Text("Your allotted days will be refunded back to your balance.")
            }
        }
    }
    
    private var headerCard: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(currentRequest.leaveType.tintColor.opacity(0.15))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: currentRequest.leaveType.iconName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(currentRequest.leaveType.tintColor)
                )
            
            Text(currentRequest.leaveType.rawValue)
                .font(.system(size: 20, weight: .bold))
            
            StatusBadge(status: currentRequest.status)
            
            HStack(spacing: 8) {
                Text(currentRequest.formattedDateRange)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text("\(formatDays(currentRequest.totalDays)) working days")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.circleCardBackground)
        .cornerRadius(18)
        .padding(.horizontal, 16)
    }
    
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Request Information")
                .font(.system(size: 15, weight: .bold))
            
            detailRow(title: "Applicant", value: currentRequest.employeeName)
            detailRow(title: "Duration Type", value: currentRequest.durationType.rawValue)
            detailRow(title: "Handover / Reliever", value: currentRequest.relieverName ?? "None specified")
            detailRow(title: "Submitted On", value: formatDate(currentRequest.appliedAt))
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Reason")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(currentRequest.reason)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
        .background(Color.circleCardBackground)
        .cornerRadius(18)
        .padding(.horizontal, 16)
    }
    
    private var approvalTimelineCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Approval Audit Trail")
                .font(.system(size: 15, weight: .bold))
            
            timelineStep(
                title: "Application Submitted",
                subtitle: formatDate(currentRequest.appliedAt),
                isDone: true,
                systemImage: "paperplane.fill",
                color: .blue
            )
            
            timelineStep(
                title: "Manager Review (\(store.currentUser.managerName))",
                subtitle: currentRequest.reviewedAt != nil ? formatDate(currentRequest.reviewedAt!) : "Awaiting review",
                isDone: currentRequest.status != .pending,
                systemImage: currentRequest.status == .approved ? "checkmark.circle.fill" : (currentRequest.status == .rejected ? "xmark.circle.fill" : "hourglass"),
                color: currentRequest.status == .approved ? .green : (currentRequest.status == .rejected ? .red : .orange)
            )
            
            if let comment = currentRequest.reviewComment, !comment.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "quote.opening")
                        .foregroundColor(.secondary)
                    Text("Manager note: \"\(comment)\"")
                        .font(.system(size: 13, weight: .medium))
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
                .padding(.leading, 32)
            }
        }
        .padding(16)
        .background(Color.circleCardBackground)
        .cornerRadius(18)
        .padding(.horizontal, 16)
    }
    
    private func attachmentCard(filename: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.fill")
                .font(.system(size: 22))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(filename)
                    .font(.system(size: 14, weight: .semibold))
                Text("Attached verified document")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 18))
                .foregroundColor(.blue)
        }
        .padding(14)
        .background(Color.circleCardBackground)
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
        }
    }
    
    private func timelineStep(title: String, subtitle: String, isDone: Bool, systemImage: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return f.string(from: date)
    }
    
    private func formatDays(_ days: Double) -> String {
        days.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(days))" : String(format: "%.1f", days)
    }
}
