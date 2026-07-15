import SwiftUI
import Combine

enum AppTab: Int {
    case home
    case stats
    case map
    case settings
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    
    @State private var homePath = NavigationPath()
    @State private var statsPath = NavigationPath()
    @State private var mapPath = NavigationPath()
    @State private var settingsPath = NavigationPath()
    
    @State private var tapFrenzyState = TapFrenzyState()

    @AppStorage("highScore_tapFrenzy") private var bestTapFrenzy: Int = 0
    @AppStorage("highScore_lightItUp") private var bestLightItUp: Int = 0
    @AppStorage("highScore_quizRush") private var bestQuizRush: Int = 0
    
    @StateObject private var scoreManager = ScoreManager()
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var homeRouteBinding: Binding<GameRoute> {
        Binding(
            get: { .mainMenu },
            set: { newValue in
                if newValue == .mainMenu {
                    homePath = NavigationPath()
                }
            }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                NavigationStack(path: $homePath) {
                    MainMenuView(
                        currentRoute: homeRouteBinding,
                        bestTapFrenzy: $bestTapFrenzy,
                        bestLightItUp: $bestLightItUp,
                        bestQuizRush: $bestQuizRush,
                        onTapFrenzySelected: {
                            tapFrenzyState = TapFrenzyState()
                            homePath.append(GameRoute.tapFrenzy)
                        }
                    )
                    .navigationDestination(for: GameRoute.self) { route in
                        destination(for: route)
                    }
                    .navigationBarHidden(true)
                }
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
                
                NavigationStack(path: $statsPath) {
                    ScoresView(currentRoute: .constant(.scores))
                        .navigationBarHidden(true)
                }
                .opacity(selectedTab == .stats ? 1 : 0)
                .allowsHitTesting(selectedTab == .stats)
                
                NavigationStack(path: $mapPath) {
                    MapView()
                        .navigationBarHidden(true)
                }
                .opacity(selectedTab == .map ? 1 : 0)
                .allowsHitTesting(selectedTab == .map)
                
                NavigationStack(path: $settingsPath) {
                    SettingsView()
                        .navigationBarHidden(true)
                }
                .opacity(selectedTab == .settings ? 1 : 0)
                .allowsHitTesting(selectedTab == .settings)
            }
            
            customTabBar()
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onReceive(timer) { _ in
            let wasGameOver = tapFrenzyState.isGameOver
            tapFrenzyState = TapFrenzyReducer.reduce(currentState: tapFrenzyState, action: .timerTicked(timeStep: 0.1))
            if !wasGameOver && tapFrenzyState.isGameOver {
                if tapFrenzyState.score > bestTapFrenzy {
                    bestTapFrenzy = tapFrenzyState.score
                }
                scoreManager.addScore(tapFrenzyState.score, for: .tapFrenzy)
            }
        }
        .environmentObject(scoreManager)
    }
    
    func customTabBar() -> some View {
        HStack(spacing: 0) {
            tabButton(tab: .home, icon: "house.fill", title: "HOME")
            tabButton(tab: .stats, icon: "chart.bar.fill", title: "STATS")
            tabButton(tab: .map, icon: "map.fill", title: "MAP")
            tabButton(tab: .settings, icon: "gearshape.fill", title: "SETTINGS")
        }
        .frame(height: 70)
        .padding(.horizontal, 24)
        .padding(.bottom, 20) // Home indicator padding
        .background(Color.white)
        .overlay(Rectangle().frame(height: 4).foregroundColor(brutalistDark), alignment: .top)
    }
    
    func tabButton(tab: AppTab, icon: String, title: String) -> some View {
        let isSelected = selectedTab == tab
        return Button(action: { selectedTab = tab }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? cautionYellow : Color.gray)
                
                Text(title)
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(isSelected ? brutalistDark : Color.gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        (isSelected ? cautionYellow : Color.clear)
                            .border(isSelected ? brutalistDark : Color.clear, width: isSelected ? 2 : 0)
                            .shadow(color: isSelected ? brutalistDark : .clear, radius: 0, x: isSelected ? 2 : 0, y: isSelected ? 2 : 0)
                    )
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func destination(for route: GameRoute) -> some View {
        switch route {
        case .tapFrenzy:
            TapFrenzyView(
                currentRoute: homeRouteBinding,
                state: $tapFrenzyState,
                onButtonTap: {
                    tapFrenzyState = TapFrenzyReducer.reduce(currentState: tapFrenzyState, action: .bigButtonTapped)
                },
                onGameAction: { action in
                    tapFrenzyState = TapFrenzyReducer.reduce(currentState: tapFrenzyState, action: action)
                }
            )
            .navigationBarHidden(true)
        case .lightItUp:
            LightItUpView(
                currentRoute: homeRouteBinding,
                onGameFinish: { score in
                    if score > bestLightItUp {
                        bestLightItUp = score
                    }
                    scoreManager.addScore(score, for: .lightItUp)
                }
            )
            .navigationBarHidden(true)
        case .quizRush:
            QuizRushView(
                currentRoute: homeRouteBinding,
                onGameFinish: { score in
                    if score > bestQuizRush {
                        bestQuizRush = score
                    }
                    scoreManager.addScore(score, for: .quizRush)
                }
            )
            .navigationBarHidden(true)
        default:
            EmptyView()
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - MapView (appended to avoid Xcode project linking issue)
struct MapView: View {
    var body: some View {
        ZStack {
            tactilePixelBackground()
            VStack {
                HStack {
                    Text("MAP")
                        .font(.system(size: 24, weight: .black, design: .default))
                        .italic()
                        .foregroundColor(brutalistDark)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
                
                Spacer()
                Text("MAP COMING SOON")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                Spacer()
            }
        }
    }
}

// MARK: - SettingsView (appended to avoid Xcode project linking issue)
struct SettingsView: View {
    var body: some View {
        ZStack {
            tactilePixelBackground()
            VStack {
                HStack {
                    Text("SETTINGS")
                        .font(.system(size: 24, weight: .black, design: .default))
                        .italic()
                        .foregroundColor(brutalistDark)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
                
                Spacer()
                Text("SETTINGS COMING SOON")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                Spacer()
            }
        }
    }
}

