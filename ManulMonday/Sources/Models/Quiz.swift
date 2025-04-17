import Foundation
import FirebaseFirestoreSwift

struct Quiz: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var releaseDate: Date
    var expirationDate: Date
    var questions: [Question]
    var rewardCurrency: Int
    var isSpecialEvent: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case releaseDate
        case expirationDate
        case questions
        case rewardCurrency
        case isSpecialEvent
    }
    
    init(id: String? = nil,
         title: String,
         description: String,
         releaseDate: Date,
         expirationDate: Date,
         questions: [Question],
         rewardCurrency: Int = 100,
         isSpecialEvent: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.releaseDate = releaseDate
        self.expirationDate = expirationDate
        self.questions = questions
        self.rewardCurrency = rewardCurrency
        self.isSpecialEvent = isSpecialEvent
    }
}

struct Question: Identifiable, Codable {
    var id: String
    var text: String
    var imageURL: String?
    var type: QuestionType
    var options: [String]
    var correctAnswerIndex: Int
    var explanation: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case imageURL
        case type
        case options
        case correctAnswerIndex
        case explanation
    }
    
    init(id: String = UUID().uuidString,
         text: String,
         imageURL: String? = nil,
         type: QuestionType,
         options: [String],
         correctAnswerIndex: Int,
         explanation: String) {
        self.id = id
        self.text = text
        self.imageURL = imageURL
        self.type = type
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
    }
}

enum QuestionType: String, Codable {
    case multipleChoice
    case trueFalse
    case imageIdentification
    
    var description: String {
        switch self {
        case .multipleChoice:
            return "Multiple Choice"
        case .trueFalse:
            return "True/False"
        case .imageIdentification:
            return "Image Identification"
        }
    }
}
