import Foundation
import SwiftUI



enum TapSide: Equatable {
    case center, left, right
}

struct TapFrenzyState {
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
    
    // Split Mode System
    var isSplitModeActive: Bool = false
    var correctSplitSide: TapSide = .center
    var splitModeTicksRemaining: Int = 0
    
    // Golden Tile System
    var isGoldenTileActive: Bool = false
    var goldenTileTicksRemaining: Int = 0
    var goldenTileOffset: CGSize = .zero
}



enum TapFrenzyAction {
    case targetTapped(side: TapSide)
    case goldenTileTapped
    case startOrRestartGame
    case timerTicked(timeStep: Double)
}



struct TapFrenzyReducer {
    
    static func reduce(currentState: TapFrenzyState, action: TapFrenzyAction) -> TapFrenzyState {
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
            newState.isSplitModeActive = false
            newState.splitModeTicksRemaining = 0
            newState.isGoldenTileActive = false
            newState.goldenTileTicksRemaining = 0
            
        case .targetTapped(let side):
            guard newState.isPlaying && !newState.isGameOver else { return newState }
            
            var isPenaltyHit = false
            if newState.isSplitModeActive {
                if side != newState.correctSplitSide {
                    isPenaltyHit = true
                }
                // Always end split mode after any tap
                newState.isSplitModeActive = false
                newState.splitModeTicksRemaining = 0
            }
            
            let now = Date()
            
            if let lastTap = newState.lastTapTime {
                let timeSinceLastTap = now.timeIntervalSince(lastTap)
                if timeSinceLastTap <= 0.5 && !isPenaltyHit {
                    newState.comboMultiplier += 1
                } else {
                    newState.comboMultiplier = 1
                }
            } else {
                newState.comboMultiplier = 1
            }
            newState.lastTapTime = now
            
            let effectiveColor = isPenaltyHit ? .grey : newState.currentButtonColor
            
            switch effectiveColor {
            case .green:
                newState.score += (1 * newState.comboMultiplier) * 2
            case .grey:
                newState.score = max(0, newState.score - 2)
                newState.comboMultiplier = 1
            case .normal:
                newState.score += (1 * newState.comboMultiplier)
            }
            
        case .goldenTileTapped:
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
            
            if newState.isGoldenTileActive {
                newState.timeRemaining += 1.5
                newState.score += (1 * newState.comboMultiplier)
                newState.isGoldenTileActive = false
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
            
            if newState.colorChangeTicks >= 10 {
                newState.colorChangeTicks = 0
                newState.currentButtonColor = ButtonColor.allCases.randomElement() ?? .normal
                
                if !newState.isSplitModeActive && (newState.currentButtonColor == .normal || newState.currentButtonColor == .green) {
                    if Int.random(in: 1...100) <= 15 {
                        newState.isSplitModeActive = true
                        newState.correctSplitSide = Bool.random() ? .left : .right
                        newState.splitModeTicksRemaining = 20
                    }
                }
                
                if !newState.isGoldenTileActive {
                    if Int.random(in: 1...100) <= 30 {
                        newState.isGoldenTileActive = true
                        newState.goldenTileTicksRemaining = 15 // 1.5 seconds
                        // Spawn safely above or below the 256x256 main square
                        let randomX = CGFloat.random(in: -120...120)
                        let randomY = Bool.random() ? CGFloat.random(in: 180...220) : CGFloat.random(in: -220...(-180))
                        newState.goldenTileOffset = CGSize(width: randomX, height: randomY)
                    }
                }
            }
            
            if newState.isSplitModeActive {
                newState.splitModeTicksRemaining -= 1
                if newState.splitModeTicksRemaining <= 0 {
                    newState.isSplitModeActive = false
                }
            }
            
            if newState.isGoldenTileActive {
                newState.goldenTileTicksRemaining -= 1
                if newState.goldenTileTicksRemaining <= 0 {
                    newState.isGoldenTileActive = false
                }
            }
        }
        
        return newState
    }
}
