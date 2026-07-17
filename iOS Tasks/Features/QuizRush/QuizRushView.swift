import SwiftUI
import Combine

struct QuizRushView: View {
    @Binding var currentRoute: GameRoute
    @State private var state = QuizRushState()
    private let quizService = QuizService()
    
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
                
                switch state.viewState {
                case .setup:
                    setupView()
                    
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
                            state = QuizRushReducer.reduce(currentState: state, action: .retry)
                            loadData()
                        }) {
                            Text("RETRY")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(brutalistDark)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(TactileButtonStyle())
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
    }
    
    private func loadData() {
        Task {
            do {
                let fetchedQuestions = try await quizService.fetchQuestions(category: state.selectedCategory, difficulty: state.selectedDifficulty)
                state = QuizRushReducer.reduce(currentState: state, action: .dataLoaded(fetchedQuestions))
            } catch {
                state = QuizRushReducer.reduce(currentState: state, action: .dataFailed)
            }
        }
    }
    
    private func setupView() -> some View {
        VStack(spacing: 24) {
            TactileCard {
                VStack(alignment: .leading, spacing: 20) {
                    Text("GENRE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.gray)
                    
                    HStack {
                        genreButton(id: 11, label: "FILM")
                        genreButton(id: 12, label: "MUSIC")
                    }
                    HStack {
                        genreButton(id: 14, label: "TV")
                        genreButton(id: 15, label: "GAMES")
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
            }
            
            TactileCard {
                VStack(alignment: .leading, spacing: 20) {
                    Text("DIFFICULTY")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.gray)
                    
                    HStack {
                        difficultyButton(id: "easy", label: "EASY")
                        difficultyButton(id: "medium", label: "MEDIUM")
                        difficultyButton(id: "hard", label: "HARD")
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
            }
            
            Button(action: {
                state = QuizRushReducer.reduce(currentState: state, action: .randomizeSetup)
            }) {
                Text("RANDOMIZE")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(brutalistDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(TactileSecondaryButtonStyle())
            
            Button(action: {
                state = QuizRushReducer.reduce(currentState: state, action: .startQuiz)
                loadData()
            }) {
                Text("START RUSH")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(brutalistDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
            .buttonStyle(TactileButtonStyle())
        }
    }
    
    private func genreButton(id: Int, label: String) -> some View {
        Button(action: {
            state = QuizRushReducer.reduce(currentState: state, action: .setCategory(id))
        }) {
            Text(label)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(brutalistDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(
            (state.selectedCategory == id ? cautionYellow : Color.white)
                .border(brutalistDark, width: 2)
                .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
        )
    }
    
    private func difficultyButton(id: String, label: String) -> some View {
        Button(action: {
            state = QuizRushReducer.reduce(currentState: state, action: .setDifficulty(id))
        }) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(brutalistDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(
            (state.selectedDifficulty == id ? cautionYellow : Color.white)
                .border(brutalistDark, width: 2)
                .shadow(color: brutalistDark, radius: 0, x: 2, y: 2)
        )
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
                if state.streak > 1 {
                    Text("\(state.streak) STREAK 🔥")
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
                
                Text("\(state.score) PTS")
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
            if let question = state.currentQuestion {
                // Question Header
                HStack {
                    Text("Q\(state.currentIndex + 1) of \(state.questions.count)")
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
                TactileCard {
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
                    ForEach(state.currentAnswers, id: \.self) { answer in
                        Button(action: {
                            handleAnswer(answer)
                        }) {
                            Text(answer)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(brutalistDark)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .padding(.horizontal, 16)
                                .background(
                                    answerBackgroundColor(for: answer)
                                        .border(brutalistDark, width: 2)
                                        .shadow(color: brutalistDark, radius: 0, x: 3, y: 3)
                                )
                        }
                        .buttonStyle(TactileSecondaryButtonStyle())
                        .disabled(isAnswering)
                    }
                }
            }
        }
    }
    
    private func resultsView() -> some View {
        VStack(spacing: 32) {
            TactileCard {
                VStack(spacing: 16) {
                    Text("QUIZ COMPLETE")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(brutalistDark)
                    
                    Text("FINAL SCORE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.gray)
                    
                    Text("\(state.score)")
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(brutalistDark)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
            }
            
            Button(action: {
                currentRoute = .mainMenu
            }) {
                Text("MAIN MENU")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(brutalistDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
            .buttonStyle(TactileButtonStyle())
        }
        .onAppear {
            onGameFinish(state.score)
        }
    }
    
    private func handleAnswer(_ answer: String) {
        guard !isAnswering else { return }
        isAnswering = true
        selectedAnswer = answer
        
        let isCorrect = answer == state.currentQuestion?.decodedCorrectAnswer
        state = QuizRushReducer.reduce(currentState: state, action: .submitAnswer(answer: answer, isCorrect: isCorrect))
        
        if isCorrect {
            // Green flash
            withAnimation(.easeInOut(duration: 0.15)) {
                flashColor = Color.green.opacity(0.3)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    flashColor = .clear
                }
                state = QuizRushReducer.reduce(currentState: state, action: .advanceToNextQuestion)
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
                state = QuizRushReducer.reduce(currentState: state, action: .advanceToNextQuestion)
                isAnswering = false
                selectedAnswer = nil
            }
        }
    }
    
    private func answerBackgroundColor(for answer: String) -> Color {
        guard isAnswering else { return .white }
        
        let isCorrectAnswer = answer == state.currentQuestion?.decodedCorrectAnswer
        if isCorrectAnswer {
            return Color.green.opacity(0.8)
        }
        
        if answer == selectedAnswer {
            return Color.red.opacity(0.8)
        }
        
        return .white
    }
    
    // Tactile components moved to TactileUI.swift
}
