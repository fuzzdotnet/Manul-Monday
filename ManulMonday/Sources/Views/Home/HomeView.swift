import SwiftUI
import Firebase

struct HomeView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var quizService: QuizService
    @State private var currentQuiz: Quiz?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingQuizDetail = false
    @State private var dailyChallenges: [DailyChallenge] = []
    @State private var conservationFact: ConservationFact?
    
    struct DailyChallenge: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let reward: Int
        var isCompleted: Bool
    }
    
    struct ConservationFact: Identifiable {
        let id = UUID()
        let title: String
        let fact: String
        let source: String
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Welcome section
                    welcomeSection
                    
                    // Current quiz section
                    if isLoading {
                        ProgressView("Loading content...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else if let errorMessage = errorMessage {
                        errorSection(message: errorMessage)
                    } else {
                        // Current quiz card
                        if let quiz = currentQuiz {
                            quizCard(quiz: quiz)
                        }
                        
                        // Daily challenges section
                        dailyChallengesSection
                        
                        // Conservation fact
                        conservationFactSection
                        
                        // Manul info section
                        manulInfoSection
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Manul Monday")
            .onAppear(perform: loadContent)
            .sheet(isPresented: $showingQuizDetail) {
                if let quiz = currentQuiz {
                    QuizDetailView(quiz: quiz)
                        .environmentObject(authService)
                        .environmentObject(quizService)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var welcomeSection: some View {
        VStack(spacing: 15) {
            if let user = authService.user {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Welcome, \(user.displayName)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Your currency: \(user.currency) 💰")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // User avatar placeholder
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Text(String(user.displayName.prefix(1)))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
    }
    
    private func quizCard(quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This Week's Quiz")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(quiz.title)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text(quiz.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.orange)
                            
                            Text("Available until \(formatDate(quiz.expirationDate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 5)
                        
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.orange)
                            
                            Text("\(quiz.rewardCurrency) currency reward")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Quiz image placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "questionmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.orange)
                    }
                }
                
                Button(action: {
                    showingQuizDetail = true
                }) {
                    Text("Start Quiz")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }
    
    private var dailyChallengesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily Challenges")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(spacing: 15) {
                ForEach(dailyChallenges) { challenge in
                    dailyChallengeRow(challenge: challenge)
                    
                    if challenge.id != dailyChallenges.last?.id {
                        Divider()
                            .padding(.horizontal, 15)
                    }
                }
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }
    
    private func dailyChallengeRow(challenge: DailyChallenge) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(challenge.title)
                    .font(.headline)
                    .foregroundColor(challenge.isCompleted ? .secondary : .primary)
                
                Text(challenge.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if challenge.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button(action: {
                    // Start challenge
                }) {
                    Text("\(challenge.reward) 💰")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.orange)
                        .cornerRadius(5)
                }
            }
        }
    }
    
    private var conservationFactSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Conservation Fact")
                .font(.headline)
                .padding(.horizontal, 20)
            
            if let fact = conservationFact {
                VStack(alignment: .leading, spacing: 15) {
                    Text(fact.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(fact.fact)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Spacer()
                        
                        Text("Source: \(fact.source)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    Button(action: {
                        // Open conservation website
                        if let url = URL(string: "https://www.manulworkinggroup.org") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Learn More")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding(.top, 5)
                }
                .padding(15)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var manulInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About Pallas's Cats")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 15) {
                // Manul image placeholder
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                    
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }
                
                Text("The Pallas's cat (Otocolobus manul)")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Pallas's cats, also known as manuls, are small wild cats native to the grasslands and montane steppes of Central Asia. They are about the size of domestic cats but have stockier builds and distinctive flat faces with wide-set ears.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Conservation Status: Near Threatened")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .padding(.top, 5)
                
                Button(action: {
                    // Navigate to more info
                }) {
                    Text("More Manul Facts")
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                }
                .padding(.top, 10)
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }
    
    private func errorSection(message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
                .padding()
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: loadContent) {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 150, height: 40)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Actions
    
    private func loadContent() {
        isLoading = true
        errorMessage = nil
        
        // Load mock data for now
        loadMockData()
        
        // Load current quiz
        quizService.fetchCurrentQuiz { result in
            self.isLoading = false
            
            switch result {
            case .success(let quiz):
                self.currentQuiz = quiz
            case .failure(let error):
                self.errorMessage = "Failed to load content: \(error.localizedDescription)"
            }
        }
    }
    
    private func loadMockData() {
        // Mock daily challenges
        dailyChallenges = [
            DailyChallenge(
                title: "Manul Fact Check",
                description: "Test your knowledge with a daily fact",
                reward: 10,
                isCompleted: false
            ),
            DailyChallenge(
                title: "Conservation Question",
                description: "Learn about conservation efforts",
                reward: 15,
                isCompleted: true
            ),
            DailyChallenge(
                title: "Photo Identification",
                description: "Identify the Pallas cat in a photo",
                reward: 20,
                isCompleted: false
            )
        ]
        
        // Mock conservation fact
        conservationFact = ConservationFact(
            title: "Habitat Loss Threatens Pallas's Cats",
            fact: "Pallas's cats face significant threats from habitat degradation due to mining, infrastructure development, and overgrazing by livestock. Their specialized habitat requirements make them particularly vulnerable to these changes.",
            source: "Manul Working Group"
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationService())
            .environmentObject(QuizService())
    }
}
