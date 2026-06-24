import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Circle()
                            .fill(HokieColors.surfaceContainer)
                            .frame(width: 88, height: 88)
                            .overlay {
                                Text(appState.profile.name.prefix(1).uppercased())
                                    .font(.title.weight(.bold))
                                    .foregroundStyle(HokieColors.primary)
                            }
                        Text(appState.profile.name)
                            .font(.system(size: 22, weight: .bold))
                        Text(appState.profile.email)
                            .font(.caption)
                            .foregroundStyle(HokieColors.onSurfaceVariant)
                    }
                    .padding(.top, 8)

                    profileCard(title: "Your Goal", icon: "dumbbell.fill") {
                        Text(appState.profile.goal.label)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(HokieColors.primary)
                        Text("Daily target: \(appState.profile.targets.calories) kcal")
                            .foregroundStyle(HokieColors.onSurfaceVariant)
                    }

                    profileCard(title: "Body Stats", icon: "figure.stand") {
                        let (ft, inch) = UnitConverter.cmToFeetInches(appState.profile.heightCm)
                        statRow("Height", "\(ft)' \(inch)\"")
                        statRow("Weight", String(format: "%.0f lbs", UnitConverter.kgToLbs(appState.profile.weightKg)))
                    }

                    profileCard(title: "Preferences", icon: "slider.horizontal.3") {
                        preferenceRow("Dietary Restrictions", appState.profile.dietaryPattern.label)
                        preferenceRow("Notification Settings", "Push")
                        preferenceRow("Location", appState.hasLocationPermission ? "Enabled" : "Manual")
                    }

                    Button("Sign Out") {
                        appState.isAuthenticated = false
                        appState.hasCompletedOnboarding = false
                    }
                    .buttonStyle(HokieSecondaryButtonStyle())
                }
                .padding(16)
            }
            .background(HokieColors.background)
            .navigationTitle("Profile")
        }
    }

    private func profileCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(HokieColors.primary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(HokieColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
    }

    private func preferenceRow(_ title: String, _ subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                Text(subtitle).font(.caption).foregroundStyle(HokieColors.onSurfaceVariant)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(HokieColors.outline)
        }
        .padding(.vertical, 4)
    }
}
