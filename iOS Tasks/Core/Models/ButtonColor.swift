import SwiftUI

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
