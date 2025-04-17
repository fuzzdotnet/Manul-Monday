import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var isShowingEditProfile = false
    @State private var isShowingSettings = false
    @State private var isShowingSubscription = false
    @State private var isShowingAbout = false
    @State private var isShowingLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile header
                    profileHeader
                    
                    // Stats section
                    statsSection
                    
                    // Menu options
                    menuSection
                    
                    // App info
                    appInfoSection
                    
                    // Logout button
                    Button(action: {
                        isShowingLogoutConfirmation = true
                    }) {
                        Text("Sign Out")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $isShowingEditProfile) {
                EditProfileView()
                    .environmentObject(authService)
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
                    .environmentObject(authService)
            }
            .sheet(isPresented: $isShowingSubscription) {
                SubscriptionView()
                    .environmentObject(authService)
            }
            .sheet(isPresented: $isShowingAbout) {
                AboutView()
            }
            .alert(isPresented: $isShowingLogoutConfirmation) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        authService.signOut()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    // MARK: - Sections
    
    private var profileHeader: some View {
        VStack(spacing: 15) {
            if let user = authService.user {
                // User avatar
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Text(String(user.displayName.prefix(1)))
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Text(user.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Member since \(formatDate(user.joinDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    isShowingEditProfile = true
                }) {
                    Text("Edit Profile")
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                }
                .padding(.top, 5)
            }
        }
        .padding(.top, 20)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Stats")
                .font(.headline)
                .padding(.horizontal, 20)
            
            HStack(spacing: 15) {
                statCard(
                    title: "Currency",
                    value: "\(authService.user?.currency ?? 0)",
                    icon: "dollarsign.circle.fill",
                    color: .orange
                )
                
                statCard(
                    title: "Manuls",
                    value: "\(authService.user?.ownedManulIds.count ?? 0)",
                    icon: "pawprint.fill",
                    color: .purple
                )
                
                statCard(
                    title: "Quizzes",
                    value: "\(authService.user?.completedQuizIds.count ?? 0)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Settings")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                menuItem(
                    title: "App Settings",
                    icon: "gear",
                    color: .gray
                ) {
                    isShowingSettings = true
                }
                
                Divider()
                    .padding(.horizontal, 15)
                
                menuItem(
                    title: "Subscription",
                    icon: "star.fill",
                    color: .yellow
                ) {
                    isShowingSubscription = true
                }
                
                Divider()
                    .padding(.horizontal, 15)
                
                menuItem(
                    title: "Notifications",
                    icon: "bell.fill",
                    color: .blue
                ) {
                    // Show notifications settings
                }
                
                Divider()
                    .padding(.horizontal, 15)
                
                menuItem(
                    title: "About",
                    icon: "info.circle.fill",
                    color: .orange
                ) {
                    isShowingAbout = true
                }
            }
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }
    
    private func menuItem(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
        }
    }
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("App Info")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.orange)
                    .padding(.top, 10)
                
                Text("Manul Monday")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Supporting Pallas cat conservation")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
}

// MARK: - Supporting Views

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthenticationService
    
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Display Name", text: $displayName)
                    
                    if let user = authService.user {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: saveProfile) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Save Changes")
                        }
                    }
                    .disabled(isLoading || displayName.isEmpty)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                if let user = authService.user {
                    displayName = user.displayName
                }
            }
        }
    }
    
    private func saveProfile() {
        guard let user = authService.user, let userId = user.id else {
            errorMessage = "User not found"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Update user profile in Firestore
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "displayName": displayName
        ]) { error in
            isLoading = false
            
            if let error = error {
                errorMessage = "Failed to update profile: \(error.localizedDescription)"
            } else {
                // Update local user object
                var updatedUser = user
                updatedUser.displayName = displayName
                authService.user = updatedUser
                
                // Dismiss the view
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthenticationService
    
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var hapticFeedbackEnabled = true
    @State private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        Toggle("Quiz Reminders", isOn: .constant(true))
                        Toggle("Daily Challenges", isOn: .constant(true))
                        Toggle("Conservation Updates", isOn: .constant(true))
                    }
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section(header: Text("Sound & Haptics")) {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                    Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                }
                
                Section(header: Text("Data & Privacy")) {
                    Button(action: {
                        // Show privacy policy
                    }) {
                        Text("Privacy Policy")
                    }
                    
                    Button(action: {
                        // Show terms of service
                    }) {
                        Text("Terms of Service")
                    }
                    
                    Button(action: {
                        // Clear cache
                    }) {
                        Text("Clear Cache")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // App logo
                    Image(systemName: "pawprint.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.orange)
                        .padding(.top, 20)
                    
                    Text("Manul Monday")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // App description
                    VStack(alignment: .leading, spacing: 15) {
                        Text("About the App")
                            .font(.headline)
                        
                        Text("Manul Monday is dedicated to raising awareness and supporting conservation efforts for the Pallas's cat (Otocolobus manul), also known as the manul. Through weekly quizzes, daily challenges, and educational content, we aim to engage users in learning about these fascinating wild cats while contributing to their protection in the wild.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Conservation info
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Conservation Partner")
                            .font(.headline)
                        
                        Text("We proudly partner with the Manul Working Group, an international team of researchers and conservationists dedicated to studying and protecting Pallas's cats across their range.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // Open conservation website
                            if let url = URL(string: "https://www.manulworkinggroup.org") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Visit Manul Working Group")
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        .padding(.top, 5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Credits
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Credits")
                            .font(.headline)
                        
                        Text("Developed by: Your Name\nDesign: Your Designer\nContent: Your Content Team")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("About")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationService())
    }
}
