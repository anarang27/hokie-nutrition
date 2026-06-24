import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var hasLocationPermission = false
    @Published var selectedQuadrant: CampusQuadrant?
    @Published var profile = UserProfile()
    @Published var recommendations: [ScoredMenuItem] = []
    @Published var savedBowls: [SavedBowl] = []
    @Published var venues: [DiningVenue] = []
    @Published var allMenuItems: [MenuItem] = []

    init() {
        seedSampleData()
    }

    func signUp(name: String, email: String, password: String) -> String? {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "Please enter your name."
        }
        guard VTEmailValidator.isValid(email) else {
            return "Please use your @vt.edu email."
        }
        guard password.count >= 8, password.contains(where: \.isLetter), password.contains(where: \.isNumber) else {
            return "Password must be at least 8 characters with a letter and number."
        }
        profile.name = name.trimmingCharacters(in: .whitespaces)
        profile.email = email.trimmingCharacters(in: .whitespaces).lowercased()
        isAuthenticated = true
        return nil
    }

    func completeOnboarding() {
        if !profile.targetsOverridden {
            profile.targets = NutritionCalculator.computeTargets(for: profile)
        }
        hasCompletedOnboarding = true
        refreshRecommendations()
    }

    func refreshRecommendations(meal: MealPeriod = .lunch) {
        let context = RecommendationContext(
            profile: profile,
            meal: meal,
            quadrant: selectedQuadrant ?? .NW
        )
        recommendations = RecommendationEngine.recommend(items: allMenuItems, context: context)
    }

    func rejectAndPropose(venueSlug: String, restaurant: String) {
        let context = RecommendationContext(
            profile: profile,
            meal: .lunch,
            proposedVenueSlug: venueSlug,
            proposedRestaurant: restaurant
        )
        recommendations = RecommendationEngine.recommend(items: allMenuItems, context: context, limit: 3)
    }

    private func seedSampleData() {
        venues = [
            DiningVenue(name: "West End Market", slug: "west-end-market", quadrant: .NW, isOpen: true, distanceMiles: 0.2, categories: "Various • Salads, Grill, Pasta", macroTags: ["HIGH PROTEIN", "LOW FAT"]),
            DiningVenue(name: "Turner Place", slug: "turner-place", quadrant: .SW, isOpen: false, distanceMiles: 0.5, categories: "Steakhouse • Sushi • Bowls", macroTags: ["BALANCED"]),
            DiningVenue(name: "D2 at Dietrick Hall", slug: "d2-dietrick", quadrant: .NW, isOpen: true, distanceMiles: 0.3, categories: "All-you-care-to-eat", macroTags: ["HIGH PROTEIN"]),
        ]

        allMenuItems = [
            MenuItem(name: "London Broil w/ Quinoa", venueName: "West End Market", restaurantName: "Grill", calories: 680, proteinG: 62, carbsG: 55, fatG: 22, meal: .lunch, venueSlug: "west-end-market", explanationTags: ["Top Bulking Pick"]),
            MenuItem(name: "Qdoba Chicken Bowl", venueName: "Turner Place", restaurantName: "Qdoba", calories: 540, proteinG: 45, carbsG: 60, fatG: 15, meal: .lunch, venueSlug: "turner-place"),
            MenuItem(name: "Grilled Chicken Bowl", venueName: "Turner Place", restaurantName: "Qdoba", calories: 540, proteinG: 42, carbsG: 58, fatG: 14, dietaryTags: ["high protein"], meal: .lunch, venueSlug: "turner-place"),
            MenuItem(name: "Salmon Salad", venueName: "West End Market", restaurantName: "Leaf & Ladle", calories: 420, proteinG: 35, carbsG: 20, fatG: 18, dietaryTags: ["lean"], meal: .lunch, venueSlug: "west-end-market"),
            MenuItem(name: "London Broil", venueName: "West End Market", restaurantName: "Grill", calories: 320, proteinG: 36, carbsG: 2, fatG: 18, allergens: ["Soy"], ingredients: "Beef (Top Round), Olive Oil, Soy Sauce", meal: .lunch, venueSlug: "west-end-market"),
        ]

        savedBowls = [
            SavedBowl(name: "Post-Workout Bowl", venueName: "Qdoba", restaurantName: "Turner Place", ingredientsSummary: "Chicken, brown rice, black beans, fajita veggies, pico, guacamole", calories: 610, proteinG: 45, carbsG: 65, fatG: 18, isFavorite: true),
            SavedBowl(name: "Lean Brisket Plate", venueName: "Turner Place", restaurantName: "Smokehouse", ingredientsSummary: "Smoked brisket (lean), double green beans, no sauce", calories: 480, proteinG: 42, carbsG: 12, fatG: 22),
        ]
    }
}
