import SwiftUI
import Firebase

struct ContentView: View {
    @StateObject private var authService = AuthenticationService()
    @State private var isOnboarding = false
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                if isOnboarding {
                    OnboardingView(isOnboarding: $isOnboarding)
                        .environmentObject(authService)
                } else {
                    MainTabView()
                        .environmentObject(authService)
                }
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
        .onAppear {
            // Check if user needs onboarding
            if let user = authService.user, user.ownedManulIds.isEmpty {
                isOnboarding = true
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "questionmark.circle.fill")
                }
            
            ManulView()
                .tabItem {
                    Label("My Manul", systemImage: "pawprint.fill")
                }
            
            StoreView()
                .tabItem {
                    Label("Store", systemImage: "bag.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.orange)
    }
}

// Placeholder views for tabs
// HomeView is now in its own file

// QuizView is now in its own file

// ManulView is now in its own file

// StoreView is now in its own file

// ProfileView is now in its own file

// OnboardingView is now in its own file

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
