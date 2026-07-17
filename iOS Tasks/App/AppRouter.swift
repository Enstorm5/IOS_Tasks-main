import Foundation

enum GameRoute: String, Hashable {
    case mainMenu
    case tapFrenzy
    case lightItUp
    case quizRush
    case scores
    
    var displayName: String {
        switch self {
        case .tapFrenzy: return "TAP FRENZY"
        case .lightItUp: return "LIGHT IT UP"
        case .quizRush: return "QUIZ RUSH"
        default: return rawValue.uppercased()
        }
    }
    
    var shortName: String {
        switch self {
        case .tapFrenzy: return "TAP"
        case .lightItUp: return "LIGHT"
        case .quizRush: return "QUIZ"
        default: return rawValue.uppercased()
        }
    }
    
    static func fromRawValue(_ raw: String) -> GameRoute? {
        GameRoute(rawValue: raw)
    }
}

/// Shared date formatter 
let sharedDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .short
    f.timeStyle = .short
    return f
}()
