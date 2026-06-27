import Foundation
import SwiftUI

enum GameRoute {
    case mainMenu
    case tapFrenzy
    case lightItUp
}

struct CardContainer<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            content
                .padding(30)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(24)
                .shadow(radius: 20)
                .padding(.horizontal, 40)
        }
    }
}

enum ButtonColor: CaseIterable {
    case green
    case grey
    case normal
    
    var displayColor: Color {
        switch self {
        case .green: return .green
        case .grey: return .gray
        case .normal: return .red
        }
    }
}

struct TimerState {
    var score: Int = 0
    var timeRemaining: Double = 10.0
    var isPlaying: Bool = false
    var isGameOver: Bool = false
    
    // Combo System
    var comboMultiplier: Int = 1
    var lastTapTime: Date? = nil
    
    // Trap Color System
    var currentButtonColor: ButtonColor = .normal
    var colorChangeTicks: Int = 0
}

//Actions
enum TimerAction {
    case bigButtonTapped
    case startOrRestartGame
    case timerTicked(timeStep: Double)
}
struct TimerReducer {
    
    static func reduce(currentState: TimerState, action: TimerAction) -> TimerState {
        var newState = currentState
        
        switch action {
        case .startOrRestartGame:
            newState.score = 0
            newState.timeRemaining = 10.0
            newState.isPlaying = true
            newState.isGameOver = false
            newState.comboMultiplier = 1
            newState.lastTapTime = nil
            newState.currentButtonColor = .normal
            newState.colorChangeTicks = 0
            
        case .bigButtonTapped:
            guard newState.isPlaying && !newState.isGameOver else { return newState }
            
            let now = Date()
            
           
            if let lastTap = newState.lastTapTime {
                let timeSinceLastTap = now.timeIntervalSince(lastTap)
                if timeSinceLastTap <= 0.5 {
                    newState.comboMultiplier += 1
                } else {
                    newState.comboMultiplier = 1
                }
            } else {
                newState.comboMultiplier = 1
            }
            newState.lastTapTime = now
            
            
            switch newState.currentButtonColor {
            case .green:
            
                newState.score += (1 * newState.comboMultiplier) * 2
            case .grey:
                
                newState.score = max(0, newState.score - 2)
                newState.comboMultiplier = 1
            case .normal:
                
                newState.score += (1 * newState.comboMultiplier)
            }
            
        case .timerTicked(let timeStep):
            guard newState.isPlaying && !newState.isGameOver else { return newState }
            
            
            newState.timeRemaining = max(0, newState.timeRemaining - timeStep)
            
            if newState.timeRemaining <= 0 {
                newState.isPlaying = false
                newState.isGameOver = true
                return newState
            }
            
            
            if let lastTap = newState.lastTapTime, Date().timeIntervalSince(lastTap) > 0.5 {
                newState.comboMultiplier = 1
            }
            
            
            newState.colorChangeTicks += 1
            if newState.colorChangeTicks >= 20 {
                newState.colorChangeTicks = 0
                newState.currentButtonColor = ButtonColor.allCases.randomElement() ?? .normal
            }
        }
        
        return newState
    }
}
