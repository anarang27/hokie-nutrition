import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
            ExploreView()
                .tabItem { Label("Explore", systemImage: "magnifyingglass") }
                .tag(1)
            SavedBowlsView()
                .tabItem { Label("Saved", systemImage: "bookmark.fill") }
                .tag(2)
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(3)
        }
        .tint(HokieColors.primary)
    }
}
