import SwiftUI

public struct StatMetricCard: View {
    public let title: String
    public let value: String
    public let subtitle: String
    public let systemImage: String
    public let tintColor: Color
    
    public init(title: String, value: String, subtitle: String, systemImage: String, tintColor: Color) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tintColor = tintColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(tintColor)
                    .padding(8)
                    .background(tintColor.opacity(0.12))
                    .clipShape(Circle())
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary.opacity(0.8))
                .lineLimit(1)
            
            Text(subtitle)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.circleCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}
