import SwiftUI
import Charts

struct ScoresView: View {
    @Binding var currentRoute: GameRoute
    @EnvironmentObject var scoreManager: ScoreManager
    
    @State private var selectedGame: GameRoute = .tapFrenzy
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                tactilePixelBackground()
                
                VStack(spacing: 0) {
                    topBar()
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            summaryCards()
                            personalBests()
                            barChartSection()
                            recentGamesSection()
                            leaderboardSection()

                        }
                        .padding(20)
                    }
                }
            }
        }
        .background(Color.white)
    }
    

    
    private func topBar() -> some View {
        HStack {
            Text("STATS")
                .font(.system(size: 24, weight: .black, design: .default))
                .italic()
                .foregroundColor(brutalistDark)
            
            Spacer()
            
            Text("TOTAL: \(scoreManager.totalScoreAllGames)")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(brutalistDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .tactileBadge()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
    }
    

    
    private func summaryCards() -> some View {
        HStack(spacing: 12) {
            statCard(label: "GAMES", value: "\(scoreManager.totalGamesPlayed)", icon: "gamecontroller.fill")
            statCard(label: "TOTAL PTS", value: "\(scoreManager.totalScoreAllGames)", icon: "star.fill")
            statCard(label: "BEST", value: "\(scoreManager.totalBestScore)", icon: "trophy.fill")
        }
    }
    
    private func statCard(label: String, value: String, icon: String) -> some View {
        TactileCard {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(cautionYellow)
                
                Text(value)
                    .font(.system(size: 22, weight: .black, design: .monospaced))
                    .foregroundColor(brutalistDark)
                
                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color.gray)
                    .tracking(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
        }
    }
    

    
    private func personalBests() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                tactileTitleAccent()
                Text("PERSONAL BESTS")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(brutalistDark)
            }
            
            VStack(spacing: 8) {
                bestRow(mode: "TAP FRENZY", score: scoreManager.bestTapFrenzy, avg: scoreManager.averageScore(for: .tapFrenzy))
                bestRow(mode: "LIGHT IT UP", score: scoreManager.bestLightItUp, avg: scoreManager.averageScore(for: .lightItUp))
                bestRow(mode: "QUIZ RUSH", score: scoreManager.bestQuizRush, avg: scoreManager.averageScore(for: .quizRush))
            }
        }
    }
    
    private func bestRow(mode: String, score: Int, avg: Int) -> some View {
        TactileCard {
            HStack {
                Text(mode)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(brutalistDark)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(score) PTS")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(brutalistDark)
                    Text("AVG \(avg)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.gray)
                }
            }
            .padding(12)
        }
    }
    

    
    private func barChartSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                tactileTitleAccent()
                Text("BEST SCORES")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(brutalistDark)
            }
            
            TactileCard {
                Chart {
                    BarMark(
                        x: .value("Game", "TAP"),
                        y: .value("Score", scoreManager.bestTapFrenzy)
                    )
                    .foregroundStyle(cautionYellow)
                    .annotation(position: .top) {
                        Text("\(scoreManager.bestTapFrenzy)")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(brutalistDark)
                    }
                    
                    BarMark(
                        x: .value("Game", "LIGHT"),
                        y: .value("Score", scoreManager.bestLightItUp)
                    )
                    .foregroundStyle(cautionYellow)
                    .annotation(position: .top) {
                        Text("\(scoreManager.bestLightItUp)")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(brutalistDark)
                    }
                    
                    BarMark(
                        x: .value("Game", "QUIZ"),
                        y: .value("Score", scoreManager.bestQuizRush)
                    )
                    .foregroundStyle(cautionYellow)
                    .annotation(position: .top) {
                        Text("\(scoreManager.bestQuizRush)")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(brutalistDark)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(brutalistDark)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundStyle(Color.gray.opacity(0.3))
                        AxisValueLabel()
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.gray)
                    }
                }
                .frame(height: 200)
                .padding(16)
            }
        }
    }
    

    
    private func recentGamesSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                tactileTitleAccent()
                Text("RECENT GAMES")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(brutalistDark)
            }
            
            let recent = Array(scoreManager.recentGames.prefix(5))
            
            if recent.isEmpty {
                Text("NO GAMES YET")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 8) {
                    ForEach(recent) { entry in
                        recentGameRow(entry: entry)
                    }
                }
            }
        }
    }
    
    private func recentGameRow(entry: ScoreEntry) -> some View {
        TactileCard {
            HStack {
                Text(GameRoute.fromRawValue(entry.game)?.shortName ?? entry.game.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(brutalistDark)
                
                Spacer()
                
                Text("\(entry.score) PTS")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(brutalistDark)
                
                Text(sharedDateFormatter.string(from: entry.date))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.gray)
                    .frame(width: 90, alignment: .trailing)
            }
            .padding(12)
        }
    }
    

    
    private func leaderboardSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                tactileTitleAccent()
                Text("LEADERBOARD")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(brutalistDark)
            }
            
            gameSelector()
            
            let scores = scoreManager.scoresFor(selectedGame)
            
            if scores.isEmpty {
                Text("NO SCORES YET")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(scores.prefix(10).enumerated()), id: \.element.id) { index, entry in
                        scoreCard(entry: entry, rank: index + 1)
                    }
                }
            }
        }
    }
    
    private func gameSelector() -> some View {
        HStack(spacing: 12) {
            selectorButton(title: "TAP", game: .tapFrenzy)
            selectorButton(title: "LIGHT", game: .lightItUp)
            selectorButton(title: "QUIZ", game: .quizRush)
        }
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
        .buttonStyle(TactileSegmentButtonStyle(isSelected: isSelected))
    }
    
    private func scoreCard(entry: ScoreEntry, rank: Int) -> some View {
        TactileCard {
            HStack {
                Text("#\(rank)")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(rank == 1 ? cautionYellow : brutalistDark)
                    .frame(width: 40, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.score) PTS")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(brutalistDark)
                    
                    Text(sharedDateFormatter.string(from: entry.date))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
                }
                
                Spacer()
            }
            .padding(16)
        }
    }
    

    

}
