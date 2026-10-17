import SwiftUI

// MARK: - View Bill Sheet
public struct ViewBillSheet: View {
    @Environment(UMobileStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var isDownloading = false
    @State private var downloadCompleted = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(spacing: 8) {
                        Text("TOTAL OUTSTANDING")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(UMobileTheme.uTextSecondary)
                            .tracking(1.2)
                        
                        Text(String(format: "RM%.2f", store.currentAccount.totalDue))
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundColor(UMobileTheme.uTextDark)
                        
                        Text("Payment due on \(store.currentAccount.dueDate)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.red.opacity(0.85))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
                    
                    // Bill Summary
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Bill Details")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(UMobileTheme.uTextDark)
                        
                        VStack(spacing: 12) {
                            detailRow(label: "Account Number", value: store.currentAccount.accountNumber)
                            detailRow(label: "Mobile Number", value: store.currentAccount.phoneNumber)
                            detailRow(label: "Plan Name", value: store.activePlan.planName)
                            detailRow(label: "Billing Cycle", value: store.activePlan.billingCycle)
                        }
                    }
                    .padding(18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    // Charges Breakdown
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Charges Breakdown")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(UMobileTheme.uTextDark)
                        
                        VStack(spacing: 12) {
                            detailRow(label: "Monthly Commitment (U Postpaid 68)", value: "RM68.00")
                            detailRow(label: "Service Tax (SST 6%)", value: "RM4.08")
                            detailRow(label: "Rounding Adjustment", value: "+RM0.02")
                            
                            Divider()
                            
                            HStack {
                                Text("Total Amount Payable")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(UMobileTheme.uTextDark)
                                Spacer()
                                Text(String(format: "RM%.2f", store.currentAccount.totalDue))
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(UMobileTheme.uOrange)
                            }
                        }
                    }
                    .padding(18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    // Download & Pay Actions
                    VStack(spacing: 12) {
                        Button(action: {
                            dismiss()
                            store.activeSheet = .payBill
                        }) {
                            Text("Pay RM\(String(format: "%.2f", store.currentAccount.totalDue)) Now")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(UMobileTheme.orangeGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: UMobileTheme.uOrange.opacity(0.35), radius: 8, y: 3)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            isDownloading = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                isDownloading = false
                                downloadCompleted = true
                            }
                        }) {
                            HStack {
                                Image(systemName: downloadCompleted ? "checkmark.circle.fill" : "arrow.down.doc")
                                    .font(.system(size: 15, weight: .semibold))
                                Text(downloadCompleted ? "PDF Statement Saved" : (isDownloading ? "Generating PDF..." : "Download PDF Statement"))
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(downloadCompleted ? .green : UMobileTheme.uTextDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .disabled(isDownloading)
                    }
                }
                .padding(18)
            }
            .background(UMobileTheme.uCreamTile.opacity(0.5))
            .navigationTitle("Bill Statement")
            .circleNavigationTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(UMobileTheme.uOrange)
                }
            }
        }
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(UMobileTheme.uTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(UMobileTheme.uTextDark)
        }
    }
}

// MARK: - Pay Bill Sheet
public struct PaymentSheet: View {
    @Environment(UMobileStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    @State private var amountString: String = "72.10"
    @State private var selectedMethod: String = "FPX Online Banking"
    @State private var isProcessing: Bool = false
    @State private var paymentSuccess: Bool = false
    
    private let methods = [
        ("FPX Online Banking", "building.columns.fill", Color.blue),
        ("Touch 'n Go eWallet", "creditcard.fill", Color.blue),
        ("GrabPay", "wallet.pass.fill", Color.green),
        ("Credit / Debit Card", "creditcard", Color.orange),
        ("Apple Pay", "applelogo", Color.black)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if paymentSuccess {
                    // Success View
                    VStack(spacing: 20) {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.12))
                                .frame(width: 90, height: 90)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 54))
                                .foregroundColor(.green)
                        }
                        
                        Text("Payment Successful!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(UMobileTheme.uTextDark)
                        
                        Text("RM\(amountString) paid via \(selectedMethod)")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(UMobileTheme.uTextSecondary)
                        
                        Text("Reference: UM-PAY-\(Int.random(in: 10000000...99999999))")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(UMobileTheme.uTextSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Done")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(UMobileTheme.uOrange)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Amount Input Card
                            VStack(spacing: 12) {
                                Text("Payment Amount")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(UMobileTheme.uTextSecondary)
                                
                                HStack(spacing: 4) {
                                    Text("RM")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(UMobileTheme.uTextDark)
                                    TextField("Amount", text: $amountString)
                                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                                        .foregroundColor(UMobileTheme.uTextDark)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: 160)
                                }
                                
                                HStack(spacing: 10) {
                                    Button("Full Due (RM72.10)") {
                                        amountString = "72.10"
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(UMobileTheme.uLightOrange)
                                    .foregroundColor(UMobileTheme.uOrange)
                                    .clipShape(Capsule())
                                    
                                    Button("RM50") { amountString = "50.00" }
                                        .font(.system(size: 12, weight: .medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.1))
                                        .foregroundColor(UMobileTheme.uTextDark)
                                        .clipShape(Capsule())
                                    
                                    Button("RM100") { amountString = "100.00" }
                                        .font(.system(size: 12, weight: .medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.1))
                                        .foregroundColor(UMobileTheme.uTextDark)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            
                            // Payment Methods
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Select Payment Method")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(UMobileTheme.uTextDark)
                                
                                VStack(spacing: 8) {
                                    ForEach(methods, id: \.0) { method in
                                        Button(action: {
                                            selectedMethod = method.0
                                        }) {
                                            HStack(spacing: 14) {
                                                Image(systemName: method.1)
                                                    .font(.system(size: 18))
                                                    .foregroundColor(method.2)
                                                    .frame(width: 32, height: 32)
                                                    .background(method.2.opacity(0.1))
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                
                                                Text(method.0)
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundColor(UMobileTheme.uTextDark)
                                                
                                                Spacer()
                                                
                                                if selectedMethod == method.0 {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(UMobileTheme.uOrange)
                                                        .font(.system(size: 18))
                                                } else {
                                                    Circle()
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                                                        .frame(width: 18, height: 18)
                                                }
                                            }
                                            .padding(14)
                                            .background(selectedMethod == method.0 ? UMobileTheme.uLightOrange.opacity(0.5) : Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedMethod == method.0 ? UMobileTheme.uOrange.opacity(0.6) : Color.clear, lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(18)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .padding(18)
                    }
                    .background(UMobileTheme.uCreamTile.opacity(0.5))
                    
                    // Bottom Pay Button
                    VStack {
                        Button(action: {
                            isProcessing = true
                            let amt = Double(amountString) ?? 72.10
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                store.recordPayment(amount: amt, channel: selectedMethod)
                                isProcessing = false
                                paymentSuccess = true
                            }
                        }) {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.trailing, 6)
                                }
                                Text(isProcessing ? "Processing Payment..." : "Pay RM\(amountString)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(UMobileTheme.orangeGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: UMobileTheme.uOrange.opacity(0.35), radius: 8, y: 3)
                        }
                        .disabled(isProcessing)
                        .padding(18)
                    }
                    .background(Color.white)
                }
            }
            .navigationTitle("Pay Bill")
            .circleNavigationTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(UMobileTheme.uOrange)
                }
            }
        }
    }
}

// MARK: - Roaming Sheet
public struct RoamingSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Header Banner
                    VStack(alignment: .leading, spacing: 8) {
                        Text("GLOBAL 5G ROAMING")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(UMobileTheme.uOrange)
                            .tracking(1)
                        Text("Connect Seamlessly in 63+ Countries")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(UMobileTheme.uTextDark)
                        Text("No manual activation needed. Roam automatically with your U Postpaid plan.")
                            .font(.system(size: 14))
                            .foregroundColor(UMobileTheme.uTextSecondary)
                    }
                    .padding(18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Text("Popular Roaming Passes")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(UMobileTheme.uTextDark)
                    
                    VStack(spacing: 12) {
                        roamingCard(
                            title: "U Data Roam 1-Day",
                            price: "RM15/day",
                            data: "500MB High-Speed + Unlimited 512kbps",
                            countries: "Singapore, Thailand, Indonesia & 60 more"
                        )
                        roamingCard(
                            title: "U Data Roam 7-Day",
                            price: "RM35/week",
                            data: "5GB High-Speed Roaming Data",
                            countries: "Popular ASEAN destinations"
                        )
                        roamingCard(
                            title: "Global 15-Day Pass",
                            price: "RM68",
                            data: "10GB High-Speed 5G Roaming",
                            countries: "Worldwide (UK, USA, Japan, Australia, Europe)"
                        )
                    }
                }
                .padding(18)
            }
            .background(UMobileTheme.uCreamTile.opacity(0.5))
            .navigationTitle("Roaming")
            .circleNavigationTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(UMobileTheme.uOrange)
                }
            }
        }
    }
    
    private func roamingCard(title: String, price: String, data: String, countries: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(UMobileTheme.uTextDark)
                Spacer()
                Text(price)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(UMobileTheme.uOrange)
            }
            
            Text(data)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(UMobileTheme.uTextDark.opacity(0.8))
            
            HStack(spacing: 4) {
                Image(systemName: "globe.asia.australia.fill")
                    .font(.system(size: 12))
                    .foregroundColor(UMobileTheme.uTextSecondary)
                Text(countries)
                    .font(.system(size: 12))
                    .foregroundColor(UMobileTheme.uTextSecondary)
            }
            
            Button("Subscribe Pass") {}
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(UMobileTheme.uOrange)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(UMobileTheme.uLightOrange)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - AddOns Sheet
public struct AddOnsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Speed & Quota Boosters")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(UMobileTheme.uTextDark)
                    
                    VStack(spacing: 12) {
                        addonCard(title: "5G Extra 50GB Booster", price: "RM10", desc: "Ultra-fast 5G data booster valid for 7 days.")
                        addonCard(title: "Hotspot 30GB Add-On", price: "RM5", desc: "Share more high-speed connection with your devices.")
                        addonCard(title: "Unlimited Video & Streaming", price: "RM8/mo", desc: "Zero data charges on YouTube, Netflix & Viu.")
                    }
                }
                .padding(18)
            }
            .background(UMobileTheme.uCreamTile.opacity(0.5))
            .navigationTitle("Add-Ons")
            .circleNavigationTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(UMobileTheme.uOrange)
                }
            }
        }
    }
    
    private func addonCard(title: String, price: String, desc: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(UMobileTheme.uTextDark)
                Text(desc)
                    .font(.system(size: 13))
                    .foregroundColor(UMobileTheme.uTextSecondary)
            }
            Spacer()
            VStack(spacing: 6) {
                Text(price)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(UMobileTheme.uOrange)
                Button("Add") {}
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(UMobileTheme.uOrange)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Transaction History Sheet
public struct TransactionHistorySheet: View {
    @Environment(UMobileStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(store.transactions) { record in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(record.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(UMobileTheme.uTextDark)
                                Spacer()
                                Text(String(format: "-RM%.2f", record.amount))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(UMobileTheme.uTextDark)
                            }
                            
                            HStack {
                                Text(record.date)
                                    .font(.system(size: 12))
                                    .foregroundColor(UMobileTheme.uTextSecondary)
                                Spacer()
                                Text(record.status)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            
                            Text("Ref: \(record.referenceNo)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(UMobileTheme.uTextSecondary)
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(18)
            }
            .background(UMobileTheme.uCreamTile.opacity(0.5))
            .navigationTitle("Transaction History")
            .circleNavigationTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(UMobileTheme.uOrange)
                }
            }
        }
    }
}

// MARK: - Account Switcher Sheet
public struct AccountSwitcherSheet: View {
    @Environment(UMobileStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Switch Active Mobile Line")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(UMobileTheme.uTextSecondary)
                    .padding(.top, 16)
                
                VStack(spacing: 10) {
                    ForEach(store.currentAccount.linkedNumbers, id: \.self) { number in
                        Button(action: {
                            store.switchAccount(to: number)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "iphone.gen3")
                                    .font(.system(size: 20))
                                    .foregroundColor(number == store.currentAccount.phoneNumber ? UMobileTheme.uOrange : UMobileTheme.uTextSecondary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(number)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(UMobileTheme.uTextDark)
                                    Text(number == "018-2218836" ? "Primary Postpaid Line (U Postpaid 68)" : "Secondary Family Line")
                                        .font(.system(size: 12))
                                        .foregroundColor(UMobileTheme.uTextSecondary)
                                }
                                
                                Spacer()
                                
                                if number == store.currentAccount.phoneNumber {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(UMobileTheme.uOrange)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
                
                Spacer()
            }
            .background(UMobileTheme.uCreamTile.opacity(0.5))
            .navigationTitle("Linked Accounts")
            .circleNavigationTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(UMobileTheme.uOrange)
                }
            }
        }
    }
}

// MARK: - Notifications Sheet
public struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    notificationRow(
                        title: "Bill Ready: October 2026",
                        message: "Your monthly statement of RM72.10 is ready. Pay before 31/10/2026 to avoid interruption.",
                        time: "Yesterday, 8:07 PM",
                        isUnread: true
                    )
                    notificationRow(
                        title: "5G Ultra Speed Upgrade",
                        message: "Enjoy uncapped 5G speeds now live in your area with zero extra fees!",
                        time: "28 Sep 2026",
                        isUnread: false
                    )
                    notificationRow(
                        title: "U Rewards Voucher Expiring",
                        message: "Your RM10 Inside Scoop ice cream voucher expires in 3 days. Claim now!",
                        time: "25 Sep 2026",
                        isUnread: false
                    )
                }
                .padding(18)
            }
            .background(UMobileTheme.uCreamTile.opacity(0.5))
            .navigationTitle("Notifications")
            .circleNavigationTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(UMobileTheme.uOrange)
                }
            }
        }
    }
    
    private func notificationRow(title: String, message: String, time: String, isUnread: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(UMobileTheme.uTextDark)
                Spacer()
                if isUnread {
                    Circle()
                        .fill(UMobileTheme.uOrange)
                        .frame(width: 8, height: 8)
                }
            }
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(UMobileTheme.uTextSecondary)
            Text(time)
                .font(.system(size: 11))
                .foregroundColor(UMobileTheme.uTextSecondary.opacity(0.7))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
