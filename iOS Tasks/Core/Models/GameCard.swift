import Foundation

struct GameCard: Identifiable, Equatable {
    let id: Int
    var isLit: Bool = false
    var isSuccess: Bool = false
    var isFailure: Bool = false
    
    var isActive: Bool {
        return isLit || isSuccess || isFailure
    }
}
