import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

@main
struct ManulMondayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var quizService = QuizService()
    @StateObject private var storeService = StoreService()
    
    init() {
        // Set up appearance
        UINavigationBar.appearance().tintColor = UIColor.orange
        UITabBar.appearance().tintColor = UIColor.orange
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quizService)
                .environmentObject(storeService)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set up Firestore settings
        let db = Firestore.firestore()
        let settings = db.settings
        settings.isPersistenceEnabled = true
        db.settings = settings
        
        return true
    }
}
