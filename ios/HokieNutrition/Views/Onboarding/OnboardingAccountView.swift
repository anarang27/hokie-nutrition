import SwiftUI

struct OnboardingAccountView: View {
    @EnvironmentObject var appState: AppState
    let isSignIn: Bool

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer(minLength: 40)

            if !isSignIn {
                ProgressView(value: 0.15)
                    .tint(HokieColors.primary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(isSignIn ? "Welcome back" : "Welcome to Hokie Nutrition")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(HokieColors.onBackground)
                Text(isSignIn
                     ? "Sign in with your VT email to continue."
                     : "Let's set up your profile to personalize your macro tracking journey.")
                    .font(.system(size: 15))
                    .foregroundStyle(HokieColors.onSurfaceVariant)
            }

            if !appState.isSupabaseConfigured {
                Text("Supabase not configured — using offline demo mode. Copy Supabase.plist.example to Supabase.plist.")
                    .font(.footnote)
                    .foregroundStyle(HokieColors.onSurfaceVariant)
                    .padding(12)
                    .background(HokieColors.surfaceContainer)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 16) {
                if !isSignIn {
                    field(title: "Full Name", text: $name, placeholder: "Enter your name", keyboard: .default)
                }
                field(title: "VT Email", text: $email, placeholder: "student@vt.edu", keyboard: .emailAddress)
                SecureField("Password", text: $password)
                    .textContentType(isSignIn ? .password : .newPassword)
                    .padding()
                    .background(HokieColors.surfaceContainerLowest)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(HokieColors.outlineVariant))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(HokieColors.error)
            }

            Spacer()

            Button(isSignIn ? "Sign In" : "Continue →") {
                Task { await submit() }
            }
            .buttonStyle(HokiePrimaryButtonStyle())
            .disabled(isSubmitting)
        }
        .padding(16)
        .navigationTitle("Hokie Nutrition")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }

        if isSignIn {
            errorMessage = await appState.signIn(email: email, password: password)
        } else {
            errorMessage = await appState.signUp(name: name, email: email, password: password)
        }
    }

    private func field(title: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                .autocorrectionDisabled()
                .padding()
                .background(HokieColors.surfaceContainerLowest)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(HokieColors.outlineVariant))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
