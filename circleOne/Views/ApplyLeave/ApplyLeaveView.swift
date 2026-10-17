import SwiftUI

public struct ApplyLeaveView: View {
    @Environment(LeaveStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: LeaveType
    @State private var durationType: LeaveDurationType = .multiDay
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var reason: String = ""
    @State private var selectedReliever: String = "Elena Rostova"
    @State private var attachmentName: String? = nil
    
    @State private var errorMessage: String? = nil
    @State private var showSuccessConfirmation: Bool = false
    
    public init(initialType: LeaveType = .annual) {
        let cal = Calendar.current
        let defaultStart = cal.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        let defaultEnd = cal.date(byAdding: .day, value: 4, to: Date()) ?? Date()
        
        self._selectedType = State(initialValue: initialType)
        self._startDate = State(initialValue: defaultStart)
        self._endDate = State(initialValue: defaultEnd)
    }
    
    private var calculatedWorkingDays: Double {
        store.calculateWorkingDays(from: startDate, to: endDate, duration: durationType)
    }
    
    private var selectedBalance: LeaveBalance? {
        store.balance(for: selectedType)
    }
    
    private var isOverBalance: Bool {
        guard let balance = selectedBalance else { return false }
        return calculatedWorkingDays > balance.availableDays
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Leave Type Selector Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Select Leave Category")
                            .font(.system(size: 15, weight: .bold))
                            .padding(.horizontal, 16)
                        
                        LeaveTypePickerView(selectedType: $selectedType, balances: store.balances)
                    }
                    
                    // 2. Duration & Dates Section
                    durationAndDatesSection
                    
                    // 3. Handover & Delegate Colleague
                    handoverSection
                    
                    // 4. Reason & Details
                    reasonSection
                    
                    // 5. Supporting Document Attachment
                    VStack(alignment: .leading, spacing: 8) {
                        DocumentAttachmentView(
                            attachmentName: $attachmentName,
                            isRequired: selectedType.requiresAttachment
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Validation or Warning banner
                    if let error = errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    } else if isOverBalance {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                            Text("Warning: You are requesting \(formatDays(calculatedWorkingDays)) days, exceeding your remaining \(selectedBalance?.formattedAvailable ?? "0") available days.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.orange)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }
                    
                    // Submit CTA Button
                    submitSection
                }
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(Color.circleBackground.ignoresSafeArea())
            .navigationTitle("Apply For Leave")
            .circleNavigationTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .circleLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Leave Request Submitted!", isPresented: $showSuccessConfirmation) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your request for \(formatDays(calculatedWorkingDays)) days of \(selectedType.rawValue) has been routed to \(store.currentUser.managerName) for review.")
            }
        }
    }
    
    // MARK: - Duration & Dates
    private var durationAndDatesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("2. Schedule & Duration")
                .font(.system(size: 15, weight: .bold))
            
            // Duration Type Picker
            Picker("Duration", selection: $durationType) {
                ForEach(LeaveDurationType.allCases) { dur in
                    Text(dur.rawValue).tag(dur)
                }
            }
            .pickerStyle(.segmented)
            
            // Date Controls
            VStack(spacing: 12) {
                if durationType == .multiDay {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Date")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("End Date")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                } else {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                        
                        Spacer()
                        
                        Text(durationType.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Divider()
                
                // Calculated Days Pill
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.badge.checkmark")
                            .foregroundColor(.blue)
                        Text("Calculated Total:")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(formatDays(calculatedWorkingDays)) working days")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(calculatedWorkingDays > 0 ? .primary : .red)
                }
            }
            .padding(14)
            .background(Color.circleCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Handover Section
    private var handoverSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("3. Handover / Covering Teammate")
                .font(.system(size: 15, weight: .bold))
            
            HStack(spacing: 12) {
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.teal)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Delegate Coverage To")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Picker("Handover Teammate", selection: $selectedReliever) {
                        ForEach(store.teamMembers) { member in
                            Text("\(member.name) (\(member.role))").tag(member.name)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.primary)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color.circleCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Reason Section
    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("4. Reason for Leave")
                .font(.system(size: 15, weight: .bold))
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("E.g., Taking vacation with family, attending appointment...", text: $reason, axis: .vertical)
                    .lineLimit(3...5)
                    .font(.system(size: 14))
                    .padding(10)
                    .background(Color.circleSubCardBackground.opacity(0.5))
                    .cornerRadius(10)
                
                // Preset suggestion chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        suggestionChip("🌴 Personal Vacation")
                        suggestionChip("🩺 Medical Clinic Visit")
                        suggestionChip("🏠 Household Matters")
                        suggestionChip("🧘 Rest & Wellness")
                    }
                }
            }
            .padding(14)
            .background(Color.circleCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
    }
    
    private func suggestionChip(_ text: String) -> some View {
        Button {
            reason = text
        } label: {
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.circleSubCardBackground)
                .cornerRadius(16)
        }
    }
    
    // MARK: - Submit Section
    private var submitSection: some View {
        VStack(spacing: 8) {
            Button {
                submitApplication()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                    Text("Submit Leave Application")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
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
            .padding(.horizontal, 16)
            
            Text("Approver: \(store.currentUser.managerName) • circleOne Leave Policy v2.4")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
    
    private func submitApplication() {
        errorMessage = nil
        let result = store.submitLeave(
            type: selectedType,
            duration: durationType,
            startDate: startDate,
            endDate: (durationType == .halfDayAM || durationType == .halfDayPM) ? startDate : endDate,
            reason: reason,
            reliever: selectedReliever,
            attachmentName: attachmentName
        )
        
        switch result {
        case .success:
            showSuccessConfirmation = true
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    private func formatDays(_ days: Double) -> String {
        days.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(days))" : String(format: "%.1f", days)
    }
}
