import Foundation

enum QuizRushViewState {
    case setup
    case loading
    case loaded
    case failed
    case finished
}

struct QuizRushState {
    var viewState: QuizRushViewState = .setup
    
    // Setup Settings
    var selectedCategory: Int = 11
    var selectedDifficulty: String = "easy"
    
    var questions: [Question] = []
    var currentIndex: Int = 0
    var score: Int = 0
    var streak: Int = 0
    var currentAnswers: [String] = []
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
}

enum QuizRushAction {
    case setCategory(Int)
    case setDifficulty(String)
    case randomizeSetup
    case startQuiz
    case loadData
    case dataLoaded([Question])
    case dataFailed
    case submitAnswer(answer: String, isCorrect: Bool)
    case advanceToNextQuestion
    case retry
}

struct QuizRushReducer {
    static func reduce(currentState: QuizRushState, action: QuizRushAction) -> QuizRushState {
        var state = currentState
        
        switch action {
        case .setCategory(let category):
            state.selectedCategory = category
            
        case .setDifficulty(let difficulty):
            state.selectedDifficulty = difficulty
            
        case .randomizeSetup:
            let allowedCategories = [11, 12, 14, 15] // Film, Music, TV, Video Games
            let allowedDifficulties = ["easy", "medium", "hard"]
            state.selectedCategory = allowedCategories.randomElement()!
            state.selectedDifficulty = allowedDifficulties.randomElement()!
            
        case .startQuiz:
            state.viewState = .loading
            
        case .loadData, .retry:
            state.viewState = .loading
            
        case .dataLoaded(let questions):
            state.questions = questions
            state.currentIndex = 0
            state.score = 0
            state.streak = 0
            if let firstQuestion = questions.first {
                state.currentAnswers = firstQuestion.allAnswers
            }
            state.viewState = .loaded
            
        case .dataFailed:
            state.viewState = .failed
            
        case .submitAnswer(_, let isCorrect):
            if isCorrect {
                state.score += 10 + (state.streak * 2)
                state.streak += 1
            } else {
                state.score = max(0, state.score - 5)
                state.streak = 0
            }
            
        case .advanceToNextQuestion:
            if state.currentIndex < state.questions.count - 1 {
                state.currentIndex += 1
                state.currentAnswers = state.questions[state.currentIndex].allAnswers
            } else {
                state.viewState = .finished
            }
        }
        
        return state
    }
}
