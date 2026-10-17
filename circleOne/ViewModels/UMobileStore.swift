import SwiftUI
import Observation

public enum ActiveModalSheet: Identifiable {
    case viewBill
    case payBill
    case roaming
    case addOns
    case transactionHistory
    case upgradePlan
    case accountSwitcher
    case notifications
    case dealDetail(DealItem)
    
    public var id: String {
        switch self {
        case .viewBill: return "viewBill"
        case .payBill: return "payBill"
        case .roaming: return "roaming"
        case .addOns: return "addOns"
        case .transactionHistory: return "transactionHistory"
        case .upgradePlan: return "upgradePlan"
        case .accountSwitcher: return "accountSwitcher"
        case .notifications: return "notifications"
        case .dealDetail(let deal): return "deal_\(deal.id)"
        }
    }
}

@Observable
public final class UMobileStore {
    public var currentAccount: UserAccount
    public var activePlan: PostpaidPlan
    public var availablePlans: [PostpaidPlan]
    public var activePlanIndex: Int = 0
    public var selectedTab: Int = 0
    public var activeSheet: ActiveModalSheet? = nil
    public var unreadNotificationsCount: Int = 1
    
    public var transactions: [TransactionRecord] = [
        TransactionRecord(
            title: "Bill Payment - FPX (Maybank2u)",
            date: "30 Sep 2026, 02:45 PM",
            amount: 72.10,
            referenceNo: "UM-PAY-98310294",
            channel: "Online Banking",
            status: "Success"
        ),
        TransactionRecord(
            title: "Bill Payment - Touch 'n Go eWallet",
            date: "31 Aug 2026, 11:20 AM",
            amount: 68.00,
            referenceNo: "UM-PAY-77401928",
            channel: "eWallet",
            status: "Success"
        ),
        TransactionRecord(
            title: "U Data Roam 1-Day Pass (Singapore)",
            date: "14 Aug 2026, 08:12 AM",
            amount: 15.00,
            referenceNo: "UM-ROAM-449102",
            channel: "Direct Bill",
            status: "Completed"
        )
    ]
    
    public var deals: [DealItem] = [
        DealItem(
            title: "FAST INTERNET SMARTER HOME",
            subtitle: "Sign up U Home 5G & enjoy 3 months FREE broadband!",
            badge: "FREE 3 MONTHS",
            imageName: "deal_banner",
            validity: "Valid until 31 Dec 2026",
            actionUrl: "https://www.u.com.my/en/personal/broadband/u-home-5g"
        ),
        DealItem(
            title: "Global 5G Roaming Pass",
            subtitle: "Uncapped roaming speeds across 63 destinations from RM10/day.",
            badge: "POPULAR",
            imageName: "hero_background",
            validity: "Valid worldwide",
            actionUrl: "https://www.u.com.my/roaming"
        )
    ]
    
    public init() {
        self.currentAccount = UserAccount()
        self.activePlan = PostpaidPlan()
        self.availablePlans = [
            PostpaidPlan(
                planName: "U Postpaid 68 v2",
                planCode: "UPostpaid68v2",
                planSubtitle: "U Postpaid 68 Base Data with Hotspot",
                usedDataGB: 6.29,
                totalDataGB: 500.0,
                hotspotUsedGB: 4.10,
                hotspotTotalGB: 100.0,
                freeRoamingCountries: 63,
                monthlyFee: 68.00
            ),
            PostpaidPlan(
                planName: "U Family Share 38",
                planCode: "UFamilyShare38",
                planSubtitle: "Shared High-Speed 5G Quota",
                usedDataGB: 18.40,
                totalDataGB: 150.0,
                hotspotUsedGB: 12.00,
                hotspotTotalGB: 50.0,
                freeRoamingCountries: 15,
                monthlyFee: 38.00
            )
        ]
    }
    
    public func selectPlan(at index: Int) {
        guard index >= 0 && index < availablePlans.count else { return }
        activePlanIndex = index
        activePlan = availablePlans[index]
    }
    
    public func switchAccount(to phoneNumber: String) {
        currentAccount.phoneNumber = phoneNumber
        if phoneNumber == "018-9842109" {
            currentAccount.accountHolderName = "Looi Jun Hong (Line 2)"
            currentAccount.totalDue = 38.00
            selectPlan(at: 1)
        } else {
            currentAccount.accountHolderName = "Looi Jun Hong"
            currentAccount.totalDue = 72.10
            selectPlan(at: 0)
        }
    }
    
    public func recordPayment(amount: Double, channel: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, hh:mm a"
        let dateString = formatter.string(from: Date())
        
        let newRecord = TransactionRecord(
            title: "Bill Payment - \(channel)",
            date: dateString,
            amount: amount,
            referenceNo: "UM-PAY-\(Int.random(in: 10000000...99999999))",
            channel: channel,
            status: "Success"
        )
        transactions.insert(newRecord, at: 0)
        currentAccount.totalDue = max(0, currentAccount.totalDue - amount)
    }
}
