import SwiftUI

public struct LeavePolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Annual Leave Guidelines")) {
                    policyItem(
                        title: "Notice Requirement",
                        desc: "Applications for 3 or more consecutive days require at least 5 business days advance notice to ensure team coverage."
                    )
                    policyItem(
                        title: "Carry-Forward Cap",
                        desc: "Up to 5 unconsumed annual leave days may be carried forward to the following calendar year, expiring on March 31."
                    )
                }
                
                Section(header: Text("Medical & Sick Leave")) {
                    policyItem(
                        title: "Medical Certificate (MC)",
                        desc: "A digital or scanned copy of a valid medical practitioner's certificate must be attached for all sick leave claims."
                    )
                    policyItem(
                        title: "Hospitalization Entitlement",
                        desc: "Up to 60 days of hospitalization leave per annum, inclusive of standard outpatient medical days."
                    )
                }
                
                Section(header: Text("Handover & Delegations")) {
                    policyItem(
                        title: "Designated Reliever",
                        desc: "Employees are required to nominate a covering colleague for leaves exceeding 1 day to maintain project velocity."
                    )
                }
            }
            .navigationTitle("Leave Policy Handbook")
            .circleNavigationTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .circleTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func policyItem(title: String, desc: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
            Text(desc)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
