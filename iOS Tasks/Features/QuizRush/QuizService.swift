import Foundation

struct QuizService {
    enum NetworkError: Error {
        case badURL
        case invalidResponse
    }
    
    func fetchQuestions() async throws -> [Question] {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple") else {
            throw NetworkError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let decodedResponse = try JSONDecoder().decode(QuizResponse.self, from: data)
        return decodedResponse.results
    }
}
