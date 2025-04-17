import SwiftUI
import Firebase

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingSignUp = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo and title
            Image(systemName: "pawprint.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.orange)
            
            Text("Manul Monday")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Error message if any
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
            }
            
            // Login form
            VStack(spacing: 15) {
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
                
                Button(action: signIn) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(8)
                .disabled(isLoading)
                
                Button(action: { isShowingSignUp = true }) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.orange)
                }
                .padding(.top, 10)
            }
            .padding(.top, 30)
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .sheet(isPresented: $isShowingSignUp) {
            SignUpView()
                .environmentObject(authService)
        }
    }
    
    private func signIn() {
        isLoading = true
        errorMessage = nil
        
        authService.signIn(email: email, password: password) { result in
            isLoading = false
            
            switch result {
            case .success(_):
                // Successfully signed in, navigation will be handled by the app state
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationService())
    }
}
