import SwiftUI
import Combine

struct QuizRushView: View {
    @Binding var currentRoute: GameRoute
    @StateObject private var viewModel = QuizRushViewModel()
    
    // Animation states
    @State private var flashColor: Color = .clear
    @State private var shakeOffset: CGFloat = 0
    @State private var isAnswering = false
    @State private var selectedAnswer: String? = nil
    
    // Callback for high score update
    var onGameFinish: (Int) -> Void
    
    var body: some View {
        ZStack {
            tactilePixelBackground()
            
            VStack {
                topBar()
                Spacer()
                
                switch viewModel.state {
                case .loading:
                    ProgressView("Fetching Trivia...")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(brutalistDark)
                    
                case .failed:
                    VStack(spacing: 24) {
                        Text("CONNECTION ERROR")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.red)
                        
                        Button(action: {
                            viewModel.retry()
                        }) {
                            Text("RETRY")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(brutalistDark)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 16)
                                .background(cautionYellow)
                                .border(brutalistDark, width: 2)
                                .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
                        }
                        .buttonStyle(MenuButtonStyle())
                    }
                    
                case .loaded:
                    loadedView()
                    
                case .finished:
                    resultsView()
                }
                
                Spacer()
            }
            .padding(.top, 50)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            
            // Screen flash overlay
            flashColor
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .task {
            if viewModel.state == .loading && viewModel.questions.isEmpty {
                viewModel.loadData()
            }
        }
    }
    
    private func topBar() -> some View {
        HStack {
            Button(action: { currentRoute = .mainMenu }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .black))
                    Text("ARCADE")
                        .font(.system(size: 20, weight: .black, design: .default))
                        .italic()
                }
                .foregroundColor(brutalistDark)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                if viewModel.streak > 1 {
                    Text("\(viewModel.streak) STREAK 🔥")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Color.red
                                .border(brutalistDark, width: 2)
                                .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
                        )
                }
                
                Text("\(viewModel.score) PTS")
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
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
    }
    
    private func loadedView() -> some View {
        VStack(spacing: 32) {
            if let question = viewModel.currentQuestion {
                // Question Header
                HStack {
                    Text("Q\(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(brutalistDark)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .border(brutalistDark, width: 2)
                    
                    Spacer()
                    
                    Text(question.category.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.gray)
                }
                
                // Question Text
                tactileCard {
                    Text(question.decodedQuestion)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(brutalistDark)
                        .multilineTextAlignment(.center)
                        .padding(24)
                        .frame(maxWidth: .infinity, minHeight: 140)
                }
                .offset(x: shakeOffset)
                
                // Answers
                VStack(spacing: 16) {
                    ForEach(viewModel.currentAnswers, id: \.self) { answer in
                        Button(action: {
                            handleAnswer(answer)
                        }) {
                            Text(answer)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(brutalistDark)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .padding(.horizontal, 16)
                        }
                        .background(
                            answerBackgroundColor(for: answer)
                                .border(brutalistDark, width: 2)
                                .shadow(color: brutalistDark, radius: 0, x: 3, y: 3)
                        )
                        .buttonStyle(MenuButtonStyle())
                        .disabled(isAnswering)
                    }
                }
            }
        }
    }
    
    private func resultsView() -> some View {
        VStack(spacing: 32) {
            tactileCard {
                VStack(spacing: 16) {
                    Text("QUIZ COMPLETE")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(brutalistDark)
                    
                    Text("FINAL SCORE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.gray)
                    
                    Text("\(viewModel.score)")
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(brutalistDark)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
            }
            
            Button(action: {
                onGameFinish(viewModel.score)
                currentRoute = .mainMenu
            }) {
                Text("MAIN MENU")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(brutalistDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(cautionYellow)
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: 4, y: 4)
            }
            .buttonStyle(MenuButtonStyle())
        }
        .onAppear {
            onGameFinish(viewModel.score)
        }
    }
    
    private func handleAnswer(_ answer: String) {
        guard !isAnswering else { return }
        isAnswering = true
        selectedAnswer = answer
        
        let isCorrect = viewModel.submitAnswer(answer)
        
        if isCorrect {
            // Green flash
            withAnimation(.easeInOut(duration: 0.15)) {
                flashColor = Color.green.opacity(0.3)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    flashColor = .clear
                }
                viewModel.advanceToNextQuestion()
                isAnswering = false
            }
        } else {
            // Red flash and shake
            withAnimation(.easeInOut(duration: 0.15)) {
                flashColor = Color.red.opacity(0.3)
            }
            
            // Simple shake animation
            withAnimation(.linear(duration: 0.05).repeatCount(4, autoreverses: true)) {
                shakeOffset = 10
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakeOffset = 0
                withAnimation(.easeInOut(duration: 0.15)) {
                    flashColor = .clear
                }
                viewModel.advanceToNextQuestion()
                isAnswering = false
                selectedAnswer = nil
            }
        }
    }
    
    private func answerBackgroundColor(for answer: String) -> Color {
        guard isAnswering else { return .white }
        
        let isCorrectAnswer = answer == viewModel.currentQuestion?.decodedCorrectAnswer
        if isCorrectAnswer {
            return Color.green.opacity(0.8)
        }
        
        if answer == selectedAnswer {
            return Color.red.opacity(0.8)
        }
        
        return .white
    }
    
    // Tactile Card Modifier wrapper for this view
    private func tactileCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(
                brutalistBg
                    .border(brutalistDark, width: 2)
                    .shadow(color: brutalistDark, radius: 0, x: 4, y: 4)
            )
            .overlay(tactileUIAccent(alignment: .topLeading))
            .overlay(tactileUIAccent(alignment: .bottomTrailing))
    }
}
