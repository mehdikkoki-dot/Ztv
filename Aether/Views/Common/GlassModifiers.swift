import SwiftUI

// MARK: - Apple Fluid Design Buttons & Cards (Inspired by Emil Kowalski's apple-design)
public struct AppleTactileButtonStyle: ButtonStyle {
    public let scaleAmount: CGFloat
    
    public init(scaleAmount: CGFloat = 0.96) {
        self.scaleAmount = scaleAmount
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.32, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

public struct AppleGlassModifier: ViewModifier {
    public let cornerRadius: CGFloat
    
    public func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
    }
}

public extension View {
    func appleGlass(cornerRadius: CGFloat = 20) -> some View {
        self.modifier(AppleGlassModifier(cornerRadius: cornerRadius))
    }
    
    func appleTactile(scale: CGFloat = 0.96) -> some View {
        self.buttonStyle(AppleTactileButtonStyle(scaleAmount: scale))
    }
}
