import Foundation


struct TimerState {
    var clickCount: Int = 0
    var timeElapsed: Int = 0
    var isTimerRunning: Bool = false
}


enum TimerAction {
    case circleButtonTapped
    case timerToggleButtonTapped
    case timerTicked
}


struct TimerReducer {
    
    static func reduce(currentState: TimerState, action: TimerAction) -> TimerState {
        var newState = currentState
        
        switch action {
        case .circleButtonTapped:
            newState.clickCount += 1
            
        case .timerToggleButtonTapped:
            newState.isTimerRunning.toggle()
            
        case .timerTicked:
            if newState.isTimerRunning {
                newState.timeElapsed += 1
            }
        }
        
        return newState
    }
    
    
    static func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
