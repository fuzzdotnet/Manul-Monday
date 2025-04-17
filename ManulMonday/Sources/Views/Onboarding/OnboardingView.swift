import SwiftUI
import Firebase

struct OnboardingView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var storeService: StoreService
    @Binding var isOnboarding: Bool
    
    @State private var currentStep = 0
    @State private var selectedManulType: ManulType = .standard
    @State private var manulName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let steps = ["Welcome", "Choose Manul", "Name Manul", "Complete"]
    
    var body: some View {
        VStack {
            // Progress indicator
            HStack {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(currentStep >= index ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                    
                    if index < steps.count - 1 {
                        Rectangle()
                            .fill(currentStep > index ? Color.orange : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    switch currentStep {
                    case 0:
                        welcomeStep
                    case 1:
                        chooseManulStep
                    case 2:
                        nameManulStep
                    case 3:
                        completeStep
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
            
            // Error message if any
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
            }
            
            // Navigation buttons
            HStack {
                if currentStep > 0 {
                    Button(action: {
                        withAnimation {
                            currentStep -= 1
                        }
                    }) {
                        Text("Back")
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                            .frame(width: 100, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                    }
                }
                
                Spacer()
                
                Button(action: {
                    nextStep()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(currentStep == steps.count - 1 ? "Start Adventure" : "Next")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 150, height: 50)
                .background(Color.orange)
                .cornerRadius(10)
                .disabled(isLoading || (currentStep == 2 && manulName.isEmpty))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .onAppear {
            // Load available manuls
            storeService.fetchAllManuls { _ in }
        }
    }
    
    // MARK: - Steps
    
    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "pawprint.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.orange)
            
            Text("Welcome to Manul Monday!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Your weekly Pallas cat adventure begins now. Let's get you set up with your very own manul!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 15) {
                infoRow(icon: "calendar.badge.clock", title: "Weekly Quizzes", description: "Complete quizzes every Monday to earn currency")
                
                infoRow(icon: "pawprint.fill", title: "Adopt a Manul", description: "Choose and customize your own Pallas cat")
                
                infoRow(icon: "bag.fill", title: "Collect Items", description: "Spend currency on items for your manul")
                
                infoRow(icon: "heart.fill", title: "Support Conservation", description: "Learn about Pallas cat conservation efforts")
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    private var chooseManulStep: some View {
        VStack(spacing: 20) {
            Text("Choose Your Manul")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Select the type of Pallas cat you'd like to adopt")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.top, 5)
            
            // Manul selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach([ManulType.standard, ManulType.snow, ManulType.desert], id: \.self) { type in
                        manulCard(type: type)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
            }
            
            Text("You'll start with a \(selectedManulType.description). You can unlock more manuls later!")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.top, 10)
            
            Spacer()
        }
    }
    
    private var nameManulStep: some View {
        VStack(spacing: 20) {
            Text("Name Your Manul")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("What would you like to call your \(selectedManulType.description)?")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.top, 5)
            
            // Manul image placeholder
            Image(systemName: "pawprint.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(.orange)
                .padding(.vertical, 20)
            
            // Name input
            TextField("Enter a name", text: $manulName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 20)
            
            Text("This is what you'll call your manul in the app")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.top, 10)
            
            Spacer()
        }
    }
    
    private var completeStep: some View {
        VStack(spacing: 20) {
            Text("All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("\(manulName) is ready for adventure")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.top, 5)
            
            // Manul image placeholder
            Image(systemName: "pawprint.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(.orange)
                .padding(.vertical, 20)
            
            VStack(alignment: .leading, spacing: 15) {
                infoRow(icon: "calendar", title: "Check back on Monday", description: "For your first weekly quiz")
                
                infoRow(icon: "dollarsign.circle", title: "Earn Currency", description: "Complete daily challenges for more rewards")
                
                infoRow(icon: "bag", title: "Visit the Store", description: "Buy items to customize your manul's habitat")
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Views
    
    private func infoRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func manulCard(type: ManulType) -> some View {
        VStack {
            // Manul image placeholder
            Image(systemName: "pawprint.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(type == selectedManulType ? .orange : .gray)
                .padding(.vertical, 10)
            
            Text(type.description)
                .font(.headline)
            
            Text(manulDescription(for: type))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 120)
                .padding(.top, 5)
        }
        .padding()
        .frame(width: 150, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(type == selectedManulType ? Color.orange : Color.clear, lineWidth: 3)
        )
        .onTapGesture {
            withAnimation {
                selectedManulType = type
            }
        }
    }
    
    private func manulDescription(for type: ManulType) -> String {
        switch type {
        case .standard:
            return "The classic Pallas cat with distinctive round face and thick fur"
        case .snow:
            return "Adapted to snowy environments with lighter coloration"
        case .desert:
            return "Sandy-colored coat perfect for arid environments"
        case .mountain:
            return "Rugged mountain dweller with extra thick fur"
        case .rare:
            return "A rare variant with unique markings"
        }
    }
    
    // MARK: - Actions
    
    private func nextStep() {
        if currentStep < steps.count - 1 {
            withAnimation {
                currentStep += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        guard let userId = authService.user?.id else {
            errorMessage = "User not found"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Create the manul in Firestore
        let manulId = "\(selectedManulType.rawValue)-\(UUID().uuidString)"
        let manul = Manul(
            id: manulId,
            name: manulName,
            type: selectedManulType,
            appliedItemIds: [],
            isUnlocked: true,
            unlockCost: 0,
            isSubscriberOnly: false
        )
        
        // Update user with the new manul
        let db = Firestore.firestore()
        
        // First, save the manul
        do {
            try db.collection("manuls").document(manulId).setData(from: manul)
            
            // Then update the user
            db.collection("users").document(userId).getDocument { [weak self] (document, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = document, document.exists else {
                    self.isLoading = false
                    self.errorMessage = "User document not found"
                    return
                }
                
                do {
                    var user = try document.data(as: User.self)
                    user.ownedManulIds = [manulId]
                    user.activeManulId = manulId
                    
                    try db.collection("users").document(userId).setData(from: user) { error in
                        self.isLoading = false
                        
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                        } else {
                            // Update the auth service user
                            self.authService.fetchUser(with: userId)
                            
                            // Complete onboarding
                            self.isOnboarding = false
                        }
                    }
                } catch {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isOnboarding: .constant(true))
            .environmentObject(AuthenticationService())
            .environmentObject(StoreService())
    }
}
