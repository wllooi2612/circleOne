import SwiftUI

public struct ReceiptIconShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let scallopCount = 4
        let scallopWidth = w / CGFloat(scallopCount)
        let scallopHeight = h * 0.12
        
        // Start top left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 2))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 2))
        // Down right side
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - scallopHeight))
        
        // Scalloped / zig-zag bottom
        for i in 0..<scallopCount {
            let xStart = rect.maxX - CGFloat(i) * scallopWidth
            let xMid = xStart - scallopWidth / 2
            let xEnd = xStart - scallopWidth
            
            path.addLine(to: CGPoint(x: xMid, y: rect.maxY))
            path.addLine(to: CGPoint(x: xEnd, y: rect.maxY - scallopHeight))
        }
        
        // Up left side
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 2))
        path.closeSubpath()
        return path
    }
}

public struct ServiceIconView: View {
    public let type: ServiceType
    public var size: CGFloat = 28
    
    public init(type: ServiceType, size: CGFloat = 28) {
        self.type = type
        self.size = size
    }
    
    public var body: some View {
        Group {
            switch type {
            case .payBill:
                // Receipt with folded corner and lines
                ZStack {
                    ReceiptIconShape()
                        .stroke(UMobileTheme.uOrange, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                        .frame(width: size * 0.85, height: size)
                    
                    VStack(spacing: 3) {
                        Rectangle()
                            .fill(UMobileTheme.uOrange)
                            .frame(width: size * 0.45, height: 2)
                        Rectangle()
                            .fill(UMobileTheme.uOrange)
                            .frame(width: size * 0.45, height: 2)
                    }
                    .offset(y: -1)
                }
                
            case .roaming:
                // Airplane angled
                Image(systemName: "airplane")
                    .font(.system(size: size * 0.95, weight: .bold))
                    .foregroundColor(UMobileTheme.uOrange)
                    .rotationEffect(.degrees(-35))
                
            case .addOns:
                // Rocket icon
                ZStack {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: size * 0.9, weight: .bold))
                        .foregroundColor(UMobileTheme.uOrange)
                        .rotationEffect(.degrees(45))
                }
                
            case .transactionHistory:
                // Calendar with dollar badge or clock
                ZStack {
                    Image(systemName: "calendar")
                        .font(.system(size: size * 0.9, weight: .medium))
                        .foregroundColor(UMobileTheme.uOrange)
                    
                    Text("$")
                        .font(.system(size: size * 0.42, weight: .black, design: .rounded))
                        .foregroundColor(UMobileTheme.uOrange)
                        .offset(x: 2, y: 3)
                }
                
            case .upgradePlan:
                // Sim card / doc with up arrow
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(UMobileTheme.uOrange, lineWidth: 2)
                        .frame(width: size * 0.75, height: size * 0.95)
                    
                    Image(systemName: "arrow.up")
                        .font(.system(size: size * 0.5, weight: .black))
                        .foregroundColor(UMobileTheme.uOrange)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

public struct ServiceTileButton: View {
    public let type: ServiceType
    public let action: () -> Void
    
    public init(type: ServiceType, action: @escaping () -> Void) {
        self.type = type
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Card Box
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(UMobileTheme.uCreamTile)
                        .frame(width: 68, height: 68)
                    
                    ServiceIconView(type: type, size: 28)
                }
                
                // Label
                Text(type.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(UMobileTheme.uTextDark)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .lineSpacing(2)
                    .frame(height: 32, alignment: .top)
            }
            .frame(width: 72)
        }
        .buttonStyle(.plain)
    }
}
