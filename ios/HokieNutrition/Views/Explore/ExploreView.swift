import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var appState: AppState
    @State private var filter: ExploreFilter = .all
    @State private var search = ""

    enum ExploreFilter: String, CaseIterable {
        case nearby = "Nearby"
        case all = "All"
        case openNow = "Open Now"
    }

    var filteredVenues: [DiningVenue] {
        var list = appState.venues
        switch filter {
        case .nearby:
            list = list.filter { $0.quadrant == appState.selectedQuadrant }
        case .openNow:
            list = list.filter(\.isOpen)
        case .all:
            break
        }
        if !search.isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(search) }
        }
        return list
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Search dining halls, meals, macros...", text: $search)
                        .padding()
                        .background(HokieColors.surfaceContainerLowest)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    Picker("Filter", selection: $filter) {
                        ForEach(ExploreFilter.allCases, id: \.self) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("Campus Dining")
                        .font(.system(size: 20, weight: .bold))

                    ForEach(filteredVenues) { venue in
                        VenueCard(venue: venue)
                    }

                    Text("Trending Meals")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 8)

                    ForEach(appState.allMenuItems.prefix(4)) { item in
                        NavigationLink {
                            MealDetailView(item: item, tags: item.explanationTags)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name).fontWeight(.semibold)
                                    Text("\(item.restaurantName) @ \(item.venueName)")
                                        .font(.caption)
                                        .foregroundStyle(HokieColors.onSurfaceVariant)
                                }
                                Spacer()
                                Text("\(item.calories) cal")
                                MacroChip(label: "P", value: "\(Int(item.proteinG))g", tint: HokieColors.proteinChip)
                            }
                            .padding()
                            .background(HokieColors.surfaceContainerLowest)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .background(HokieColors.background)
            .navigationTitle("Hokie Nutrition")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct VenueCard: View {
    let venue: DiningVenue

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(venue.name).font(.system(size: 18, weight: .bold))
                Spacer()
                Label(venue.isOpen ? "Open" : "Closed", systemImage: "circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(venue.isOpen ? .green : .red)
            }
            if let miles = venue.distanceMiles {
                Label(String(format: "%.1f mi", miles), systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(HokieColors.onSurfaceVariant)
            }
            Text(venue.categories)
                .font(.caption)
                .foregroundStyle(HokieColors.onSurfaceVariant)
            HStack {
                ForEach(venue.macroTags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(HokieColors.surfaceContainer)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(HokieColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
