import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class AuthenticationService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    
    private var db = Firestore.firestore()
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (_, firebaseUser) in
            guard let self = self else { return }
            
            if let firebaseUser = firebaseUser {
                self.fetchUser(with: firebaseUser.uid)
            } else {
                self.user = nil
                self.isAuthenticated = false
            }
        }
    }
    
    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = result?.user else {
                completion(.failure(NSError(domain: "AuthenticationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user"])))
                return
            }
            
            self.fetchUser(with: firebaseUser.uid) { result in
                switch result {
                case .success(let user):
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signUp(email: String, password: String, displayName: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = result?.user else {
                completion(.failure(NSError(domain: "AuthenticationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])))
                return
            }
            
            let newUser = User(
                id: firebaseUser.uid,
                email: email,
                displayName: displayName,
                joinDate: Date(),
                currency: 100,
                isSubscriber: false,
                lastQuizCompleted: nil,
                completedQuizIds: [],
                ownedManulIds: ["standard-manul"], // Default manul
                activeManulId: "standard-manul",
                ownedItemIds: []
            )
            
            do {
                try self.db.collection("users").document(firebaseUser.uid).setData(from: newUser)
                self.user = newUser
                self.isAuthenticated = true
                completion(.success(newUser))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func fetchUser(with userId: String, completion: ((Result<User, Error>) -> Void)? = nil) {
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                completion?(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                let error = NSError(domain: "AuthenticationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document does not exist"])
                completion?(.failure(error))
                return
            }
            
            do {
                let user = try document.data(as: User.self)
                self.user = user
                self.isAuthenticated = true
                completion?(.success(user))
            } catch {
                completion?(.failure(error))
            }
        }
    }
}
