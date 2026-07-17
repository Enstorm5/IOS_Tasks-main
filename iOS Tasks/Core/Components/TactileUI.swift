import SwiftUI


let brutalistDark = Color(red: 15/255, green: 23/255, blue: 42/255) // #0F172A
let brutalistBg = Color(red: 248/255, green: 250/255, blue: 252/255) // #F8FAFC
let panelBg = Color(red: 241/255, green: 245/255, blue: 249/255) // #F1F5F9
let cautionYellow = Color(red: 250/255, green: 204/255, blue: 21/255) // #FACC15



func tactilePixelBackground() -> some View {
    Canvas { context, size in
        let dotSize: CGFloat = 1
        let spacing: CGFloat = 16
        
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(brutalistBg))
        
        for x in stride(from: 0, to: size.width, by: spacing) {
            for y in stride(from: 0, to: size.height, by: spacing) {
                let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                context.fill(Path(rect), with: .color(Color(red: 203/255, green: 213/255, blue: 225/255)))
            }
        }
    }
    .ignoresSafeArea()
}

func tactileCornerBrackets(color: Color) -> some View {
    GeometryReader { geo in
        Path { path in
            // TL
            path.move(to: CGPoint(x: 6, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 6))
            
            // TR
            path.move(to: CGPoint(x: geo.size.width - 6, y: 0))
            path.addLine(to: CGPoint(x: geo.size.width, y: 0))
            path.addLine(to: CGPoint(x: geo.size.width, y: 6))
            
            // BL
            path.move(to: CGPoint(x: 6, y: geo.size.height))
            path.addLine(to: CGPoint(x: 0, y: geo.size.height))
            path.addLine(to: CGPoint(x: 0, y: geo.size.height - 6))
            
            // BR
            path.move(to: CGPoint(x: geo.size.width - 6, y: geo.size.height))
            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height - 6))
        }
        .stroke(color, lineWidth: 3)
    }
    .padding(-4) // Offset outwards
}

func tactileUIAccent(alignment: Alignment) -> some View {
    GeometryReader { geo in
        Path { path in
            if alignment == .topLeading {
                path.move(to: CGPoint(x: 8, y: 4))
                path.addLine(to: CGPoint(x: 4, y: 4))
                path.addLine(to: CGPoint(x: 4, y: 8))
            } else {
                path.move(to: CGPoint(x: geo.size.width - 8, y: geo.size.height - 4))
                path.addLine(to: CGPoint(x: geo.size.width - 4, y: geo.size.height - 4))
                path.addLine(to: CGPoint(x: geo.size.width - 4, y: geo.size.height - 8))
            }
        }
        .stroke(brutalistDark, lineWidth: 1.5)
    }
}



/// Standard Brutalist Card with heavy border, drop shadow, and corner accents
struct TactileCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                brutalistBg
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: 4, y: 4)
            )
            .overlay(tactileUIAccent(alignment: .topLeading))
            .overlay(tactileUIAccent(alignment: .bottomTrailing))
    }
}

/// A standard yellow thick line used for emphasizing titles
func tactileTitleAccent() -> some View {
    Rectangle()
        .fill(cautionYellow)
        .frame(width: 8, height: 24)
        .border(brutalistDark, width: 1)
}



/// Primary Action Button (Yellow background, thick border, drop shadow)
struct TactileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                cautionYellow
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: configuration.isPressed ? 0 : 3, y: configuration.isPressed ? 0 : 3)
            )
            .offset(x: configuration.isPressed ? 3 : 0, y: configuration.isPressed ? 3 : 0)
    }
}

/// Secondary Action Button (White/Light background, thick border, drop shadow)
struct TactileSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color.white
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: configuration.isPressed ? 0 : 3, y: configuration.isPressed ? 0 : 3)
            )
            .offset(x: configuration.isPressed ? 3 : 0, y: configuration.isPressed ? 3 : 0)
    }
}

/// Success Action Button (Green background, thick border, drop shadow)
struct TactileSuccessButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color.green
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: configuration.isPressed ? 0 : 3, y: configuration.isPressed ? 0 : 3)
            )
            .offset(x: configuration.isPressed ? 3 : 0, y: configuration.isPressed ? 3 : 0)
    }
}

/// Dynamic Color Action Button
struct TactileDynamicButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                color
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: configuration.isPressed ? 0 : 3, y: configuration.isPressed ? 0 : 3)
            )
            .offset(x: configuration.isPressed ? 3 : 0, y: configuration.isPressed ? 3 : 0)
    }
}



struct TactileBadgeModifier: ViewModifier {
    var color: Color
    func body(content: Content) -> some View {
        content
            .background(
                color
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: 3, y: 3)
            )
    }
}

extension View {
    func tactileBadge(color: Color = cautionYellow) -> some View {
        self.modifier(TactileBadgeModifier(color: color))
    }
}

/// Icon Action Button (White/Light background, smaller shadow, used for top bar icons)
struct TactileIconButtonStyle: ButtonStyle {
    var isSelected: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                (isSelected ? cautionYellow : Color.white)
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: configuration.isPressed ? 0 : 2, y: configuration.isPressed ? 0 : 2)
            )
            .offset(x: configuration.isPressed ? 2 : 0, y: configuration.isPressed ? 2 : 0)
    }
}

/// Segment Toggle Button Style
struct TactileSegmentButtonStyle: ButtonStyle {
    var isSelected: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                (isSelected ? cautionYellow : Color.white)
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: configuration.isPressed ? 0 : 2, y: configuration.isPressed ? 0 : 2)
            )
            .offset(x: configuration.isPressed ? 2 : 0, y: configuration.isPressed ? 2 : 0)
    }
}

/// A unified game over modal to be used across all games
struct TactileGameOverModal: View {
    let score: Int
    let gameName: String
    let onMenu: () -> Void
    let onPlayAgain: () -> Void
    
    var body: some View {
        TactileCard {
            VStack(spacing: 24) {
                Text("ROUND OVER")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.red)
                
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(brutalistDark)
                    Text("FINAL SCORE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.gray)
                }
                
                ShareLink(item: "I just scored \(score) on \(gameName)! Can you beat me?") {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("SHARE SCORE")
                    }
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(brutalistDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(TactileButtonStyle())
                
                HStack(spacing: 12) {
                    Button(action: onMenu) {
                        Text("MENU")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(brutalistDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(TactileSecondaryButtonStyle())
                    
                    Button(action: onPlayAgain) {
                        Text("PLAY AGAIN")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(TactileSuccessButtonStyle())
                }
            }
            .padding(32)
        }
        .padding(.horizontal, 24)
    }
}



/// A unified brutalist banner for alerts (Level Up, Success, Failed, etc)
struct TactileBanner: View {
    let text: String
    var textColor: Color = .white
    var backgroundColor: Color = cautionYellow
    var borderColor: Color = brutalistDark
    var angle: Double = 0
    var fontSize: CGFloat = 36
    var tracking: CGFloat = 0
    var paddingH: CGFloat = 20
    var paddingV: CGFloat = 20
    
    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .black))
            .tracking(tracking)
            .foregroundColor(textColor)
            .padding(.horizontal, paddingH)
            .padding(.vertical, paddingV)
            .background(
                backgroundColor
                    .border(borderColor, width: 4)
                    .shadow(color: brutalistDark, radius: 0, x: 6, y: 6)
            )
            .rotationEffect(.degrees(angle))
            .transition(.scale.combined(with: .opacity))
            .zIndex(10)
    }
}
