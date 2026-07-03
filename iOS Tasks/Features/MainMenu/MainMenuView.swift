import SwiftUI

struct MainMenuView: View {
    @Binding var currentRoute: GameRoute
    @Binding var bestTapFrenzy: Int
    @Binding var bestLightItUp: Int
    @Binding var bestQuizRush: Int
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
            
            Text("\(bestTapFrenzy + bestLightItUp + bestQuizRush) PTS")
                .font(.system(size: 16, weight: .black))
                .foregroundColor(brutalistDark)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
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
    
    // Hero Section
    func heroSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                tactileTitleAccent()
                
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
                
                featuredCard(
                    title: "QUIZ RUSH",
                    desc: "Live trivia,Answer from multiple choices.",
                    time: "REC: \(bestQuizRush)",
                    action: { currentRoute = .quizRush }
                )
            }
        }
    }
    
    // Featured Card
    func featuredCard(title: String, desc: String, time: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            TactileCard {
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
    
    // Tactile components moved to TactileUI.swift
    
    // Bottom Nav
    func bottomNavBar() -> some View {
        HStack(spacing: 0) {
            navItem(label: "Home", iconName: "home_icon", isSelected: true, action: {})
            navItem(label: "Scores", iconName: "scores_icon", isSelected: false, action: { currentRoute = .scores })
        }
        .frame(height: 80)
        .padding(.horizontal, 24)
        .padding(.bottom, 20) // Home indicator
        .background(Color.white)
        .overlay(Rectangle().frame(height: 4).foregroundColor(brutalistDark), alignment: .top)
    }
    
    func navItem(label: String, iconName: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text(label.uppercased())
                    .font(.system(size: 14, weight: .black))
            }
            .foregroundColor(isSelected ? brutalistDark : Color(red: 71/255, green: 85/255, blue: 105/255))
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
        .background(
            (isSelected ? cautionYellow : Color.clear)
                .border(isSelected ? brutalistDark : Color.clear, width: 2)
                .shadow(color: isSelected ? brutalistDark : .clear, radius: 0, x: 3, y: 3)
        )
        .frame(maxWidth: .infinity)
    }
}
