import Foundation
import SwiftUI

// MARK: - State

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

// MARK: - Actions

enum LightItUpAction {
    case startGame
    case cardTapped(id: Int)
    case timerTicked(timeStep: Double)
    case changeRoundLength(Double)
}

// MARK: - Reducer

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
