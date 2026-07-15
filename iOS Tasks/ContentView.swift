import SwiftUI
import Combine
import MapKit

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
    @StateObject private var locationManager = LocationManager()
    
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
        .onAppear {
            locationManager.requestPermission()
            locationManager.startUpdating()
        }
        .onReceive(timer) { _ in
            let wasGameOver = tapFrenzyState.isGameOver
            tapFrenzyState = TapFrenzyReducer.reduce(currentState: tapFrenzyState, action: .timerTicked(timeStep: 0.1))
            if !wasGameOver && tapFrenzyState.isGameOver {
                if tapFrenzyState.score > bestTapFrenzy {
                    bestTapFrenzy = tapFrenzyState.score
                }
                scoreManager.addScore(tapFrenzyState.score, for: .tapFrenzy, location: locationManager.lastLocation)
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
                    scoreManager.addScore(score, for: .lightItUp, location: locationManager.lastLocation)
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
                    scoreManager.addScore(score, for: .quizRush, location: locationManager.lastLocation)
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

// MARK: - MapView
struct MapView: View {
    @EnvironmentObject var scoreManager: ScoreManager
    @State private var selectedEntry: ScoreEntry?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            mapTopBar()
            
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition) {
                    ForEach(scoreManager.scoredLocations) { entry in
                        Annotation("", coordinate: CLLocationCoordinate2D(
                            latitude: entry.latitude ?? 0,
                            longitude: entry.longitude ?? 0
                        )) {
                            Button(action: { selectedEntry = entry }) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(cautionYellow)
                                    .background(
                                        Circle()
                                            .fill(brutalistDark)
                                            .frame(width: 20, height: 20)
                                    )
                            }
                        }
                    }
                }
                .mapStyle(.standard)
                
                if let entry = selectedEntry {
                    pinDetail(entry: entry)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    private func mapTopBar() -> some View {
        HStack {
            Text("MAP")
                .font(.system(size: 24, weight: .black, design: .default))
                .italic()
                .foregroundColor(brutalistDark)
            
            Spacer()
            
            Text("\(scoreManager.scoredLocations.count) PINS")
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
    
    private func pinDetail(entry: ScoreEntry) -> some View {
        TactileCard {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(gameModeLabel(entry.game))
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(brutalistDark)
                    
                    Text("\(entry.score) PTS")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(brutalistDark)
                    
                    Text(dateFormatter.string(from: entry.date))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                Button(action: { selectedEntry = nil }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(brutalistDark)
                        .frame(width: 32, height: 32)
                }
                .background(
                    Color.white
                        .border(brutalistDark, width: 2)
                        .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
                )
            }
            .padding(16)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
    
    private func gameModeLabel(_ game: String) -> String {
        switch game {
        case "tapFrenzy": return "TAP FRENZY"
        case "lightItUp": return "LIGHT IT UP"
        case "quizRush": return "QUIZ RUSH"
        default: return game.uppercased()
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

