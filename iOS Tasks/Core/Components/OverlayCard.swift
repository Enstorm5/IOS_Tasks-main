import SwiftUI

/// Unified overlay card — merges the old `CardContainer` (TapFrenzy) and
/// `GameOverlayCard` (LightItUp) into one reusable component.
///
/// - `.standard`    → opaque system-background card with dimming backdrop (TapFrenzy style)
/// - `.glassmorphic` → translucent material card with subtle stroke (LightItUp style)
enum OverlayCardStyle {
    case standard
    case glassmorphic
}

struct OverlayCard<Content: View>: View {
    let style: OverlayCardStyle
    let content: Content
    
    init(style: OverlayCardStyle = .glassmorphic, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        switch style {
        case .standard:
            ZStack {
                Color.black.opacity(0.4).ignoresSafeArea()
                content
                    .padding(30)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(24)
                    .shadow(radius: 20)
                    .padding(.horizontal, 40)
            }
        case .glassmorphic:
            VStack {
                content
            }
            .padding(.all, 28)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 36)
            .transition(.opacity.combined(with: .scale(scale: 0.92)))
        }
    }
}
