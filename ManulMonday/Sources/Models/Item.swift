import Foundation
import FirebaseFirestoreSwift

struct Item: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var type: ItemType
    var cost: Int
    var imageName: String
    var isSubscriberOnly: Bool
    var isUnlocked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case type
        case cost
        case imageName
        case isSubscriberOnly
        case isUnlocked
    }
    
    init(id: String? = nil,
         name: String,
         description: String,
         type: ItemType,
         cost: Int,
         imageName: String,
         isSubscriberOnly: Bool = false,
         isUnlocked: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.cost = cost
        self.imageName = imageName
        self.isSubscriberOnly = isSubscriberOnly
        self.isUnlocked = isUnlocked
    }
}

enum ItemType: String, Codable {
    case habitat
    case accessory
    case toy
    case food
    case background
    
    var description: String {
        switch self {
        case .habitat:
            return "Habitat Item"
        case .accessory:
            return "Accessory"
        case .toy:
            return "Toy"
        case .food:
            return "Food"
        case .background:
            return "Background"
        }
    }
}
