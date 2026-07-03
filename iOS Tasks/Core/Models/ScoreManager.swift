import Foundation
import Combine

struct ScoreEntry: Codable, Identifiable, Equatable {
    var id = UUID()
    let score: Int
    let date: Date
    let game: String
}

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
    
    func addScore(_ score: Int, for route: GameRoute) {
        guard score > 0 else { return } // Don't save 0 score
        
        let entry = ScoreEntry(score: score, date: Date(), game: route.rawValue)
        
        switch route {
        case .tapFrenzy:
            tapFrenzyScores.append(entry)
            tapFrenzyScores.sort { $0.score > $1.score }
            if tapFrenzyScores.count > 10 { tapFrenzyScores.removeLast() }
        case .lightItUp:
            lightItUpScores.append(entry)
            lightItUpScores.sort { $0.score > $1.score }
            if lightItUpScores.count > 10 { lightItUpScores.removeLast() }
        case .quizRush:
            quizRushScores.append(entry)
            quizRushScores.sort { $0.score > $1.score }
            if quizRushScores.count > 10 { quizRushScores.removeLast() }
        default: break
        }
        
        saveScores()
    }
    
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
    
    func resetScores() {
        tapFrenzyScores.removeAll()
        lightItUpScores.removeAll()
        quizRushScores.removeAll()
        
        userDefaults.removeObject(forKey: tapFrenzyKey)
        userDefaults.removeObject(forKey: lightItUpKey)
        userDefaults.removeObject(forKey: quizRushKey)
        
        // Also clear the AppStorage keys for the main menu REC stats
        userDefaults.removeObject(forKey: "highScore_tapFrenzy")
        userDefaults.removeObject(forKey: "highScore_lightItUp")
        userDefaults.removeObject(forKey: "highScore_quizRush")
    }
}
