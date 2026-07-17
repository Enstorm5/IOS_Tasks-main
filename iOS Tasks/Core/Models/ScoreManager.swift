import Foundation
import Combine
import CoreLocation

struct ScoreEntry: Codable, Identifiable, Equatable {
    var id = UUID()
    let score: Int
    let date: Date
    let game: String
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Score Manager

class ScoreManager: ObservableObject {
    @Published var tapFrenzyScores: [ScoreEntry] = []
    @Published var lightItUpScores: [ScoreEntry] = []
    @Published var quizRushScores: [ScoreEntry] = []
    
    private let userDefaults = UserDefaults.standard
    private let tapFrenzyKey = "history_tapFrenzy"
    private let lightItUpKey = "history_lightItUp"
    private let quizRushKey = "history_quizRush"
    
    init() {
        loadScores()
    }
    
    func addScore(_ score: Int, for route: GameRoute, location: CLLocation? = nil) {
        // Removed guard score > 0 to allow testing with 0 score
        
        let entry = ScoreEntry(
            score: score,
            date: Date(),
            game: route.rawValue,
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude
        )
        
        switch route {
        case .tapFrenzy:
            tapFrenzyScores.append(entry)
            tapFrenzyScores.sort { $0.score > $1.score }
            if tapFrenzyScores.count > 50 { tapFrenzyScores.removeLast() }
        case .lightItUp:
            lightItUpScores.append(entry)
            lightItUpScores.sort { $0.score > $1.score }
            if lightItUpScores.count > 50 { lightItUpScores.removeLast() }
        case .quizRush:
            quizRushScores.append(entry)
            quizRushScores.sort { $0.score > $1.score }
            if quizRushScores.count > 50 { quizRushScores.removeLast() }
        default: break
        }
        
        saveScores()
    }
    
    // MARK: - Personal Bests
    
    var bestTapFrenzy: Int {
        tapFrenzyScores.first?.score ?? 0
    }
    
    var bestLightItUp: Int {
        lightItUpScores.first?.score ?? 0
    }
    
    var bestQuizRush: Int {
        quizRushScores.first?.score ?? 0
    }
    
    var totalBestScore: Int {
        bestTapFrenzy + bestLightItUp + bestQuizRush
    }
    
    // MARK: - Stats Helpers
    
    var totalGamesPlayed: Int {
        tapFrenzyScores.count + lightItUpScores.count + quizRushScores.count
    }
    
    var totalScoreAllGames: Int {
        let tapTotal = tapFrenzyScores.reduce(0) { $0 + $1.score }
        let lightTotal = lightItUpScores.reduce(0) { $0 + $1.score }
        let quizTotal = quizRushScores.reduce(0) { $0 + $1.score }
        return tapTotal + lightTotal + quizTotal
    }
    
    func averageScore(for route: GameRoute) -> Int {
        let scores = scoresFor(route)
        guard !scores.isEmpty else { return 0 }
        let total = scores.reduce(0) { $0 + $1.score }
        return total / scores.count
    }
    
    func scoresFor(_ route: GameRoute) -> [ScoreEntry] {
        switch route {
        case .tapFrenzy: return tapFrenzyScores
        case .lightItUp: return lightItUpScores
        case .quizRush: return quizRushScores
        default: return []
        }
    }
    
    /// All scores combined, sorted by date (newest first)
    var recentGames: [ScoreEntry] {
        let all = tapFrenzyScores + lightItUpScores + quizRushScores
        return all.sorted { $0.date > $1.date }
    }
    
    /// All scores that have valid coordinates
    var scoredLocations: [ScoreEntry] {
        let all = tapFrenzyScores + lightItUpScores + quizRushScores
        return all.filter { $0.latitude != nil && $0.longitude != nil }
    }
    
    // MARK: - Persistence
    
    private func saveScores() {
        if let encoded = try? JSONEncoder().encode(tapFrenzyScores) {
            userDefaults.set(encoded, forKey: tapFrenzyKey)
        }
        if let encoded = try? JSONEncoder().encode(lightItUpScores) {
            userDefaults.set(encoded, forKey: lightItUpKey)
        }
        if let encoded = try? JSONEncoder().encode(quizRushScores) {
            userDefaults.set(encoded, forKey: quizRushKey)
        }
    }
    
    private func loadScores() {
        if let data = userDefaults.data(forKey: tapFrenzyKey),
           let decoded = try? JSONDecoder().decode([ScoreEntry].self, from: data) {
            tapFrenzyScores = decoded
        }
        
        if let data = userDefaults.data(forKey: lightItUpKey),
           let decoded = try? JSONDecoder().decode([ScoreEntry].self, from: data) {
            lightItUpScores = decoded
        }
        
        if let data = userDefaults.data(forKey: quizRushKey),
           let decoded = try? JSONDecoder().decode([ScoreEntry].self, from: data) {
            quizRushScores = decoded
        }
    }
}
