import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class QuizService: ObservableObject {
    @Published var currentQuiz: Quiz?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var db = Firestore.firestore()
    
    func fetchCurrentQuiz(completion: @escaping (Result<Quiz?, Error>) -> Void) {
        isLoading = true
        
        let now = Date()
        
        db.collection("quizzes")
            .whereField("releaseDate", isLessThanOrEqualTo: now)
            .whereField("expirationDate", isGreaterThanOrEqualTo: now)
            .order(by: "releaseDate", descending: true)
            .limit(to: 1)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.currentQuiz = nil
                    completion(.success(nil))
                    return
                }
                
                do {
                    let quiz = try documents[0].data(as: Quiz.self)
                    self.currentQuiz = quiz
                    completion(.success(quiz))
                } catch {
                    self.error = error
                    completion(.failure(error))
                }
            }
    }
    
    func fetchQuizById(id: String, completion: @escaping (Result<Quiz, Error>) -> Void) {
        isLoading = true
        
        db.collection("quizzes").document(id).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.error = error
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                let error = NSError(domain: "QuizService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Quiz document does not exist"])
                self.error = error
                completion(.failure(error))
                return
            }
            
            do {
                let quiz = try document.data(as: Quiz.self)
                completion(.success(quiz))
            } catch {
                self.error = error
                completion(.failure(error))
            }
        }
    }
    
    func fetchUpcomingQuizzes(limit: Int = 5, completion: @escaping (Result<[Quiz], Error>) -> Void) {
        isLoading = true
        
        let now = Date()
        
        db.collection("quizzes")
            .whereField("releaseDate", isGreaterThan: now)
            .order(by: "releaseDate", descending: false)
            .limit(to: limit)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let quizzes = try documents.compactMap { try $0.data(as: Quiz.self) }
                    completion(.success(quizzes))
                } catch {
                    self.error = error
                    completion(.failure(error))
                }
            }
    }
    
    func submitQuizResults(quizId: String, userId: String, score: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        let batch = db.batch()
        
        // Update user's completed quizzes
        let userRef = db.collection("users").document(userId)
        
        // First, get the current user to update their data
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                let error = NSError(domain: "QuizService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document does not exist"])
                completion(.failure(error))
                return
            }
            
            do {
                var user = try document.data(as: User.self)
                
                // Check if quiz already completed
                if user.completedQuizIds.contains(quizId) {
                    let error = NSError(domain: "QuizService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Quiz already completed"])
                    completion(.failure(error))
                    return
                }
                
                // Get the quiz to determine reward
                self.fetchQuizById(id: quizId) { result in
                    switch result {
                    case .success(let quiz):
                        // Calculate reward based on score percentage
                        let questionCount = quiz.questions.count
                        let scorePercentage = Double(score) / Double(questionCount)
                        let reward = Int(Double(quiz.rewardCurrency) * scorePercentage)
                        
                        // Update user data
                        user.completedQuizIds.append(quizId)
                        user.lastQuizCompleted = quizId
                        user.currency += reward
                        
                        // Save to Firestore
                        do {
                            try userRef.setData(from: user)
                            
                            // Also save quiz result
                            let resultData: [String: Any] = [
                                "userId": userId,
                                "quizId": quizId,
                                "score": score,
                                "maxScore": questionCount,
                                "reward": reward,
                                "completedAt": Timestamp(date: Date())
                            ]
                            
                            let resultRef = self.db.collection("quizResults").document()
                            resultRef.setData(resultData) { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(reward))
                                }
                            }
                        } catch {
                            completion(.failure(error))
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
