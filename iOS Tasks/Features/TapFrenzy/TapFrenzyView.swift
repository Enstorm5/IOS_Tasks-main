import SwiftUI

struct TapFrenzyView: View {
    @Binding var currentRoute: GameRoute
    @Binding var state: TapFrenzyState
    let onButtonTap: () -> Void
    let onGameAction: (TapFrenzyAction) -> Void
    
    let brutalistDark = Color(red: 15/255, green: 23/255, blue: 42/255) // #0F172A
    let brutalistBg = Color(red: 248/255, green: 250/255, blue: 252/255) // #F8FAFC
    let panelBg = Color(red: 241/255, green: 245/255, blue: 249/255) // #F1F5F9
    let cautionYellow = Color(red: 250/255, green: 204/255, blue: 21/255) // #FACC15
    
    @State private var scanlineOffset: CGFloat = -200
    @State private var pulse: Bool = false
    
    var body: some View {
        ZStack {
            pixelBackground()
            
            VStack(spacing: 0) {
                // We keep HUD in background when not playing, but slightly dimmed
                gameHUD()
                    .opacity(state.isPlaying ? 1.0 : 0.4)
                    .blur(radius: state.isPlaying ? 0 : 2)
                    .padding(.top, 80)
                
                Spacer()
                
                // Primary Target
                tapTarget()
                    .disabled(!state.isPlaying)
                    .opacity(state.isPlaying ? 1.0 : 0.1) // Ghost element when not playing
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if !state.isPlaying {
                startGameOverModal()
            }
        }
        .overlay(topBar(), alignment: .top)
        .ignoresSafeArea(.all, edges: .bottom)
        .background(brutalistBg)
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                scanlineOffset = 200
            }
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
        }
    }
    
    // Pixel dotted background
    func pixelBackground() -> some View {
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
    
    // Top Bar (Acts as back navigation)
    func topBar() -> some View {
        HStack {
            Button(action: { currentRoute = .mainMenu }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .black))
                    Text("ARCADE")
                        .font(.system(size: 20, weight: .black, design: .default))
                        .italic()
                }
                .foregroundColor(brutalistDark)
            }
            
            Spacer()
            
            Text("\(state.score) PTS")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(brutalistDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    cautionYellow
                        .border(brutalistDark, width: 2)
                        .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
    }
    
    // Gameplay HUD
    func gameHUD() -> some View {
        VStack(spacing: 32) {
            // Score
            VStack(spacing: 4) {
                Text("System_Score")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255)) // on-surface-variant
                    .tracking(2)
                
                Text("\(state.score)")
                    .font(.system(size: 60, weight: .black))
                    .foregroundColor(brutalistDark)
            }
            
            // Progress Bar
            VStack(spacing: 12) {
                HStack(alignment: .bottom) {
                    Text("TIMER_REMAINING")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
                    
                    Spacer()
                    
                    Text(String(format: "%.1fs", state.timeRemaining))
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(brutalistDark)
                }
                
                // Brutalist Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(red: 226/255, green: 232/255, blue: 240/255)) // surface-container-high
                        
                        Rectangle()
                            .fill(cautionYellow)
                            .frame(width: max(0, geo.size.width * CGFloat(state.timeRemaining / 10.0)))
                    }
                }
                .padding(2)
                .background(Color.white)
                .border(brutalistDark, width: 2)
                .frame(height: 20)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // The Tap Target
    func tapTarget() -> some View {
        ZStack {
            // Outer Decorative Marks
            Circle()
                .stroke(brutalistDark.opacity(0.05), lineWidth: 1)
                .frame(width: 320, height: 320)
            
            Button(action: onButtonTap) {
                tactilePanel {
                    ZStack {
                        // Scanline effect
                        Rectangle()
                            .fill(brutalistDark.opacity(0.1))
                            .frame(height: 2)
                            .offset(y: scanlineOffset)
                            .clipped()
                        
                        VStack {
                            Text("TAP!")
                                .font(.system(size: 40, weight: .black))
                                .italic()
                                .foregroundColor(brutalistDark)
                                .tracking(-1)
                            
                            if state.currentButtonColor == .grey {
                                Text("Penalty Active")
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                                    .foregroundColor(brutalistDark)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(cautionYellow.opacity(0.3))
                                    .overlay(cornerBrackets(color: cautionYellow))
                                    .padding(.top, 16)
                            }
                        }
                    }
                    .frame(width: 256, height: 256)
                }
                .background(
                    (state.currentButtonColor == .green ? Color.green.opacity(0.2) : panelBg)
                        .border(brutalistDark, width: 2)
                        .shadow(color: brutalistDark, radius: 0, x: 4, y: 4)
                )
                .overlay(uiAccent(alignment: .topLeading))
                .overlay(uiAccent(alignment: .bottomTrailing))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Technical Labels
            Text("Target_ID: 00-PX9")
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(brutalistDark)
                .offset(x: 100, y: -140)
            
            Text("Status: \(state.currentButtonColor == .grey ? "Restricted" : "Active")")
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .foregroundColor(brutalistDark)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    Color.white
                        .border(brutalistDark, width: 2)
                        .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
                )
                .offset(x: -80, y: 140)
        }
    }
    
    // Start / Game Over Modal
    func startGameOverModal() -> some View {
        ZStack {
            Color(red: 226/255, green: 232/255, blue: 240/255).opacity(0.6) // surface-dim
                .ignoresSafeArea()
            
            tactilePanel {
                VStack(spacing: 0) {
                    // Industrial Accent Bar
                    HStack(spacing: 4) {
                        Spacer()
                        Rectangle().fill(brutalistDark).frame(width: 6, height: 6)
                        Rectangle().fill(cautionYellow).frame(width: 6, height: 6).border(brutalistDark, width: 1)
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                    
                    VStack(spacing: 24) {
                        // Title
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Rectangle().fill(cautionYellow).frame(width: 8, height: 24).border(brutalistDark, width: 1)
                                
                                if state.isGameOver {
                                    Text("GAME ")
                                        .font(.system(size: 40, weight: .black))
                                        .italic()
                                        .foregroundColor(brutalistDark)
                                    + Text("OVER")
                                        .font(.system(size: 40, weight: .black))
                                        .italic()
                                        .foregroundColor(Color.red)
                                } else {
                                    Text("TAP ")
                                        .font(.system(size: 40, weight: .black))
                                        .italic()
                                        .foregroundColor(brutalistDark)
                                    + Text("FRENZY")
                                        .font(.system(size: 40, weight: .black))
                                        .italic()
                                        .foregroundColor(Color(red: 202/255, green: 138/255, blue: 4/255)) // tertiary #ca8a04
                                }
                            }
                            
                            Rectangle().fill(brutalistDark).frame(width: 48, height: 3)
                        }
                        
                        // Body
                        if state.isGameOver {
                            Text("Final Score: \(state.score)")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(brutalistDark)
                        } else {
                            Text("Tap as fast as you can inside ")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
                            + Text("10 seconds")
                                .font(.system(size: 17, weight: .black))
                                .foregroundColor(brutalistDark)
                            + Text(". Avoid penalty traps!")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
                        }
                        
                        // Action Button
                        Button(action: { onGameAction(.startOrRestartGame) }) {
                            HStack(spacing: 12) {
                                Text(state.isGameOver ? "PLAY AGAIN" : "START GAME")
                                    .font(.system(size: 22, weight: .black))
                                    .italic()
                                    .tracking(-1)
                                
                                Image(systemName: "play.fill")
                            }
                            .foregroundColor(brutalistDark)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                            .background(
                                cautionYellow
                                    .border(brutalistDark, width: 2)
                                    .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
                            )
                            .overlay(
                                Path { path in
                                    path.move(to: CGPoint(x: 4, y: 0))
                                    path.addLine(to: CGPoint(x: 0, y: 0))
                                    path.addLine(to: CGPoint(x: 0, y: 4))
                                }
                                .stroke(brutalistDark, lineWidth: 1)
                                .padding(4), alignment: .topLeading
                            )
                        }
                        
                        // Status Bar
                        HStack(spacing: 16) {
                            Text("SYS_READY")
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                                .scaleEffect(pulse ? 1.5 : 1.0)
                                .opacity(pulse ? 0.5 : 1.0)
                            Text("V.2.0.4")
                        }
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
                        .tracking(1)
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
            .background(
                panelBg
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: 4, y: 4)
            )
            .overlay(
                Path { path in
                    path.move(to: CGPoint(x: -4, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: -4))
                }
                .stroke(brutalistDark, lineWidth: 3)
                .padding(4), alignment: .bottomTrailing
            )
            .padding(24)
        }
    }
    
    // Tactile Panel Modifier
    func tactilePanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
    }
    
    // UI Accents
    func cornerBrackets(color: Color) -> some View {
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
    
    func uiAccent(alignment: Alignment) -> some View {
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
}
