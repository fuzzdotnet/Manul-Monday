import Foundation
import FirebaseFirestoreSwift

struct Manul: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var type: ManulType
    var appliedItemIds: [String]
    var isUnlocked: Bool
    var unlockCost: Int
    var isSubscriberOnly: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case appliedItemIds
        case isUnlocked
        case unlockCost
        case isSubscriberOnly
    }
    
    init(id: String? = nil,
         name: String,
         type: ManulType,
         appliedItemIds: [String] = [],
         isUnlocked: Bool = false,
         unlockCost: Int = 500,
         isSubscriberOnly: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.appliedItemIds = appliedItemIds
        self.isUnlocked = isUnlocked
        self.unlockCost = unlockCost
        self.isSubscriberOnly = isSubscriberOnly
    }
}

enum ManulType: String, Codable {
    case standard
    case snow
    case desert
    case mountain
    case rare
    
    var description: String {
        switch self {
        case .standard:
            return "Standard Manul"
        case .snow:
            return "Snow Manul"
        case .desert:
            return "Desert Manul"
        case .mountain:
            return "Mountain Manul"
        case .rare:
            return "Rare Manul"
        }
    }
}
