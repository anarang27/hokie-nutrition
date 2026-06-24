import SwiftUI

struct OnboardingAccountView: View {
    @EnvironmentObject var appState: AppState
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer(minLength: 40)

            ProgressView(value: 0.15)
                .tint(HokieColors.primary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome to Hokie Nutrition")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(HokieColors.onBackground)
                Text("Let's set up your profile to personalize your macro tracking journey.")
                    .font(.system(size: 15))
                    .foregroundStyle(HokieColors.onSurfaceVariant)
            }

            VStack(alignment: .leading, spacing: 16) {
                field(title: "Full Name", text: $name, placeholder: "Enter your name", keyboard: .default)
                field(title: "VT Email", text: $email, placeholder: "student@vt.edu", keyboard: .emailAddress)
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
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

            Button("Continue →") {
                errorMessage = appState.signUp(name: name, email: email, password: password)
            }
            .buttonStyle(HokiePrimaryButtonStyle())
        }
        .padding(16)
        .navigationTitle("Hokie Nutrition")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func field(title: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType) -> some View {
        VStack( alignment: .leading, spacing: 6) {
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
