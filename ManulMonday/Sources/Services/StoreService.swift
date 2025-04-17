import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class StoreService: ObservableObject {
    @Published var items: [Item] = []
    @Published var manuls: [Manul] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var db = Firestore.firestore()
    
    func fetchAllItems(completion: @escaping (Result<[Item], Error>) -> Void) {
        isLoading = true
        
        db.collection("items")
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let items = try documents.compactMap { try $0.data(as: Item.self) }
                    self.items = items
                    completion(.success(items))
                } catch {
                    self.error = error
                    completion(.failure(error))
                }
            }
    }
    
    func fetchAllManuls(completion: @escaping (Result<[Manul], Error>) -> Void) {
        isLoading = true
        
        db.collection("manuls")
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let manuls = try documents.compactMap { try $0.data(as: Manul.self) }
                    self.manuls = manuls
                    completion(.success(manuls))
                } catch {
                    self.error = error
                    completion(.failure(error))
                }
            }
    }
    
    func purchaseItem(itemId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Get the item
        db.collection("items").document(itemId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                let error = NSError(domain: "StoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Item does not exist"])
                completion(.failure(error))
                return
            }
            
            do {
                let item = try document.data(as: Item.self)
                
                // Get the user
                self.db.collection("users").document(userId).getDocument { (userDoc, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let userDoc = userDoc, userDoc.exists else {
                        let error = NSError(domain: "StoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User does not exist"])
                        completion(.failure(error))
                        return
                    }
                    
                    do {
                        var user = try userDoc.data(as: User.self)
                        
                        // Check if user already owns this item
                        if user.ownedItemIds.contains(itemId) {
                            let error = NSError(domain: "StoreService", code: -2, userInfo: [NSLocalizedDescriptionKey: "User already owns this item"])
                            completion(.failure(error))
                            return
                        }
                        
                        // Check if user has enough currency
                        if user.currency < item.cost {
                            let error = NSError(domain: "StoreService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Not enough currency"])
                            completion(.failure(error))
                            return
                        }
                        
                        // Check if item is subscriber-only and user is not a subscriber
                        if item.isSubscriberOnly && !user.isSubscriber {
                            let error = NSError(domain: "StoreService", code: -4, userInfo: [NSLocalizedDescriptionKey: "This item is for subscribers only"])
                            completion(.failure(error))
                            return
                        }
                        
                        // Update user data
                        user.currency -= item.cost
                        user.ownedItemIds.append(itemId)
                        
                        // Save to Firestore
                        do {
                            try self.db.collection("users").document(userId).setData(from: user)
                            
                            // Record the purchase
                            let purchaseData: [String: Any] = [
                                "userId": userId,
                                "itemId": itemId,
                                "cost": item.cost,
                                "purchasedAt": Timestamp(date: Date())
                            ]
                            
                            self.db.collection("purchases").document().setData(purchaseData) { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(()))
                                }
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func purchaseManul(manulId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Get the manul
        db.collection("manuls").document(manulId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                let error = NSError(domain: "StoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Manul does not exist"])
                completion(.failure(error))
                return
            }
            
            do {
                let manul = try document.data(as: Manul.self)
                
                // Get the user
                self.db.collection("users").document(userId).getDocument { (userDoc, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let userDoc = userDoc, userDoc.exists else {
                        let error = NSError(domain: "StoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User does not exist"])
                        completion(.failure(error))
                        return
                    }
                    
                    do {
                        var user = try userDoc.data(as: User.self)
                        
                        // Check if user already owns this manul
                        if user.ownedManulIds.contains(manulId) {
                            let error = NSError(domain: "StoreService", code: -2, userInfo: [NSLocalizedDescriptionKey: "User already owns this manul"])
                            completion(.failure(error))
                            return
                        }
                        
                        // Check if user has enough currency
                        if user.currency < manul.unlockCost {
                            let error = NSError(domain: "StoreService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Not enough currency"])
                            completion(.failure(error))
                            return
                        }
                        
                        // Check if manul is subscriber-only and user is not a subscriber
                        if manul.isSubscriberOnly && !user.isSubscriber {
                            let error = NSError(domain: "StoreService", code: -4, userInfo: [NSLocalizedDescriptionKey: "This manul is for subscribers only"])
                            completion(.failure(error))
                            return
                        }
                        
                        // Update user data
                        user.currency -= manul.unlockCost
                        user.ownedManulIds.append(manulId)
                        
                        // If this is the user's first manul, set it as active
                        if user.activeManulId == nil {
                            user.activeManulId = manulId
                        }
                        
                        // Save to Firestore
                        do {
                            try self.db.collection("users").document(userId).setData(from: user)
                            
                            // Record the purchase
                            let purchaseData: [String: Any] = [
                                "userId": userId,
                                "manulId": manulId,
                                "cost": manul.unlockCost,
                                "purchasedAt": Timestamp(date: Date())
                            ]
                            
                            self.db.collection("manulPurchases").document().setData(purchaseData) { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(()))
                                }
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
