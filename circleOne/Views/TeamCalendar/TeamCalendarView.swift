import SwiftUI

public struct TeamCalendarView: View {
    @Environment(LeaveStore.self) private var store
    
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    public init() {}
    
    private var daysInCurrentMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        
        let startOfMonth = monthInterval.start
        let startWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var dates: [Date] = []
        if startWeekday > 1 {
            for dayOffset in (1..<startWeekday).reversed() {
                if let prevDate = calendar.date(byAdding: .day, value: -dayOffset, to: startOfMonth) {
                    dates.append(prevDate)
                }
            }
        }
        
        let daysCount = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
        for dayOffset in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private var leavesOnSelectedDate: [LeaveRequest] {
        store.leavesOn(date: selectedDate)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    monthHeader
                    calendarGridCard
                    dayAbsencesCard
                }
                .padding(16)
            }
            .background(Color.circleBackground.ignoresSafeArea())
            .navigationTitle("Team Calendar")
            #if os(iOS)
            .circleNavigationTitleDisplayModeLarge()
            #endif
        }
    }
    
    private var monthHeader: some View {
        HStack {
            Text(monthYearString(from: currentMonth))
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
            
            HStack(spacing: 8) {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .padding(8)
                        .background(Color.circleCardBackground)
                        .clipShape(Circle())
                }
                
                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .padding(8)
                        .background(Color.circleCardBackground)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private var calendarGridCard: some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(0..<7, id: \.self) { idx in
                    Text(daysOfWeek[idx])
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(idx == 0 || idx == 6 ? .secondary.opacity(0.6) : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            Divider()
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInCurrentMonth, id: \.self) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(date)
                    let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                    let dayLeaves = store.leavesOn(date: date)
                    
                    CalendarDayButton(
                        date: date,
                        isSelected: isSelected,
                        isToday: isToday,
                        isCurrentMonth: isCurrentMonth,
                        leaves: dayLeaves
                    ) {
                        selectedDate = date
                    }
                }
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
    
    private var dayAbsencesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.crop.circle.badge.clock")
                        .foregroundColor(.blue)
                    Text("Away on \(formatSelectedDate(selectedDate))")
                        .font(.system(size: 16, weight: .bold))
                }
                
                Spacer()
                
                Text("\(leavesOnSelectedDate.count) away")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            if leavesOnSelectedDate.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 26))
                            .foregroundColor(.green)
                        Text("Full Team Strength")
                            .font(.system(size: 14, weight: .semibold))
                        Text("No one is scheduled on leave on this date.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                ForEach(leavesOnSelectedDate) { req in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(req.leaveType.tintColor.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(req.employeeAvatarInitials)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(req.leaveType.tintColor)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(req.employeeName)
                                .font(.system(size: 14, weight: .bold))
                            
                            Text("\(req.leaveType.rawValue) • \(req.durationType.rawValue)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let reliever = req.relieverName {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Cover")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.secondary)
                                Text(reliever)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.circleSubCardBackground.opacity(0.5))
                    .cornerRadius(12)
                }
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
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }
    
    private func formatSelectedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        return f.string(from: date)
    }
}

private struct CalendarDayButton: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let leaves: [LeaveRequest]
    let action: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                let dayNum = calendar.component(.day, from: date)
                Text("\(dayNum)")
                    .font(.system(size: 14, weight: isToday ? .heavy : (isSelected ? .bold : .regular)))
                    .foregroundColor(textColor)
                
                HStack(spacing: 2) {
                    if !leaves.isEmpty {
                        ForEach(leaves.prefix(3)) { req in
                            Circle()
                                .fill(isSelected ? Color.white : req.leaveType.tintColor)
                                .frame(width: 4, height: 4)
                        }
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.12) : Color.clear))
            )
        }
        .buttonStyle(.plain)
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary.opacity(0.3)
        }
    }
}
