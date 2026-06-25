import SwiftUI

struct AuthView: View {
    @State private var mode: AuthMode = .signUp

    enum AuthMode: String, CaseIterable {
        case signUp = "Sign Up"
        case signIn = "Log In"
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Auth mode", selection: $mode) {
                ForEach(AuthMode.allCases, id: \.self) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 8)

            if mode == .signUp {
                OnboardingAccountView(isSignIn: false)
            } else {
                OnboardingAccountView(isSignIn: true)
            }
        }
    }
}
