import SwiftUI
import Firebase

struct SignUpView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo and title
                    Image(systemName: "pawprint.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.orange)
                    
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Join the Manul Monday community")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Error message if any
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                    
                    // Sign up form
                    VStack(spacing: 15) {
                        TextField("Display Name", text: $displayName)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        Button(action: signUp) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                        .disabled(isLoading)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
            }
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.primary)
            })
        }
    }
    
    private func signUp() {
        // Validate inputs
        if displayName.isEmpty {
            errorMessage = "Please enter a display name"
            return
        }
        
        if email.isEmpty {
            errorMessage = "Please enter an email address"
            return
        }
        
        if password.isEmpty {
            errorMessage = "Please enter a password"
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        authService.signUp(email: email, password: password, displayName: displayName) { result in
            isLoading = false
            
            switch result {
            case .success(_):
                // Successfully signed up, dismiss the view
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthenticationService())
    }
}
