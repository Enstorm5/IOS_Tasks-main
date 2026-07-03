import Foundation
import SwiftUI

@MainActor
class QuizRushViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case failed
        case finished
    }
    
    @Published var state: ViewState = .loading
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var currentAnswers: [String] = []
    
    private let service = QuizService()
    
    func loadData() {
        state = .loading
        
        Task {
            do {
                let fetchedQuestions = try await service.fetchQuestions()
                self.questions = fetchedQuestions
                self.currentIndex = 0
                self.score = 0
                self.streak = 0
                
                if let firstQuestion = fetchedQuestions.first {
                    self.currentAnswers = firstQuestion.allAnswers
                }
                self.state = .loaded
            } catch {
                self.state = .failed
            }
        }
    }
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    func submitAnswer(_ answer: String) -> Bool {
        guard let current = currentQuestion else { return false }
        
        let isCorrect = answer == current.decodedCorrectAnswer
        if isCorrect {
            score += 10 + (streak * 2) // Bonus for streaks
            streak += 1
        } else {
            score = max(0, score - 5) // Small penalty
            streak = 0
        }
        
        // Wait a small delay before moving to next question for animation to complete
        // Since view layer handles animation trigger, we just advance state immediately,
        // but it's better to let view do a delay. Let's actually provide a function
        // that view calls to advance after animation.
        return isCorrect
    }
    
    func advanceToNextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            currentAnswers = questions[currentIndex].allAnswers
        } else {
            state = .finished
        }
    }
    
    func retry() {
        loadData()
    }
}
