import SwiftUI
import Combine

// MARK: - Game Setup Config
enum GameLevel: Int, CaseIterable {
    case L1 = 1, L2, L3, L4
    
    var totalCards: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }
    
    var litDuration: Double {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }
    
    var glowColor: Color {
        switch self {
        case .L1: return .yellow
        case .L2: return .orange
        case .L3: return .cyan
        case .L4: return .purple
        }
    }
    
    var gridColumns: [GridItem] {
        switch self {
        case .L1: return Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)
        case .L2: return Array(repeating: GridItem(.flexible(), spacing: 14), count: 2)
        case .L3: return Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)
        case .L4: return Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)
        }
    }
}

struct GameCard: Identifiable, Equatable {
    let id: Int
    var isLit: Bool = false
}

struct LightItUpState {
    var score: Int = 0
    var totalTimeElapsed: Double = 0.0
    var roundLength: Double = 60.0
    var isPlaying: Bool = false
    var isGameOver: Bool = false
    var lives: Int = 3
    var currentLevel: GameLevel = .L1
    
    var cards: [GameCard] = [
        GameCard(id: 0, isLit: false),
        GameCard(id: 1, isLit: true),
        GameCard(id: 2, isLit: false)
    ]
    
    var windowTimeTracker: Double = 0.0
    var showLevelUpOverlay: Bool = false
    var levelUpOverlayTracker: Double = 0.0
}

enum LightItUpAction {
    case startGame
    case cardTapped(id: Int)
    case timerTicked(timeStep: Double)
    case changeRoundLength(Double)
}

struct LightItUpReducer {
    static func reduce(currentState: LightItUpState, action: LightItUpAction) -> LightItUpState {
        var newState = currentState
        
        switch action {
        case .changeRoundLength(let length):
            newState.roundLength = length
            
        case .startGame:
            newState.score = 0
            newState.totalTimeElapsed = 0.0
            newState.lives = 3
            newState.currentLevel = .L1
            newState.isPlaying = true
            newState.isGameOver = false
            newState.windowTimeTracker = 0.0
            newState.showLevelUpOverlay = false
            
            newState.cards = (0..<GameLevel.L1.totalCards).map { GameCard(id: $0, isLit: false) }
            if let randomIdx = newState.cards.indices.randomElement() {
                newState.cards[randomIdx].isLit = true
            }
            
        case .cardTapped(let clickedId):
            guard newState.isPlaying && !newState.isGameOver else { return newState }
            
            if let index = newState.cards.firstIndex(where: { $0.id == clickedId }) {
                if newState.cards[index].isLit {
                    newState.score += 1
                    newState.windowTimeTracker = 0.0
                    newState = shuffleLitCards(state: newState)
                } else {
                    newState.lives = max(0, newState.lives - 1)
                    if newState.lives <= 0 {
                        newState.isPlaying = false
                        newState.isGameOver = true
                    }
                }
            }
            
        case .timerTicked(let timeStep):
            guard newState.isPlaying && !newState.isGameOver else { return newState }
            
            newState.totalTimeElapsed += timeStep
            newState.windowTimeTracker += timeStep
            
            if newState.showLevelUpOverlay {
                newState.levelUpOverlayTracker += timeStep
                if newState.levelUpOverlayTracker >= 1.0 {
                    newState.showLevelUpOverlay = false
                }
            }
            
            if newState.totalTimeElapsed >= newState.roundLength {
                newState.isPlaying = false
                newState.isGameOver = true
                return newState
            }
            
            let targetLevel: GameLevel
            if newState.totalTimeElapsed < 15.0 { targetLevel = .L1 }
            else if newState.totalTimeElapsed < 30.0 { targetLevel = .L2 }
            else if newState.totalTimeElapsed < 45.0 { targetLevel = .L3 }
            else { targetLevel = .L4 }
            
            if targetLevel != newState.currentLevel {
                newState.currentLevel = targetLevel
                newState.showLevelUpOverlay = true
                newState.levelUpOverlayTracker = 0.0
                
                newState.cards = (0..<targetLevel.totalCards).map { GameCard(id: $0, isLit: false) }
                newState.windowTimeTracker = 0.0
                newState = shuffleLitCards(state: newState)
                return newState
            }
            
            if newState.windowTimeTracker >= newState.currentLevel.litDuration {
                newState.windowTimeTracker = 0.0
                newState.lives = max(0, newState.lives - 1)
                
                if newState.lives <= 0 {
                    newState.isPlaying = false
                    newState.isGameOver = true
                } else {
                    newState = shuffleLitCards(state: newState)
                }
            }
        }
        return newState
    }
    
    private static func shuffleLitCards(state: LightItUpState) -> LightItUpState {
        var stateCopy = state
        for i in 0..<stateCopy.cards.count { stateCopy.cards[i].isLit = false }
        
        let countToLight = stateCopy.currentLevel == .L4 ? 2 : 1
        let shuffledIndices = stateCopy.cards.indices.shuffled()
        
        for index in 0..<min(countToLight, shuffledIndices.count) {
            stateCopy.cards[shuffledIndices[index]].isLit = true
        }
        return stateCopy
    }
}

// MARK: - View Component
struct LightItUpView: View {
    @Binding var currentRoute: GameRoute
    @State private var state = LightItUpState()
    @Binding var highscoreTracker: Int
    
    @State private var showSettings: Bool = false
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Modern Canvas Architecture
            Color(red: 0.04, green: 0.05, blue: 0.08)
                .ignoresSafeArea()
            
            // Soft background glow mapping to current difficulty
            Circle()
                .fill(state.currentLevel.glowColor.opacity(0.08))
                .frame(width: 320, height: 320)
                .blur(radius: 65)
                .offset(y: 40)
            
            VStack(spacing: 24) {
                // Top Header Controls
                HStack {
                    Button(action: { currentRoute = .mainMenu }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Menu")
                        }
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("LEVEL \(state.currentLevel.rawValue)")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.black)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(state.currentLevel.glowColor.opacity(0.12))
                        .foregroundColor(state.currentLevel.glowColor)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .disabled(state.isPlaying)
                    .opacity(state.isPlaying ? 0.3 : 1.0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // Translucent Values Status Panel
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SCORE").font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)
                        Text("\(state.score)").font(.system(.title2, design: .rounded)).bold().foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("TIME LEFT").font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)
                        Text(String(format: "%.1fs", max(0, state.roundLength - state.totalTimeElapsed)))
                            .font(.system(.title2, design: .monospaced)).bold().foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("LIVES").font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)
                        HStack(spacing: 5) {
                            ForEach(0..<3) { idx in
                                Circle()
                                    .fill(idx < state.lives ? Color.red : Color.gray.opacity(0.3))
                                    .frame(width: 10, height: 10)
                                    .shadow(color: idx < state.lives ? .red.opacity(0.5) : .clear, radius: 4)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.all, 20)
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Matrix Grid Frame
                VStack {
                    LazyVGrid(columns: state.currentLevel.gridColumns, spacing: 14) {
                        ForEach(state.cards) { card in
                            Button(action: {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                    state = LightItUpReducer.reduce(currentState: state, action: .cardTapped(id: card.id))
                                }
                            }) {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(card.isLit ? state.currentLevel.glowColor : Color(red: 0.1, green: 0.12, blue: 0.18))
                                    .frame(height: 105)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(card.isLit ? .white.opacity(0.2) : .white.opacity(0.04), lineWidth: 1)
                                    )
                                    .shadow(color: card.isLit ? state.currentLevel.glowColor.opacity(0.5) : .clear, radius: 14, x: 0, y: 4)
                                    .scaleEffect(card.isLit ? 1.02 : 1.0)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(18)
                }
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1.5)
                        .background(Color(red: 0.06, green: 0.08, blue: 0.12).opacity(0.8))
                )
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .blur(radius: (state.isGameOver || !state.isPlaying) ? 10 : 0)
            
            // Level Up HUD Toast Alert
            if state.showLevelUpOverlay {
                Text("LEVEL UP!")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundColor(state.currentLevel.glowColor)
                    .shadow(color: state.currentLevel.glowColor.opacity(0.4), radius: 10)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Initial Welcome Portal Layout
            if !state.isPlaying && !state.isGameOver {
                GameOverlayCard {
                    VStack(spacing: 24) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.4), radius: 10)
                        
                        VStack(spacing: 8) {
                            Text("LIGHT IT UP")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.black)
                            Text("Tap the highlighted tiles before they dim. Focus and stay fast—you only have 3 lives!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        
                        Button(action: { state = LightItUpReducer.reduce(currentState: state, action: .startGame) }) {
                            Text("START CHALLENGE")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.all, 16)
                                .background(LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: .purple.opacity(0.3), radius: 10, y: 4)
                        }
                    }
                }
            }
            
            // Game Over Score Card Dialog
            if state.isGameOver {
                GameOverlayCard {
                    VStack(spacing: 24) {
                        Text("ROUND OVER")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.red)
                        
                        VStack(spacing: 4) {
                            Text("\(state.score)")
                                .font(.system(size: 64, weight: .black, design: .rounded))
                                .foregroundColor(.primary)
                            Text("Final Score")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: { currentRoute = .mainMenu }) {
                                Text("MENU")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.all, 14)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button(action: { state = LightItUpReducer.reduce(currentState: state, action: .startGame) }) {
                                Text("PLAY AGAIN")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.all, 14)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .green.opacity(0.3), radius: 8, y: 4)
                            }
                        }
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if state.isPlaying {
                state = LightItUpReducer.reduce(currentState: state, action: .timerTicked(timeStep: 0.1))
                if state.isGameOver && state.score > highscoreTracker {
                    highscoreTracker = state.score
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            VStack(spacing: 25) {
                Text("Select Round Duration")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                
                HStack(spacing: 14) {
                    ForEach([30.0, 60.0, 90.0], id: \.self) { duration in
                        Button(action: { state = LightItUpReducer.reduce(currentState: state, action: .changeRoundLength(duration)) }) {
                            Text("\(Int(duration))s")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(state.roundLength == duration ? Color.purple : Color.white.opacity(0.06))
                                .foregroundColor(state.roundLength == duration ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                
                Button("Dismiss") { showSettings = false }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
            }
            .presentationDetents([.fraction(0.28)])
            .padding(.all, 24)
        }
    }
}

// MARK: - STRUCT SUBVIEW: GameOverlayCard
struct GameOverlayCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
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

// MARK: - Preview Engine
#Preview {
    LightItUpView(currentRoute: .constant(.lightItUp), highscoreTracker: .constant(10))
}
