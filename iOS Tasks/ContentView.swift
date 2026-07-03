import SwiftUI
import Combine

struct ContentView: View {
    @State private var currentRoute: GameRoute = .mainMenu
    @State private var tapFrenzyState = TapFrenzyState()

    @StateObject private var scoreManager = ScoreManager()
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            switch currentRoute {
            case .mainMenu:
                MainMenuView(
                    currentRoute: $currentRoute,
                    onTapFrenzySelected: {
                        tapFrenzyState = TapFrenzyState()
                        currentRoute = .tapFrenzy
                    }
                )
                
            case .tapFrenzy:
                TapFrenzyView(
                    currentRoute: $currentRoute,
                    state: $tapFrenzyState,
                    onButtonTap: {
                        tapFrenzyState = TapFrenzyReducer.reduce(currentState: tapFrenzyState, action: .bigButtonTapped)
                    },
                    onGameAction: { action in
                        tapFrenzyState = TapFrenzyReducer.reduce(currentState: tapFrenzyState, action: action)
                    }
                )
                
            case .lightItUp:
                LightItUpView(
                    currentRoute: $currentRoute,
                    onGameFinish: { score in
                        scoreManager.addScore(score, for: .lightItUp)
                    }
                )
                
            case .quizRush:
                QuizRushView(
                    currentRoute: $currentRoute,
                    onGameFinish: { score in
                        scoreManager.addScore(score, for: .quizRush)
                    }
                )
                
            case .scores:
                ScoresView(currentRoute: $currentRoute)
            }
        }
        .onReceive(timer) { _ in
            if currentRoute == .tapFrenzy {
                tapFrenzyState = TapFrenzyReducer.reduce(currentState: tapFrenzyState, action: .timerTicked(timeStep: 0.1))
                if tapFrenzyState.isGameOver {
                    scoreManager.addScore(tapFrenzyState.score, for: .tapFrenzy)
                }
            }
        }
        .environmentObject(scoreManager)
    }
}

#Preview {
    ContentView()
}
