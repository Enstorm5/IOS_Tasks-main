import Foundation

struct QuizResponse: Codable {
    let results: [Question]
}

struct Question: Codable, Equatable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    var decodedQuestion: String {
        question.htmlDecoded
    }
    
    var decodedCorrectAnswer: String {
        correct_answer.htmlDecoded
    }
    
    var decodedIncorrectAnswers: [String] {
        incorrect_answers.map { $0.htmlDecoded }
    }
    
    var allAnswers: [String] {
        var answers = decodedIncorrectAnswers
        answers.append(decodedCorrectAnswer)
        return answers.shuffled()
    }
}

extension String {

    var htmlDecoded: String {
        return self
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&eacute;", with: "é")
            .replacingOccurrences(of: "&Uuml;", with: "Ü")
            .replacingOccurrences(of: "&rsquo;", with: "’")
            .replacingOccurrences(of: "&ldquo;", with: "“")
            .replacingOccurrences(of: "&rdquo;", with: "”")
    }
}
