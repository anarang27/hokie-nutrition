import SwiftUI

@main
struct HokieNutritionApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if !appState.isAuthenticated {
                OnboardingAccountView()
            } else if !appState.hasCompletedOnboarding {
                OnboardingFlowView()
            } else if !appState.hasLocationPermission && appState.selectedQuadrant == nil {
                LocationPermissionView()
            } else {
                MainTabView()
            }
        }
        .background(HokieColors.background.ignoresSafeArea())
    }
}
