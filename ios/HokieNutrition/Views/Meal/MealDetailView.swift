import SwiftUI

struct MealDetailView: View {
    let item: MenuItem
    let tags: [String]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(HokieColors.surfaceContainer)
                    .frame(height: 200)
                    .overlay {
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(item.venueName.uppercased())
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.9))
                            Text(item.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    macroTile("Calories", "\(item.calories) kcal")
                    macroTile("Protein", "\(Int(item.proteinG))g")
                    macroTile("Carbs", "\(Int(item.carbsG))g")
                    macroTile("Fat", "\(Int(item.fatG))g")
                }

                if !tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Why it fits your goal", systemImage: "dumbbell.fill")
                            .font(.headline)
                            .foregroundStyle(HokieColors.primary)
                        Text(tags.joined(separator: " • "))
                            .foregroundStyle(HokieColors.onSurfaceVariant)
                    }
                    .padding()
                    .background(HokieColors.surfaceContainer)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if let ingredients = item.ingredients {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredients").font(.headline)
                        Text(ingredients).foregroundStyle(HokieColors.onSurfaceVariant)
                    }
                    .padding()
                    .background(HokieColors.surfaceContainerLowest)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if !item.allergens.isEmpty {
                    HStack {
                        Text("Allergens").font(.headline)
                        ForEach(item.allergens, id: \.self) { a in
                            Text(a)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(HokieColors.surfaceContainer)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(HokieColors.background)
        .navigationTitle("Meal Details")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button("Save") {}
                    .buttonStyle(HokieSecondaryButtonStyle())
                Button("Add to Bowl") {}
                    .buttonStyle(HokiePrimaryButtonStyle())
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }

    private func macroTile(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(HokieColors.onSurfaceVariant)
            Text(value).font(.system(size: 20, weight: .bold)).foregroundStyle(HokieColors.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(HokieColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SavedBowlsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your custom bowls and quick-add meals.")
                        .foregroundStyle(HokieColors.onSurfaceVariant)

                    ForEach(appState.savedBowls) { bowl in
                        SavedBowlCard(bowl: bowl)
                    }
                }
                .padding(16)
            }
            .background(HokieColors.background)
            .navigationTitle("Saved")
            .overlay(alignment: .bottomTrailing) {
                Button {} label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(HokieColors.primary)
                        .clipShape(Circle())
                        .shadow(radius: 8, y: 4)
                }
                .padding()
            }
        }
    }
}

struct SavedBowlCard: View {
    let bowl: SavedBowl

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(bowl.restaurantName, systemImage: "fork.knife")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HokieColors.primary)
                Spacer()
                if bowl.isFavorite {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(HokieColors.primaryContainer)
                }
            }
            Text(bowl.name).font(.system(size: 18, weight: .bold))
            Text(bowl.ingredientsSummary)
                .font(.caption)
                .foregroundStyle(HokieColors.onSurfaceVariant)
            HStack {
                MacroChip(label: "Pro", value: "\(Int(bowl.proteinG))g", tint: HokieColors.proteinChip)
                MacroChip(label: "Carb", value: "\(Int(bowl.carbsG))g", tint: HokieColors.carbChip)
                MacroChip(label: "Fat", value: "\(Int(bowl.fatG))g", tint: HokieColors.fatChip)
            }
            HStack {
                Text("\(bowl.calories) kcal").fontWeight(.bold)
                Spacer()
                Button("Save") {}
                    .buttonStyle(HokiePrimaryButtonStyle())
                    .frame(width: 120)
            }
        }
        .padding()
        .background(HokieColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
