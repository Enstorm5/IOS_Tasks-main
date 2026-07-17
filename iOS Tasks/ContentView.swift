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
    
    @State private var tapFrenzyState = TapFrenzyState()
    
    @StateObject private var scoreManager = ScoreManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var notificationManager = NotificationManager()
    
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
                    MainMenuView(currentRoute: homeRouteBinding)
                    .navigationDestination(for: GameRoute.self) { route in
                        destination(for: route)
                    }
                    .navigationBarHidden(true)
                }
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
                
                NavigationStack {
                    ScoresView(currentRoute: .constant(.scores))
                        .navigationBarHidden(true)
                }
                .opacity(selectedTab == .stats ? 1 : 0)
                .allowsHitTesting(selectedTab == .stats)
                
                NavigationStack {
                    MapView()
                        .navigationBarHidden(true)
                }
                .opacity(selectedTab == .map ? 1 : 0)
                .allowsHitTesting(selectedTab == .map)
                
                NavigationStack {
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
                scoreManager.addScore(tapFrenzyState.score, for: .tapFrenzy, location: locationManager.lastLocation)
            }
        }
        .environmentObject(scoreManager)
        .environmentObject(notificationManager)
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
        return Button(action: {
            if tab == .home {
                homePath = NavigationPath() // Reset to root if in game
            }
            selectedTab = tab
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? cautionYellow : Color.gray)
                
                if isSelected {
                    Text(title)
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(brutalistDark)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .tactileBadge()
                } else {
                    Text(title)
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Color.gray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                }
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
                    tapFrenzyState = TapFrenzyReducer.reduce(currentState: tapFrenzyState, action: .targetTapped(side: .center))
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
                    scoreManager.addScore(score, for: .lightItUp, location: locationManager.lastLocation)
                }
            )
            .navigationBarHidden(true)
        case .quizRush:
            QuizRushView(
                currentRoute: homeRouteBinding,
                onGameFinish: { score in
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

