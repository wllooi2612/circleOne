import SwiftUI

public struct LeaveTypePickerView: View {
    @Binding var selectedType: LeaveType
    public let balances: [LeaveBalance]
    
    public init(selectedType: Binding<LeaveType>, balances: [LeaveBalance]) {
        self._selectedType = selectedType
        self.balances = balances
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LeaveType.allCases) { type in
                    let balance = balances.first(where: { $0.type == type })
                    let isSelected = selectedType == type
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedType = type
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: type.iconName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(isSelected ? .white : type.tintColor)
                                
                                Spacer()
                                
                                if let balance = balance {
                                    Text("\(balance.formattedAvailable) left")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                                }
                            }
                            
                            Text(type.rawValue)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isSelected ? .white : .primary)
                                .lineLimit(1)
                            
                            Text(type.description)
                                .font(.system(size: 10))
                                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(12)
                        .frame(width: 155, height: 115)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    isSelected
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [type.tintColor, type.tintColor.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    : AnyShapeStyle(Color.circleCardBackground)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color.clear : Color.primary.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: isSelected ? type.tintColor.opacity(0.3) : Color.black.opacity(0.03), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
}
