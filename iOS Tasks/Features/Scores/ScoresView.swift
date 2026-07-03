import SwiftUI

struct ScoresView: View {
    @Binding var currentRoute: GameRoute
    @EnvironmentObject var scoreManager: ScoreManager
    
    @State private var selectedGame: GameRoute = .tapFrenzy
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                tactilePixelBackground()
                
                VStack(spacing: 0) {
                    // Top Bar
                    topBar()
                    
                    // Game Selector
                    gameSelector()
                    
                    // Scores List
                    ScrollView {
                        VStack(spacing: 16) {
                            if scoresForSelectedGame().isEmpty {
                                Text("NO SCORES YET")
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                                    .padding(.top, 40)
                            } else {
                                ForEach(Array(scoresForSelectedGame().enumerated()), id: \.element.id) { index, entry in
                                    scoreCard(entry: entry, rank: index + 1)
                                }
                            }
                        }
                        .padding(20)
                    }
                    
                    Button(action: {
                        scoreManager.resetScores()
                    }) {
                        Text("RESET HISTORY")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.gray)
                            .underline()
                    }
                    .padding(.vertical, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(Color.white)
    }
    
    // MARK: - Components
    
    private func topBar() -> some View {
        HStack {
            Button(action: {
                currentRoute = .mainMenu
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(brutalistDark)
                    .frame(width: 44, height: 44)
            }
            .background(
                Color.white
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
            )
            
            Text("SCORES")
                .font(.system(size: 24, weight: .black, design: .default))
                .italic()
                .foregroundColor(brutalistDark)
                .padding(.leading, 12)
            
            Spacer()
            
            Text("TOTAL: \(scoreManager.totalBestScore)")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(brutalistDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    cautionYellow
                        .border(brutalistDark, width: 2)
                        .shadow(color: brutalistDark, radius: 0, x: 3, y: 3)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
    }
    
    private func gameSelector() -> some View {
        HStack(spacing: 12) {
            selectorButton(title: "TAP", game: .tapFrenzy)
            selectorButton(title: "LIGHT", game: .lightItUp)
            selectorButton(title: "QUIZ", game: .quizRush)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(panelBg)
        .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
    }
    
    private func selectorButton(title: String, game: GameRoute) -> some View {
        let isSelected = selectedGame == game
        return Button(action: {
            selectedGame = game
        }) {
            Text(title)
                .font(.system(size: 14, weight: .black))
                .foregroundColor(isSelected ? brutalistDark : Color(red: 100/255, green: 116/255, blue: 139/255))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(
            (isSelected ? cautionYellow : Color.white)
                .border(isSelected ? brutalistDark : Color(red: 203/255, green: 213/255, blue: 225/255), width: 2)
                .shadow(color: isSelected ? brutalistDark : .clear, radius: 0, x: 2, y: 2)
        )
    }
    
    private func scoreCard(entry: ScoreEntry, rank: Int) -> some View {
        HStack {
            Text("#\(rank)")
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(rank == 1 ? cautionYellow : brutalistDark)
                .frame(width: 40, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.score) PTS")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(brutalistDark)
                
                Text(dateFormatter.string(from: entry.date))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            Color.white
                .border(brutalistDark, width: 2)
                .shadow(color: brutalistDark, radius: 0, x: 4, y: 4)
        )
    }
    
    // MARK: - Helpers
    
    private func scoresForSelectedGame() -> [ScoreEntry] {
        switch selectedGame {
        case .tapFrenzy: return scoreManager.tapFrenzyScores
        case .lightItUp: return scoreManager.lightItUpScores
        case .quizRush: return scoreManager.quizRushScores
        default: return []
        }
    }
}
