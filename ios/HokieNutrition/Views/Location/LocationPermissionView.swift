import SwiftUI

struct LocationPermissionView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(HokieColors.surfaceContainer)
                    .frame(width: 180, height: 180)
                Circle()
                    .fill(HokieColors.primary)
                    .frame(width: 80, height: 80)
                Image(systemName: "location.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 8) {
                Text("Find Food Faster")
                    .font(.system(size: 28, weight: .bold))
                Text("We use your location to show you the closest VT dining halls and accurate nutrition menus.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(HokieColors.onSurfaceVariant)
                    .padding(.horizontal)
            }

            Spacer()

            Button {
                appState.hasLocationPermission = true
                appState.selectedQuadrant = .NW
                appState.refreshRecommendations()
            } label: {
                Label("Enable Location", systemImage: "location.circle")
            }
            .buttonStyle(HokiePrimaryButtonStyle())

            Button("Select Dining Hall Manually") {
                appState.selectedQuadrant = .NW
                appState.refreshRecommendations()
            }
            .buttonStyle(HokieSecondaryButtonStyle())

            Text("You can still browse all menus without location access.")
                .font(.footnote)
                .foregroundStyle(HokieColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
        .padding(16)
    }
}
