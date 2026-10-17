import SwiftUI

public struct UMobileTheme {
    // Brand primary orange
    public static let uOrange = Color(red: 1.0, green: 0.40, blue: 0.0)
    public static let uDeepOrange = Color(red: 0.95, green: 0.32, blue: 0.0)
    public static let uLightOrange = Color(red: 1.0, green: 0.94, blue: 0.90)
    
    // Backgrounds & Surfaces
    public static let uCreamTile = Color(red: 0.965, green: 0.961, blue: 0.949) // #F6F5F2
    public static let uCardGlass = Color.black.opacity(0.34)
    public static let uCardBorder = Color.white.opacity(0.22)
    public static let uPageBackground = Color(red: 0.985, green: 0.985, blue: 0.99)
    public static let uPureWhite = Color.white
    
    // Typography Colors
    public static let uTextDark = Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1E
    public static let uTextSecondary = Color(red: 0.55, green: 0.55, blue: 0.58) // #8E8E93
    public static let uTextMuted = Color(red: 0.42, green: 0.42, blue: 0.45)
    
    // Gradients
    public static let orangeGradient = LinearGradient(
        colors: [uOrange, uDeepOrange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let heroDarkGradient = LinearGradient(
        colors: [
            Color.black.opacity(0.72),
            Color.black.opacity(0.35),
            Color.black.opacity(0.05),
            Color.clear
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
