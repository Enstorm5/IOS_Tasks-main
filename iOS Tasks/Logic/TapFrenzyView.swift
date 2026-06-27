import SwiftUI

struct TapFrenzyView: View {
    @Binding var currentRoute: GameRoute
    @Binding var state: TimerState
    let onButtonTap: () -> Void
    let onGameAction: (TimerAction) -> Void
    
    var body: some View {
        ZStack {
           
            VStack(spacing: 30) {
                HStack {
                    Button(action: { currentRoute = .mainMenu }) {
                        HStack(spacing: 5) {
                            Image(systemName: "house.fill")
                            Text("Menu")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Score Display
                VStack(spacing: 5) {
                    Text("SCORE")
                        .font(.caption).bold().foregroundColor(.gray)
                    Text("\(state.score)")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                    
                    if state.isPlaying && state.comboMultiplier > 1 {
                        Text("\(state.comboMultiplier)x Combo!")
                            .font(.headline).bold().foregroundColor(.orange)
                    } else {
                        Text(" ").font(.headline)
                    }
                }
                
                // Timer
                VStack(spacing: 8) {
                    Text(String(format: "%.1fs Remaining", state.timeRemaining))
                        .font(.system(.title3, design: .monospaced)).bold()
                    ProgressView(value: state.timeRemaining, total: 10.0)
                        .padding(.horizontal, 50)
                }
                
                Spacer()
                
                // Target Circle Button
                circleButton {
                    onButtonTap()
                }
                .disabled(!state.isPlaying || state.isGameOver)
                
                Spacer()
            }
            .blur(radius: state.isGameOver ? 5 : 0)
            
            
            if !state.isPlaying && !state.isGameOver {
                CardContainer {
                    VStack(spacing: 20) {
                        Text("TAP FRENZY")
                            .font(.largeTitle)
                            .fontWeight(.black)
                        Text("Tap as fast as you can inside 10 seconds. Avoid grey penalty traps!")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button(action: { onGameAction(.startOrRestartGame) }) {
                            Text("START GAME")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            
            if state.isGameOver {
                CardContainer {
                    VStack(spacing: 20) {
                        Text("GAME OVER")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundColor(.red)
                        
                        Text("Final Score: \(state.score)")
                            .font(.title).bold()
                        
                        HStack(spacing: 15) {
                            Button(action: { currentRoute = .mainMenu }) {
                                Text("MAIN MENU")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: { onGameAction(.startOrRestartGame) }) {
                                Text("PLAY AGAIN")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func circleButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text("TAP!").font(.system(size: 32, weight: .black, design: .rounded))
                if state.currentButtonColor == .green { Text("BONUS!").font(.caption).bold() }
                else if state.currentButtonColor == .grey { Text("PENALTY!").font(.caption).bold() }
            }
            .foregroundColor(.white)
            .frame(width: 200, height: 200)
            .background(state.currentButtonColor.displayColor)
            .clipShape(Circle())
        }
    }
}
