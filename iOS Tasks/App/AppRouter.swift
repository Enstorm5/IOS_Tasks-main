import Foundation

enum GameRoute: String, Hashable {
    case mainMenu
    case tapFrenzy
    case lightItUp
    case quizRush
    case scores
    
    /// Full display name (e.g. "TAP FRENZY")
    var displayName: String {
        switch self {
        case .tapFrenzy: return "TAP FRENZY"
        case .lightItUp: return "LIGHT IT UP"
        case .quizRush: return "QUIZ RUSH"
        default: return rawValue.uppercased()
        }
    }
    
    /// Short label (e.g. "TAP")
    var shortName: String {
        switch self {
        case .tapFrenzy: return "TAP"
        case .lightItUp: return "LIGHT"
        case .quizRush: return "QUIZ"
        default: return rawValue.uppercased()
        }
    }
    
    /// Convert rawValue string back to a GameRoute for label lookups
    static func fromRawValue(_ raw: String) -> GameRoute? {
        GameRoute(rawValue: raw)
    }
}

/// Shared date formatter for score displays
let sharedDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .short
    f.timeStyle = .short
    return f
}()
