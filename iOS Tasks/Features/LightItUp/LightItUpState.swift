import Foundation
import SwiftUI

struct LightItUpState {
    var score: Int = 0
    var totalTimeElapsed: Double = 0.0
    var roundLength: Double = 60.0
    var isPlaying: Bool = false
    var isGameOver: Bool = false
    var currentLevel: GameLevel = .L1
    
    var cards: [GameCard] = [
        GameCard(id: 0, isLit: false),
        GameCard(id: 1, isLit: true),
        GameCard(id: 2, isLit: false)
    ]
    
    var windowTimeTracker: Double = 0.0
    var showLevelUpOverlay: Bool = false
    var levelUpOverlayTracker: Double = 0.0
    
    // Pattern Mode
    var hasPatternModeTriggered: Bool = false
    var isPatternModeActive: Bool = false
    var prePatternCards: [GameCard] = []
    var prePatternLevel: GameLevel = .L1
    var patternModeCooldownTracker: Double = 0.0
    var patternSequence: [Int] = []
    var userPatternTaps: [Int] = []
    var isShowingPatternSequence: Bool = false
    var isShowingPatternResult: Bool = false
    var patternResultSuccess: Bool = false
    var currentPatternDisplayIndex: Int = 0
    var patternDisplayTimer: Double = 0.0
}

enum LightItUpAction {
    case startGame
    case cardTapped(id: Int)
    case timerTicked(timeStep: Double)
    case changeRoundLength(Double)
    case patternCardTapped(id: Int)
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
            newState.currentLevel = .L1
            newState.isPlaying = true
            newState.isGameOver = false
            newState.windowTimeTracker = 0.0
            newState.showLevelUpOverlay = false
            newState.hasPatternModeTriggered = false
            newState.isPatternModeActive = false
            newState.patternModeCooldownTracker = 0.0
            newState.patternSequence = []
            newState.userPatternTaps = []
            newState.isShowingPatternSequence = false
            newState.isShowingPatternResult = false
            newState.patternResultSuccess = false
            newState.currentPatternDisplayIndex = 0
            
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

                    newState.score = max(0, newState.score - 1)
                }
            }
            

        case .patternCardTapped(let clickedId):
            guard newState.isPatternModeActive && !newState.isShowingPatternSequence && !newState.isShowingPatternResult else { return newState }
            
            newState.userPatternTaps.append(clickedId)
            let tapIndex = newState.userPatternTaps.count - 1
            
            if newState.patternSequence[tapIndex] == clickedId {
            
                if let idx = newState.cards.firstIndex(where: { $0.id == clickedId }) {
                    newState.cards[idx].isSuccess = true
                }
                
                if newState.userPatternTaps.count == newState.patternSequence.count {
                    newState.score += 20
                    newState.isShowingPatternResult = true
                    newState.patternResultSuccess = true
                    newState.patternDisplayTimer = 0.0
                }
            } else {
                
                if let idx = newState.cards.firstIndex(where: { $0.id == clickedId }) {
                    newState.cards[idx].isFailure = true
                }
                newState.score = max(0, newState.score - 10)
                newState.isShowingPatternResult = true
                newState.patternResultSuccess = false
                newState.patternDisplayTimer = 0.0
            }
            
        case .timerTicked(let timeStep):
            guard (newState.isPlaying || newState.isShowingPatternSequence || newState.isShowingPatternResult) && !newState.isGameOver else { return newState }
            
            if newState.isShowingPatternResult {
                newState.patternDisplayTimer += timeStep
                if newState.patternDisplayTimer >= 1.5 { // Wait 1.5s so user can see result
                    newState.isShowingPatternResult = false
                    newState.isPatternModeActive = false
                    newState.cards = newState.prePatternCards
                    newState.currentLevel = newState.prePatternLevel
                    newState.windowTimeTracker = 0.0
                }
                return newState
            }
            
            if newState.isShowingPatternSequence {
                newState.patternDisplayTimer += timeStep
                
                // Turn off the card halfway t
                if newState.patternDisplayTimer >= 0.4 && newState.patternDisplayTimer < 0.5 {
                    for i in 0..<newState.cards.count {
                        newState.cards[i].isLit = false
                    }
                }
                
               
                if newState.patternDisplayTimer >= 0.8 {
                    newState.patternDisplayTimer = 0.0
                    
                    if newState.currentPatternDisplayIndex < newState.patternSequence.count {
                        let cardToLight = newState.patternSequence[newState.currentPatternDisplayIndex]
                        newState.cards[cardToLight].isLit = true
                        newState.currentPatternDisplayIndex += 1
                    } else {
                        newState.isShowingPatternSequence = false
                    }
                }
                return newState
            }
            
            if newState.isPatternModeActive {
                return newState
            }
            
            newState.totalTimeElapsed += timeStep
            newState.windowTimeTracker += timeStep
            newState.patternModeCooldownTracker += timeStep
            
            // Randomly trigger mid-game 
            if !newState.hasPatternModeTriggered && !newState.isPatternModeActive && !newState.isShowingPatternSequence && newState.patternModeCooldownTracker > 10.0 {
                if Double.random(in: 0...1) < 0.05 { 
                    newState.hasPatternModeTriggered = true
                    newState.prePatternCards = newState.cards
                    newState.prePatternLevel = newState.currentLevel
                    newState.isPatternModeActive = true
                    newState.cards = (0..<16).map { GameCard(id: $0, isLit: false) }
                    newState.patternSequence = (0..<4).map { _ in Int.random(in: 0..<16) }
                    newState.userPatternTaps = []
                    newState.isShowingPatternSequence = true
                    newState.currentPatternDisplayIndex = 0
                    newState.patternDisplayTimer = 0.0
                    newState.patternModeCooldownTracker = 0.0
                    return newState
                }
            }
            
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
                newState = shuffleLitCards(state: newState)
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
