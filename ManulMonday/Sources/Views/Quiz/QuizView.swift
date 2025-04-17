import SwiftUI
import Firebase

struct QuizView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var quizService: QuizService
    @State private var currentQuiz: Quiz?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isShowingQuizDetail = false
    @State private var upcomingQuizzes: [Quiz] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView("Loading quizzes...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text("Error")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: loadQuizzes) {
                            Text("Try Again")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 150, height: 40)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Current quiz section
                            if let quiz = currentQuiz {
                                currentQuizSection(quiz: quiz)
                            } else {
                                noCurrentQuizSection()
                            }
                            
                            // Upcoming quizzes section
                            upcomingQuizzesSection()
                            
                            // Daily challenges section
                            dailyChallengesSection()
                            
                            // Quiz history section
                            quizHistorySection()
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Quizzes")
            .onAppear(perform: loadQuizzes)
            .sheet(isPresented: $isShowingQuizDetail) {
                if let quiz = currentQuiz {
                    QuizDetailView(quiz: quiz)
                        .environmentObject(authService)
                        .environmentObject(quizService)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private func currentQuizSection(quiz: Quiz) -> some View {
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
                    isShowingQuizDetail = true
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
    
    private func noCurrentQuizSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This Week's Quiz")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(alignment: .center, spacing: 15) {
                Image(systemName: "calendar.badge.clock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.orange)
                    .padding(.top, 20)
                
                Text("No Active Quiz")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Check back on Monday for the next quiz!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .padding(15)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }
    
    private func upcomingQuizzesSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Upcoming Quizzes")
                .font(.headline)
                .padding(.horizontal, 20)
            
            if upcomingQuizzes.isEmpty {
                VStack(alignment: .center, spacing: 10) {
                    Text("No upcoming quizzes scheduled yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(upcomingQuizzes) { quiz in
                        upcomingQuizRow(quiz: quiz)
                        
                        if quiz.id != upcomingQuizzes.last?.id {
                            Divider()
                                .padding(.horizontal, 15)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func upcomingQuizRow(quiz: Quiz) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(quiz.title)
                    .font(.headline)
                
                Text("Available on \(formatDate(quiz.releaseDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(quiz.rewardCurrency) 💰")
                .font(.subheadline)
                .foregroundColor(.orange)
        }
        .padding(15)
    }
    
    private func dailyChallengesSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily Challenges")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(spacing: 15) {
                dailyChallengeRow(
                    title: "Manul Fact Check",
                    description: "Test your knowledge with a daily fact",
                    reward: 10,
                    isCompleted: false
                )
                
                Divider()
                    .padding(.horizontal, 15)
                
                dailyChallengeRow(
                    title: "Conservation Question",
                    description: "Learn about conservation efforts",
                    reward: 15,
                    isCompleted: true
                )
                
                Divider()
                    .padding(.horizontal, 15)
                
                dailyChallengeRow(
                    title: "Photo Identification",
                    description: "Identify the Pallas cat in a photo",
                    reward: 20,
                    isCompleted: false
                )
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }
    
    private func dailyChallengeRow(title: String, description: String, reward: Int, isCompleted: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Text("\(reward) 💰")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
        }
    }
    
    private func quizHistorySection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quiz History")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(alignment: .center, spacing: 15) {
                if let user = authService.user, !user.completedQuizIds.isEmpty {
                    Text("You've completed \(user.completedQuizIds.count) quizzes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 10)
                    
                    Button(action: {
                        // Show quiz history
                    }) {
                        Text("View History")
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                            .padding(.vertical, 5)
                    }
                } else {
                    Text("You haven't completed any quizzes yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(15)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Actions
    
    private func loadQuizzes() {
        isLoading = true
        errorMessage = nil
        
        // Load current quiz
        quizService.fetchCurrentQuiz { result in
            switch result {
            case .success(let quiz):
                self.currentQuiz = quiz
                
                // Load upcoming quizzes
                self.quizService.fetchUpcomingQuizzes { result in
                    self.isLoading = false
                    
                    switch result {
                    case .success(let quizzes):
                        self.upcomingQuizzes = quizzes
                    case .failure(let error):
                        self.errorMessage = "Failed to load upcoming quizzes: \(error.localizedDescription)"
                    }
                }
                
            case .failure(let error):
                self.isLoading = false
                self.errorMessage = "Failed to load current quiz: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Quiz Detail View

struct QuizDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var quizService: QuizService
    
    let quiz: Quiz
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswerIndex: Int?
    @State private var correctAnswers = 0
    @State private var showingExplanation = false
    @State private var isQuizCompleted = false
    @State private var earnedReward: Int?
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                if isQuizCompleted {
                    quizCompletedView
                } else {
                    quizQuestionView
                }
            }
            .navigationTitle("Quiz: \(quiz.title)")
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
                    .foregroundColor(.orange)
            })
            .alert(item: Binding<QuizError?>(
                get: { errorMessage != nil ? QuizError(message: errorMessage!) : nil },
                set: { errorMessage = $0?.message }
            )) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private var quizQuestionView: some View {
        VStack(spacing: 20) {
            // Progress indicator
            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(quiz.questions.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                .padding(.horizontal, 20)
            
            Text("Question \(currentQuestionIndex + 1) of \(quiz.questions.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(spacing: 20) {
                    let question = quiz.questions[currentQuestionIndex]
                    
                    // Question text
                    Text(question.text)
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Question image if available
                    if let imageURL = question.imageURL {
                        // Placeholder for actual image loading
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                            
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Answer options
                    VStack(spacing: 12) {
                        ForEach(0..<question.options.count, id: \.self) { index in
                            Button(action: {
                                if !showingExplanation {
                                    selectedAnswerIndex = index
                                }
                            }) {
                                HStack {
                                    Text(question.options[index])
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    if showingExplanation {
                                        if index == question.correctAnswerIndex {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else if index == selectedAnswerIndex {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    } else if index == selectedAnswerIndex {
                                        Image(systemName: "circle.fill")
                                            .foregroundColor(.orange)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(answerBackgroundColor(for: index))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(answerBorderColor(for: index), lineWidth: 2)
                                )
                            }
                            .disabled(showingExplanation)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Explanation when answer is selected
                    if showingExplanation {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Explanation")
                                .font(.headline)
                            
                            Text(question.explanation)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 100) // Extra padding for button at bottom
            }
            
            // Bottom button
            VStack {
                Spacer()
                
                Button(action: {
                    if showingExplanation {
                        moveToNextQuestion()
                    } else if selectedAnswerIndex != nil {
                        checkAnswer()
                    }
                }) {
                    Text(showingExplanation ? (currentQuestionIndex < quiz.questions.count - 1 ? "Next Question" : "Complete Quiz") : "Check Answer")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(selectedAnswerIndex != nil ? Color.orange : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(selectedAnswerIndex == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    private var quizCompletedView: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            Text("Quiz Completed!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You got \(correctAnswers) out of \(quiz.questions.count) questions correct")
                .font(.title3)
                .multilineTextAlignment(.center)
            
            if let earnedReward = earnedReward {
                VStack(spacing: 10) {
                    Text("You earned")
                        .font(.headline)
                    
                    Text("\(earnedReward) 💰")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("currency")
                        .font(.headline)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(15)
            }
            
            if isSubmitting {
                ProgressView("Saving results...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Return to Quizzes")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func answerBackgroundColor(for index: Int) -> Color {
        if !showingExplanation {
            return index == selectedAnswerIndex ? Color.orange.opacity(0.1) : Color.white
        } else {
            if index == question.correctAnswerIndex {
                return Color.green.opacity(0.1)
            } else if index == selectedAnswerIndex && index != question.correctAnswerIndex {
                return Color.red.opacity(0.1)
            } else {
                return Color.white
            }
        }
    }
    
    private func answerBorderColor(for index: Int) -> Color {
        if !showingExplanation {
            return index == selectedAnswerIndex ? Color.orange : Color.gray.opacity(0.3)
        } else {
            if index == question.correctAnswerIndex {
                return Color.green
            } else if index == selectedAnswerIndex && index != question.correctAnswerIndex {
                return Color.red
            } else {
                return Color.gray.opacity(0.3)
            }
        }
    }
    
    private var question: Question {
        quiz.questions[currentQuestionIndex]
    }
    
    // MARK: - Actions
    
    private func checkAnswer() {
        showingExplanation = true
        
        if selectedAnswerIndex == question.correctAnswerIndex {
            correctAnswers += 1
        }
    }
    
    private func moveToNextQuestion() {
        if currentQuestionIndex < quiz.questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
            showingExplanation = false
        } else {
            completeQuiz()
        }
    }
    
    private func completeQuiz() {
        isQuizCompleted = true
        
        guard let userId = authService.user?.id else {
            errorMessage = "User not found"
            return
        }
        
        isSubmitting = true
        
        quizService.submitQuizResults(quizId: quiz.id ?? "", userId: userId, score: correctAnswers) { result in
            isSubmitting = false
            
            switch result {
            case .success(let reward):
                self.earnedReward = reward
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

// Helper for error alerts
struct QuizError: Identifiable {
    let id = UUID()
    let message: String
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
            .environmentObject(AuthenticationService())
            .environmentObject(QuizService())
    }
}
