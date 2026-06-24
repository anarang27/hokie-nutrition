import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    targetRings
                    picksSection
                }
                .padding(16)
            }
            .background(HokieColors.background)
            .navigationTitle("Hokie Nutrition")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Morning, \(appState.profile.name.components(separatedBy: " ").first ?? "Hokie")!")
                .font(.system(size: 28, weight: .bold))
            Label("Phase: \(appState.profile.goal.label)", systemImage: "figure.strengthtraining.traditional")
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(HokieColors.surfaceContainer)
                .clipShape(Capsule())
        }
    }

    private var targetRings: some View {
        HStack(spacing: 12) {
            targetCard(title: "Calories", value: "\(appState.profile.targets.calories)", unit: "kcal target", color: HokieColors.secondaryContainer)
            targetCard(title: "Protein", value: "\(appState.profile.targets.protein)", unit: "g target", color: HokieColors.primaryContainer)
        }
    }

    private func targetCard(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(HokieColors.onSurfaceVariant)
            Text(value).font(.system(size: 24, weight: .bold)).foregroundStyle(HokieColors.primary)
            Text(unit).font(.caption).foregroundStyle(HokieColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(HokieColors.surfaceContainerLowest)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.3), lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var picksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Best nearby picks")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button("Not feeling it?") {
                    appState.rejectAndPropose(venueSlug: "turner-place", restaurant: "Qdoba")
                }
                .font(.footnote)
                .foregroundStyle(HokieColors.primary)
            }

            ForEach(appState.recommendations) { rec in
                NavigationLink {
                    MealDetailView(item: rec.item, tags: rec.tags)
                } label: {
                    RecommendationCard(item: rec.item, score: rec.score, tags: rec.tags)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct RecommendationCard: View {
    let item: MenuItem
    let score: Double
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 18, weight: .bold))
                    Text("\(item.venueName) • \(item.restaurantName)")
                        .font(.caption)
                        .foregroundStyle(HokieColors.onSurfaceVariant)
                }
                Spacer()
                Text("\(item.calories) kcal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(HokieColors.primary)
            }

            HStack {
                MacroChip(label: "P", value: "\(Int(item.proteinG))g", tint: HokieColors.proteinChip)
                MacroChip(label: "C", value: "\(Int(item.carbsG))g", tint: HokieColors.carbChip)
                MacroChip(label: "F", value: "\(Int(item.fatG))g", tint: HokieColors.fatChip)
                Spacer()
                Text(String(format: "%.0f fit", score))
                    .font(.caption2)
                    .foregroundStyle(HokieColors.onSurfaceVariant)
            }

            if !tags.isEmpty {
                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(HokieColors.surfaceContainer)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(HokieColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
    }
}
