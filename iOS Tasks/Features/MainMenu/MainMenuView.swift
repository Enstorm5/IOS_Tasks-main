import SwiftUI

struct MainMenuView: View {
    @Binding var currentRoute: GameRoute
    @EnvironmentObject var scoreManager: ScoreManager
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                tactilePixelBackground()
                
                ScrollView {
                    VStack(spacing: 32) {
                        heroSection()
                    }
                    .padding(.top, 80) 
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            
        }
        .overlay(topBar(), alignment: .top)
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
            
            Text("\(scoreManager.totalBestScore) REC TOTAL")
                .font(.system(size: 16, weight: .black))
                .foregroundColor(brutalistDark)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .tactileBadge()
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
                NavigationLink(value: GameRoute.tapFrenzy) {
                    featuredCardContent(
                        title: "TAP FRENZY",
                        desc: "Tactical tapping challenge. Compete globally.",
                        time: "REC: \(scoreManager.bestTapFrenzy)"
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(value: GameRoute.lightItUp) {
                    featuredCardContent(
                        title: "LIGHT IT UP",
                        desc: "High-speed reflex memory. Endless levels.",
                        time: "REC: \(scoreManager.bestLightItUp)"
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(value: GameRoute.quizRush) {
                    featuredCardContent(
                        title: "QUIZ RUSH",
                        desc: "Live trivia,Answer from multiple choices.",
                        time: "REC: \(scoreManager.bestQuizRush)"
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    
    func featuredCardContent(title: String, desc: String, time: String) -> some View {
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
}
