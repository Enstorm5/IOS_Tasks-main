import SwiftUI

struct MainMenuView: View {
    @Binding var currentRoute: GameRoute
    @Binding var bestTapFrenzy: Int
    @Binding var bestLightItUp: Int
    let onTapFrenzySelected: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                tactilePixelBackground()
                
                ScrollView {
                    VStack(spacing: 32) {
                        heroSection()
                    }
                    .padding(.top, 80) // Space for top bar
                    .padding(.bottom, 100) // Space for bottom bar
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            bottomNavBar()
        }
        .overlay(topBar(), alignment: .top)
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color.white)
    }
    
    
    // Top Bar
    func topBar() -> some View {
        HStack {
            Text("ARCADE")
                .font(.system(size: 20, weight: .black, design: .default))
                .italic()
                .foregroundColor(brutalistDark)
            
            Spacer()
            
            HStack(spacing: 12) {
                Text("2,450 PTS")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(brutalistDark)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        cautionYellow
                            .border(brutalistDark, width: 2)
                            .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
                    )
                
                Text("HELP")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(brutalistDark)
                    .padding(.bottom, 2)
                    .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
    }
    
    // Hero Section
    func heroSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(cautionYellow)
                    .frame(width: 8, height: 24)
                    .border(brutalistDark, width: 1)
                
                Text("FEATURED")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(brutalistDark)
                    .tracking(-1)
            }
            
            VStack(spacing: 16) {
                featuredCard(
                    title: "TAP FRENZY",
                    desc: "Tactical tapping challenge. Compete globally.",
                    time: "REC: \(bestTapFrenzy)",
                    action: { onTapFrenzySelected() }
                )
                
                featuredCard(
                    title: "LIGHT IT UP",
                    desc: "High-speed reflex memory. Endless levels.",
                    time: "REC: \(bestLightItUp)",
                    action: { currentRoute = .lightItUp }
                )
            }
        }
    }
    
    // Featured Card
    func featuredCard(title: String, desc: String, time: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            tactileCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text(title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(brutalistDark)
                        
                        Spacer()
                        
                        Text(time)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(brutalistDark)
                    }
                    
                    Text(desc)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 4) {
                        Rectangle().fill(cautionYellow).frame(width: 6, height: 6).border(brutalistDark, width: 1)
                        Rectangle().fill(brutalistDark).frame(width: 6, height: 6)
                        Rectangle().fill(brutalistDark).frame(width: 6, height: 6)
                    }
                    .padding(.top, 4)
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Tactile Card Modifier
    func tactileCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(
                brutalistBg
                    .border(brutalistDark, width: 1.5)
                    .shadow(color: brutalistDark, radius: 0, x: 3, y: 3)
            )
            .overlay(tactileUIAccent(alignment: .topLeading))
            .overlay(tactileUIAccent(alignment: .bottomTrailing))
    }
    
    // Bottom Nav
    func bottomNavBar() -> some View {
        HStack(spacing: 0) {
            navItem(label: "Home", isSelected: true)
            navItem(label: "Library", isSelected: false)
            navItem(label: "Scores", isSelected: false)
        }
        .frame(height: 64)
        .padding(.horizontal, 24)
        .padding(.bottom, 20) // Home indicator
        .background(Color.white)
        .overlay(Rectangle().frame(height: 4).foregroundColor(brutalistDark), alignment: .top)
    }
    
    func navItem(label: String, isSelected: Bool) -> some View {
        Button(action: {}) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .black))
                .foregroundColor(isSelected ? brutalistDark : Color(red: 71/255, green: 85/255, blue: 105/255))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isSelected ? cautionYellow : Color.clear)
                .border(isSelected ? brutalistDark : Color.clear, width: 1)
        }
        .frame(maxWidth: .infinity)
    }
}
