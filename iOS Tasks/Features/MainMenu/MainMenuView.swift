import SwiftUI

struct MainMenuView: View {
    @Binding var currentRoute: GameRoute
    @Binding var bestTapFrenzy: Int
    @Binding var bestLightItUp: Int
    let onTapFrenzySelected: () -> Void
    
    var body: some View {
        ZStack {
            // Modern dark gradient background
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 35) {
                VStack(spacing: 8) {
                    Text("Collection")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .tracking(3) // Modern letter-spacing
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .primary.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("Choose game")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                VStack(spacing: 20) {
                    menuButton(
                        title: "Tap Frenzy",
                        subtitle: "Fast-paced rhythm clicking challenge",
                        icon: "sparkles",
                        bestScore: bestTapFrenzy,
                        gradientColors: [.orange, .pink]
                    ) {
                        onTapFrenzySelected()
                    }
                    
                    menuButton(
                        title: "Light It Up",
                        subtitle: "Precision puzzle matching game",
                        icon: "lightbulb.fill",
                        bestScore: bestLightItUp,
                        gradientColors: [.purple, .blue]
                    ) {
                        currentRoute = .lightItUp
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
    
    private func menuButton(
        title: String,
        subtitle: String,
        icon: String,
        bestScore: Int,
        gradientColors: [Color],
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Featured Icon Asset Block
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 54, height: 54)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                    
                    // High score badge
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.caption2)
                        Text("Record: \(bestScore)")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark) // Forces contrast on glass morphic badge
                    .clipShape(Capsule())
                    .padding(.top, 2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.all, 16)
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: gradientColors[0].opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(MenuButtonStyle()) // Custom press scaling
    }
}
