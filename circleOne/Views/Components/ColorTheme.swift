import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    #if canImport(UIKit)
    public static let circleBackground = Color(uiColor: .systemGroupedBackground)
    public static let circleCardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    public static let circleSubCardBackground = Color(uiColor: .tertiarySystemGroupedBackground)
    #elseif canImport(AppKit)
    public static let circleBackground = Color(nsColor: .windowBackgroundColor)
    public static let circleCardBackground = Color(nsColor: .controlBackgroundColor)
    public static let circleSubCardBackground = Color(nsColor: .underPageBackgroundColor)
    #else
    public static let circleBackground = Color.gray.opacity(0.1)
    public static let circleCardBackground = Color.white
    public static let circleSubCardBackground = Color.gray.opacity(0.05)
    #endif
    
    // Custom brand accents for circleOne
    public static let circlePrimaryGradientStart = Color(red: 0.08, green: 0.45, blue: 0.95)
    public static let circlePrimaryGradientEnd = Color(red: 0.10, green: 0.70, blue: 0.85)
}

extension View {
    @ViewBuilder
    public func circleNavigationTitleDisplayModeInline() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
    
    @ViewBuilder
    public func circleNavigationTitleDisplayModeLarge() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.large)
        #else
        self
        #endif
    }
    
    @ViewBuilder
    public func circleGroupedListStyle() -> some View {
        #if os(iOS)
        self.listStyle(.insetGrouped)
        #else
        self
        #endif
    }
}

extension ToolbarItemPlacement {
    public static var circleLeading: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarLeading
        #else
        return .cancellationAction
        #endif
    }
    
    public static var circleTrailing: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarTrailing
        #else
        return .primaryAction
        #endif
    }
}
