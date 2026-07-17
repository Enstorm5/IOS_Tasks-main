import SwiftUI
import Combine

// MARK: - View

struct LightItUpView: View {
    @Binding var currentRoute: GameRoute
    @State private var state = LightItUpState()
    var onGameFinish: (Int) -> Void
    
    @State private var showSettings: Bool = false
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    // Animation for lit tiles
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            tactilePixelBackground()
            
            VStack(spacing: 0) {
                // Top Bar
                topBar()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Technical HUD
                        hudView()
                        
                        // Matrix Grid
                        gridView()
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 32)
                }
            }
            .blur(radius: (state.isGameOver || !state.isPlaying) ? 10 : 0)
            
            // Level Up Text
            if state.showLevelUpOverlay {
                Text("LEVEL UP!")
                    .font(.system(size: 42, weight: .black, design: .default))
                    .tracking(2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        cautionYellow
                            .border(brutalistDark, width: 4)
                            .shadow(color: brutalistDark, radius: 0, x: 6, y: 6)
                    )
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Start / Welcome Dialog
            if !state.isPlaying && !state.isGameOver {
                Color.white.opacity(0.6).ignoresSafeArea() // dim background
                startDialog()
            }
            
            // Game Over Dialog
            if state.isGameOver {
                Color.white.opacity(0.6).ignoresSafeArea() // dim background
                gameOverDialog()
            }
        }
        .onReceive(timer) { _ in
            if state.isPlaying {
                state = LightItUpReducer.reduce(currentState: state, action: .timerTicked(timeStep: 0.1))
                if state.isGameOver {
                    onGameFinish(state.score)
                }
            }
            
            // Subtle pulse for active elements
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
        .sheet(isPresented: $showSettings) {
            settingsView()
        }
    }
    
    // MARK: - Subviews
    
    private func topBar() -> some View {
        HStack {
            Button(action: { currentRoute = .mainMenu }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(brutalistDark)
                    .frame(width: 44, height: 44)
            }
            .background(
                Color.white
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
            )
            
            Text("LEVEL \(state.currentLevel.rawValue)")
                .font(.system(size: 20, weight: .black, design: .default))
                .italic()
                .foregroundColor(brutalistDark)
                .padding(.leading, 12)
            
            Spacer()
            
            Button(action: { showSettings = true }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(brutalistDark)
                    .frame(width: 44, height: 44)
            }
            .background(
                (state.isPlaying ? Color.gray.opacity(0.2) : Color.white)
                    .border(brutalistDark, width: 2)
                    .shadow(color: state.isPlaying ? .clear : brutalistDark, radius: 0, x: 2, y: 2)
            )
            .disabled(state.isPlaying)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
    }
    
    private func hudView() -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                // Score
                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENT SCORE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.gray)
                        .tracking(1)
                    
                    Text(String(format: "%05d", state.score))
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundColor(brutalistDark)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            panelBg
                                .border(brutalistDark, width: 2)
                                .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
                        )
                }
                
                Spacer()
                
                // Title & Lives
                VStack(alignment: .center, spacing: 8) {
                    Text("LIGHT IT UP")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(brutalistDark)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<3) { idx in
                            Rectangle()
                                .fill(idx < state.lives ? Color.red : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                                .border(brutalistDark, width: 1.5)
                        }
                    }
                    
                    Text("LIVES")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color.gray)
                        .tracking(1)
                }
                
                Spacer()
                
                // Time
                VStack(alignment: .trailing, spacing: 4) {
                    Text("TIME LEFT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.gray)
                        .tracking(1)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(String(format: "%.1f", max(0, state.roundLength - state.totalTimeElapsed)))
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundColor(.red)
                        Text("S")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        panelBg
                            .border(brutalistDark, width: 2)
                            .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
                    )
                }
            }
        }
        .padding(20)
        .background(
            Color.white
                .border(brutalistDark, width: 2)
                .shadow(color: brutalistDark, radius: 0, x: 4, y: 4)
        )
        .padding(.horizontal, 20)
    }
    
    private func gridView() -> some View {
        ZStack {
            // Structural Accents (Corner brackets) for the grid container
            tactileCornerBrackets(color: .blue)
            
            LazyVGrid(columns: state.currentLevel.gridColumns, spacing: 16) {
                ForEach(state.cards) { card in
                    Button(action: {
                        if state.isPlaying {
                            state = LightItUpReducer.reduce(currentState: state, action: .cardTapped(id: card.id))
                        }
                    }) {
                        ZStack {
                            if card.isLit {
                                Color(red: 13/255, green: 211/255, blue: 225/255) // Cyan Accent
                                tactileCornerBrackets(color: .white)
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                    .scaleEffect(pulseScale)
                            } else {
                                Color.white
                                Text(String(format: "%03d", card.id))
                                    .font(.system(size: 14, weight: .black, design: .monospaced))
                                    .foregroundColor(Color(red: 226/255, green: 232/255, blue: 240/255))
                            }
                        }
                        .frame(height: 100)
                        .border(brutalistDark, width: 2)
                        .background(card.isLit ? Color(red: 13/255, green: 211/255, blue: 225/255) : .white)
                        .shadow(color: card.isLit ? brutalistDark : .clear, radius: 0, x: card.isLit ? 6 : 0, y: card.isLit ? 6 : 0)
                        .offset(x: card.isLit ? -3 : 0, y: card.isLit ? -3 : 0)
                        .zIndex(card.isLit ? 1 : 0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(24)
            .background(
                panelBg
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: 8, y: 8)
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    private func startDialog() -> some View {
        TactileCard {
            VStack(spacing: 24) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 50))
                    .foregroundColor(cautionYellow)
                
                VStack(spacing: 8) {
                    Text("LIGHT IT UP")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(brutalistDark)
                    Text("Tap the highlighted tiles before they dim. Focus and stay fast—you only have 3 lives!")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                Button(action: { state = LightItUpReducer.reduce(currentState: state, action: .startGame) }) {
                    Text("START CHALLENGE")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(brutalistDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .background(
                    cautionYellow
                        .border(brutalistDark, width: 2)
                        .shadow(color: brutalistDark, radius: 0, x: 4, y: 4)
                )
            }
            .padding(32)
        }
        .padding(.horizontal, 24)
    }
    
    private func gameOverDialog() -> some View {
        TactileGameOverModal(
            score: state.score,
            onMenu: { currentRoute = .mainMenu },
            onPlayAgain: { state = LightItUpReducer.reduce(currentState: state, action: .startGame) }
        )
    }
    
    private func settingsView() -> some View {
        VStack(spacing: 24) {
            Text("ROUND DURATION")
                .font(.system(size: 20, weight: .black))
                .foregroundColor(brutalistDark)
            
            HStack(spacing: 16) {
                ForEach([30.0, 60.0, 90.0], id: \.self) { duration in
                    Button(action: { state = LightItUpReducer.reduce(currentState: state, action: .changeRoundLength(duration)) }) {
                        Text("\(Int(duration))s")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(state.roundLength == duration ? brutalistDark : Color.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .background(
                        (state.roundLength == duration ? cautionYellow : Color.white)
                            .border(brutalistDark, width: 2)
                            .shadow(color: state.roundLength == duration ? brutalistDark : .clear, radius: 0, x: 3, y: 3)
                    )
                }
            }
            
            Button("DISMISS") { showSettings = false }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.gray)
                .padding(.top, 10)
        }
        .padding(24)
        .presentationDetents([.fraction(0.3)])
    }
    
    // Tactile Card Modifier moved to TactileUI.swift
}

// MARK: - Preview Engine
#Preview {
    LightItUpView(currentRoute: .constant(.lightItUp), onGameFinish: { _ in })
}
