import SwiftUI

struct TapFrenzyView: View {
    @Binding var currentRoute: GameRoute
    @Binding var state: TapFrenzyState
    let onButtonTap: () -> Void
    let onGameAction: (TapFrenzyAction) -> Void
    
    @State private var scanlineOffset: CGFloat = -200
    @State private var pulse: Bool = false
    
    var body: some View {
        ZStack {
            tactilePixelBackground()
            
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
                .font(.system(size: 16, weight: .black))
                .foregroundColor(brutalistDark)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    cautionYellow
                        .border(brutalistDark, width: 2)
                        .shadow(color: brutalistDark, radius: 0, x: 3, y: 3)
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
                                    .overlay(tactileCornerBrackets(color: cautionYellow))
                                    .padding(.top, 16)
                            }
                        }
                    }
                    .frame(width: 256, height: 256)
                .background(
                    (state.currentButtonColor == .green ? Color.green.opacity(0.2) : panelBg)
                        .border(brutalistDark, width: 2)
                        .shadow(color: brutalistDark, radius: 0, x: 4, y: 4)
                )
                .overlay(tactileUIAccent(alignment: .topLeading))
                .overlay(tactileUIAccent(alignment: .bottomTrailing))
            }
            .buttonStyle(PlainButtonStyle())

        }
    }
    
    // Start / Game Over Modal
    func startGameOverModal() -> some View {
        ZStack {
            Color(red: 226/255, green: 232/255, blue: 240/255).opacity(0.6) // surface-dim
                .ignoresSafeArea()
            
            if state.isGameOver {
                TactileGameOverModal(
                    score: state.score,
                    gameName: "Tap Frenzy",
                    onMenu: { currentRoute = .mainMenu },
                    onPlayAgain: { onGameAction(.startOrRestartGame) }
                )
            } else {
                TactileCard {
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
                                    tactileTitleAccent()
                                    
                                    Text("TAP ")
                                        .font(.system(size: 40, weight: .black))
                                        .italic()
                                        .foregroundColor(brutalistDark)
                                    + Text("FRENZY")
                                        .font(.system(size: 40, weight: .black))
                                        .italic()
                                        .foregroundColor(Color(red: 202/255, green: 138/255, blue: 4/255)) // tertiary #ca8a04
                                }
                                
                                Rectangle().fill(brutalistDark).frame(width: 48, height: 3)
                            }
                            
                            // Body
                            Text("Tap as fast as you can inside ")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
                            + Text("10 seconds")
                                .font(.system(size: 17, weight: .black))
                                .foregroundColor(brutalistDark)
                            + Text(". Avoid penalty traps!")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
                            
                            // Action Buttons
                            VStack(spacing: 16) {
                                Button(action: { onGameAction(.startOrRestartGame) }) {
                                    HStack(spacing: 12) {
                                        Text("START GAME")
                                            .font(.system(size: 22, weight: .black))
                                            .italic()
                                            .tracking(-1)
                                        
                                        Image(systemName: "play.fill")
                                    }
                                    .foregroundColor(brutalistDark)
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(TactileButtonStyle())
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                    }
                }
                .padding(24)
            }
        }
    }
}
