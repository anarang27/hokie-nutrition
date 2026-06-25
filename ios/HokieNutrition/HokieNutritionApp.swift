import SwiftUI

@main
struct HokieNutritionApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .task { await appState.bootstrap() }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isBootstrapping {
                LoadingView()
            } else if !appState.isAuthenticated {
                AuthView()
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

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(HokieColors.primary)
            Text("Loading Hokie Nutrition...")
                .foregroundStyle(HokieColors.onSurfaceVariant)
        }
    }
}
