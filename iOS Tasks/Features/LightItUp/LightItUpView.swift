import SwiftUI
import Combine

struct LightItUpView: View {
    @Binding var currentRoute: GameRoute
    @State private var state = LightItUpState()
    var onGameFinish: (Int) -> Void
    
    @State private var showSettings: Bool = false
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            tactilePixelBackground()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                    
                        hudView()
                        
                        gridView()
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 100) /
                }
            }
            .blur(radius: (state.isGameOver || !state.isPlaying) ? 10 : 0)
            
           
            if state.showLevelUpOverlay {
                TactileBanner(
                    text: "LEVEL UP!",
                    textColor: .white,
                    backgroundColor: cautionYellow,
                    angle: 0,
                    fontSize: 42,
                    tracking: 2,
                    paddingH: 24,
                    paddingV: 12
                )
            }
            
            // Start 
            if !state.isPlaying && !state.isGameOver && !state.isPatternModeActive {
                Color.white.opacity(0.6).ignoresSafeArea() 
                startDialog()
            }
            
            
            if state.isPatternModeActive && state.isShowingPatternSequence && state.currentPatternDisplayIndex == 0 {
                TactileBanner(
                    text: "PATTERN MODE!",
                    textColor: cautionYellow,
                    backgroundColor: brutalistDark,
                    borderColor: cautionYellow,
                    angle: -5,
                    fontSize: 36
                )
            }
            
            // Pattern Result Banner
            if state.isShowingPatternResult {
                TactileBanner(
                    text: state.patternResultSuccess ? "SUCCESS!" : "FAILED!",
                    textColor: .white,
                    backgroundColor: state.patternResultSuccess ? Color.green : Color.red,
                    angle: state.patternResultSuccess ? 5 : -5,
                    fontSize: 42
                )
            }
            
            
            if state.isGameOver {
                Color.white.opacity(0.6).ignoresSafeArea() // dim background
                gameOverDialog()
            }
        }
        .overlay(topBar(), alignment: .top)
        .onReceive(timer) { _ in
            if state.isPlaying {
                state = LightItUpReducer.reduce(currentState: state, action: .timerTicked(timeStep: 0.1))
            }
            
            
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
        .sheet(isPresented: $showSettings) {
            settingsView()
        }
        .onChange(of: state.isGameOver) { _, isOver in
            if isOver {
                onGameFinish(state.score)
            }
        }
    }
    
    private func topBar() -> some View {
        HStack {
            Button(action: { currentRoute = .mainMenu }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(brutalistDark)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(TactileIconButtonStyle())
            
            Text("ARCADE")
                .font(.system(size: 20, weight: .black, design: .default))
                .italic()
                .foregroundColor(brutalistDark)
                .padding(.leading, 8)
            
            Spacer()
            
            HStack(spacing: 12) {
                Text("\(state.score) PTS")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(brutalistDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .tactileBadge()
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(brutalistDark)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(TactileIconButtonStyle())
                .disabled(state.isPlaying)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
    }
    
    private func hudView() -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
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
                
               
                VStack(alignment: .center, spacing: 8) {
                    Text("LIGHT IT UP")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(brutalistDark)
                }
                
                Spacer()
                
                
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
    
    private var gridColumns: [GridItem] {
        if state.isPatternModeActive {
            return Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
        }
        return state.currentLevel.gridColumns
    }
    
    private func gridView() -> some View {
        let cardHeight: CGFloat = state.isPatternModeActive ? 60 : 100
        
        return ZStack {
            
            tactileCornerBrackets(color: .blue)
            
            LazyVGrid(columns: gridColumns, spacing: state.isPatternModeActive ? 8 : 16) {
                ForEach(state.cards) { card in
                    Button(action: {
                        if state.isPatternModeActive {
                            state = LightItUpReducer.reduce(currentState: state, action: .patternCardTapped(id: card.id))
                        } else if state.isPlaying {
                            state = LightItUpReducer.reduce(currentState: state, action: .cardTapped(id: card.id))
                        }
                    }) {
                        ZStack {
                            if card.isSuccess {
                                Color.green
                                tactileCornerBrackets(color: .white)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                    .scaleEffect(pulseScale)
                            } else if card.isFailure {
                                Color.red
                                tactileCornerBrackets(color: .white)
                                Image(systemName: "xmark")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                    .scaleEffect(pulseScale)
                            } else if card.isLit {
                                Color(red: 13/255, green: 211/255, blue: 225/255)
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
                        .frame(height: cardHeight)
                        .border(brutalistDark, width: 2)
                        .background(card.isSuccess ? Color.green : (card.isFailure ? Color.red : (card.isLit ? Color(red: 13/255, green: 211/255, blue: 225/255) : .white)))
                        .shadow(color: card.isActive ? brutalistDark : .clear, radius: 0, x: card.isActive ? 6 : 0, y: card.isActive ? 6 : 0)
                        .offset(x: card.isActive ? -3 : 0, y: card.isActive ? -3 : 0)
                        .zIndex(card.isActive ? 1 : 0)
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
                    Text("Tap the highlighted tiles before they dim. Focus and stay fast to score points!")
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
                .buttonStyle(TactileButtonStyle())
            }
            .padding(32)
        }
        .padding(.horizontal, 24)
    }
    

    
    private func gameOverDialog() -> some View {
        TactileGameOverModal(
            score: state.score,
            gameName: "Light It Up",
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
                    .buttonStyle(TactileSegmentButtonStyle(isSelected: state.roundLength == duration))
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
    
}

#Preview {
    LightItUpView(currentRoute: .constant(.lightItUp), onGameFinish: { _ in })
}
