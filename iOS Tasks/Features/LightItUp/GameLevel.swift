import SwiftUI

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
