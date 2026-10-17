import Foundation

public struct UserAccount: Codable, Identifiable {
    public var id: String { phoneNumber }
    public var phoneNumber: String
    public var accountHolderName: String
    public var accountNumber: String
    public var totalDue: Double
    public var dueDate: String
    public var linkedNumbers: [String]
    
    public init(
        phoneNumber: String = "018-2218836",
        accountHolderName: String = "Looi Jun Hong",
        accountNumber: String = "1.082736481",
        totalDue: Double = 72.10,
        dueDate: String = "31/10/2026",
        linkedNumbers: [String] = ["018-2218836", "018-9842109", "018-3351982"]
    ) {
        self.phoneNumber = phoneNumber
        self.accountHolderName = accountHolderName
        self.accountNumber = accountNumber
        self.totalDue = totalDue
        self.dueDate = dueDate
        self.linkedNumbers = linkedNumbers
    }
}

public struct PostpaidPlan: Codable, Identifiable {
    public var id: String { planCode }
    public var planName: String
    public var planCode: String
    public var planSubtitle: String
    public var usedDataGB: Double
    public var totalDataGB: Double
    public var hotspotUsedGB: Double
    public var hotspotTotalGB: Double
    public var freeRoamingCountries: Int
    public var monthlyFee: Double
    public var billingCycle: String
    
    public var formattedUsedData: String {
        String(format: "%.2f", usedDataGB)
    }
    
    public var formattedTotalData: String {
        "\(Int(totalDataGB))GB"
    }
    
    public var progressRatio: Double {
        min(max(usedDataGB / totalDataGB, 0.0), 1.0)
    }
    
    public init(
        planName: String = "U Postpaid 68 v2",
        planCode: String = "UPostpaid68v2",
        planSubtitle: String = "U Postpaid 68 Base Data with Hotspot",
        usedDataGB: Double = 6.29,
        totalDataGB: Double = 500.0,
        hotspotUsedGB: Double = 4.10,
        hotspotTotalGB: Double = 100.0,
        freeRoamingCountries: Int = 63,
        monthlyFee: Double = 68.00,
        billingCycle: String = "01 Oct - 31 Oct 2026"
    ) {
        self.planName = planName
        self.planCode = planCode
        self.planSubtitle = planSubtitle
        self.usedDataGB = usedDataGB
        self.totalDataGB = totalDataGB
        self.hotspotUsedGB = hotspotUsedGB
        self.hotspotTotalGB = hotspotTotalGB
        self.freeRoamingCountries = freeRoamingCountries
        self.monthlyFee = monthlyFee
        self.billingCycle = billingCycle
    }
}

public enum ServiceType: String, CaseIterable, Identifiable {
    case payBill = "pay_bill"
    case roaming = "roaming"
    case addOns = "add_ons"
    case transactionHistory = "transaction_history"
    case upgradePlan = "upgrade_plan"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .payBill: return "Pay Bill for\nSelf"
        case .roaming: return "Roaming"
        case .addOns: return "Add-Ons"
        case .transactionHistory: return "Transaction\nHistory"
        case .upgradePlan: return "Upgrade\nPlan"
        }
    }
}

public struct BillBreakdownItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let detail: String
    public let amount: Double
}

public struct TransactionRecord: Identifiable {
    public let id = UUID()
    public let title: String
    public let date: String
    public let amount: Double
    public let referenceNo: String
    public let channel: String
    public let status: String
}

public struct DealItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let badge: String
    public let imageName: String
    public let validity: String
    public let actionUrl: String
}
