import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var joinDate: Date
    var currency: Int
    var isSubscriber: Bool
    var lastQuizCompleted: String?
    var completedQuizIds: [String]
    var ownedManulIds: [String]
    var activeManulId: String?
    var ownedItemIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName
        case joinDate
        case currency
        case isSubscriber
        case lastQuizCompleted
        case completedQuizIds
        case ownedManulIds
        case activeManulId
        case ownedItemIds
    }
    
    init(id: String? = nil, 
         email: String, 
         displayName: String, 
         joinDate: Date = Date(), 
         currency: Int = 100, 
         isSubscriber: Bool = false, 
         lastQuizCompleted: String? = nil, 
         completedQuizIds: [String] = [], 
         ownedManulIds: [String] = [], 
         activeManulId: String? = nil, 
         ownedItemIds: [String] = []) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.joinDate = joinDate
        self.currency = currency
        self.isSubscriber = isSubscriber
        self.lastQuizCompleted = lastQuizCompleted
        self.completedQuizIds = completedQuizIds
        self.ownedManulIds = ownedManulIds
        self.activeManulId = activeManulId
        self.ownedItemIds = ownedItemIds
    }
}
