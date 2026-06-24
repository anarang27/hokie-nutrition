import Foundation

struct RecommendationContext {
    var profile: UserProfile
    var meal: MealPeriod
    var quadrant: CampusQuadrant?
    var proposedVenueSlug: String?
    var proposedRestaurant: String?
}

struct ScoredMenuItem: Identifiable {
    let item: MenuItem
    let score: Double
    let tags: [String]
    var id: UUID { item.id }
}

enum RecommendationEngine {
    private struct Weights {
        let protein, calorie, goal, pref: Double
    }

    private static func weights(for goal: GymGoal) -> Weights {
        switch goal {
        case .cutting: Weights(protein: 0.35, calorie: 0.30, goal: 0.20, pref: 0.15)
        case .bulking: Weights(protein: 0.30, calorie: 0.30, goal: 0.25, pref: 0.15)
        case .lean: Weights(protein: 0.35, calorie: 0.25, goal: 0.20, pref: 0.20)
        case .maintenance: Weights(protein: 0.25, calorie: 0.35, goal: 0.20, pref: 0.20)
        case .highProtein: Weights(protein: 0.45, calorie: 0.20, goal: 0.15, pref: 0.20)
        case .balanced: Weights(protein: 0.25, calorie: 0.30, goal: 0.25, pref: 0.20)
        }
    }

    private static let mealShares: [MealPeriod: Double] = [
        .breakfast: 0.25, .lunch: 0.35, .dinner: 0.35, .snack: 0.15,
    ]

    static func mealTargets(from daily: NutritionTargets, meal: MealPeriod) -> NutritionTargets {
        let share = mealShares[meal] ?? 0.35
        return NutritionTargets(
            calories: Int(Double(daily.calories) * share),
            protein: Int(Double(daily.protein) * share),
            carbs: Int(Double(daily.carbs) * share),
            fat: Int(Double(daily.fat) * share)
        )
    }

    static func recommend(items: [MenuItem], context: RecommendationContext, limit: Int = 20) -> [ScoredMenuItem] {
        var candidates = items.filter { passesHardFilters($0, profile: context.profile) }

        if let slug = context.proposedVenueSlug {
            candidates = candidates.filter { $0.venueSlug == slug }
            if let restaurant = context.proposedRestaurant {
                candidates = candidates.filter { $0.restaurantName == restaurant }
            }
        } else if let quadrant = context.quadrant {
            let slugs = Set(CampusLocation.quadrantVenueSlugs[quadrant] ?? [])
            candidates = candidates.filter { slugs.contains($0.venueSlug) }
        }

        let mealTarget = mealTargets(from: context.profile.targets, meal: context.meal)
        let w = weights(for: context.profile.goal)

        let scored = candidates.map { item -> ScoredMenuItem in
            let sProtein = proteinScore(item)
            let sCalorie = calorieScore(item, target: mealTarget.calories, goal: context.profile.goal)
            let sGoal = goalScore(item, profile: context.profile, mealTarget: mealTarget)
            let sPref = prefScore(item, profile: context.profile)
            let score = 100 * (w.protein * sProtein + w.calorie * sCalorie + w.goal * sGoal + w.pref * sPref)
            let tags = explanationTags(item: item, sProtein: sProtein, sCalorie: sCalorie, sGoal: sGoal, profile: context.profile)
            return ScoredMenuItem(item: item, score: score, tags: tags)
        }.sorted { $0.score > $1.score }

        return Array(diversify(scored).prefix(limit))
    }

    private static func passesHardFilters(_ item: MenuItem, profile: UserProfile) -> Bool {
        if !Set(item.allergens).isDisjoint(with: profile.allergens) { return false }
        if item.calories <= 0 { return false }

        switch profile.dietaryPattern {
        case .vegan:
            if !item.dietaryTags.contains(where: { $0.lowercased() == "vegan" }) { return false }
        case .vegetarian:
            if !item.dietaryTags.contains(where: { ["vegetarian", "vegan"].contains($0.lowercased()) }) { return false }
        default:
            break
        }
        return true
    }

    private static func proteinScore(_ item: MenuItem) -> Double {
        guard item.calories > 0 else { return 0 }
        let density = item.proteinG / (Double(item.calories) / 100)
        return min(1, max(0, density / 12))
    }

    private static func calorieScore(_ item: MenuItem, target: Int, goal: GymGoal) -> Double {
        let tolFrac = goal == .bulking ? 0.45 : 0.35
        let tol = tolFrac * Double(target)
        let diff = abs(Double(item.calories - target))
        return min(1, max(0, 1 - diff / tol))
    }

    private static func goalScore(_ item: MenuItem, profile: UserProfile, mealTarget: NutritionTargets) -> Double {
        switch profile.goal {
        case .cutting:
            guard item.calories > 0 else { return 0 }
            return min(1, max(0, (item.proteinG / (Double(item.calories) / 100)) / 14))
        case .bulking:
            return min(1, max(0, Double(item.calories) / (1.5 * Double(mealTarget.calories))))
        case .highProtein:
            return proteinScore(item)
        default:
            return balancedMacroScore(item, target: profile.targets)
        }
    }

    private static func balancedMacroScore(_ item: MenuItem, target: NutritionTargets) -> Double {
        guard item.calories > 0 else { return 0 }
        let pCals = item.proteinG * 4
        let cCals = item.carbsG * 4
        let fCals = item.fatG * 9
        let total = Double(item.calories)
        let tp = Double(target.protein * 4) / Double(target.calories)
        let tc = Double(target.carbs * 4) / Double(target.calories)
        let tf = Double(target.fat * 9) / Double(target.calories)
        let err = (abs(pCals / total - tp) + abs(cCals / total - tc) + abs(fCals / total - tf)) / 2
        return max(0, 1 - err)
    }

    private static func prefScore(_ item: MenuItem, profile: UserProfile) -> Double {
        let disliked = profile.dislikes.contains { d in
            (item.ingredients ?? item.name).localizedCaseInsensitiveContains(d)
        }
        return min(1, max(0, 0.6 + (disliked ? -0.5 : 0)))
    }

    private static func explanationTags(item: MenuItem, sProtein: Double, sCalorie: Double, sGoal: Double, profile: UserProfile) -> [String] {
        var tags: [String] = []
        if sProtein >= 0.75 { tags.append("High protein") }
        if sCalorie >= 0.8 { tags.append("Fits your calories") }
        if profile.goal == .bulking && sGoal >= 0.7 { tags.append("Great for bulking") }
        if (profile.goal == .cutting || profile.goal == .lean) && sGoal >= 0.7 { tags.append("Lean pick") }
        return Array(tags.prefix(3))
    }

    private static func diversify(_ scored: [ScoredMenuItem]) -> [ScoredMenuItem] {
        var result: [ScoredMenuItem] = []
        var venueCounts: [String: Int] = [:]
        let cap = max(2, Int(Double(scored.count) * 0.4))

        for entry in scored {
            let venue = entry.item.venueSlug
            if (venueCounts[venue] ?? 0) >= cap { continue }
            result.append(entry)
            venueCounts[venue, default: 0] += 1
        }

        if result.count < scored.count {
            for entry in scored where !result.contains(where: { $0.id == entry.id }) {
                result.append(entry)
            }
        }
        return result
    }
}
