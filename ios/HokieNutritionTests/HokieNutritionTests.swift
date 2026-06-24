import XCTest
@testable import HokieNutrition

final class VTEmailValidatorTests: XCTestCase {
    func testAcceptsVtEmail() {
        XCTAssertTrue(VTEmailValidator.isValid("student@vt.edu"))
        XCTAssertTrue(VTEmailValidator.isValid("abc123@VT.EDU"))
    }

    func testRejectsNonVtEmail() {
        XCTAssertFalse(VTEmailValidator.isValid("student@gmail.com"))
        XCTAssertFalse(VTEmailValidator.isValid("user@cs.vt.edu"))
    }
}

final class NutritionCalculatorTests: XCTestCase {
    func testComputeTargetsForBulkingMale() {
        var profile = UserProfile()
        profile.sex = .male
        profile.dob = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
        profile.heightCm = 180
        profile.weightKg = 80
        profile.activityLevel = .moderate
        profile.goal = .bulking
        profile.pace = .steady
        profile.proteinEmphasis = .high

        let targets = NutritionCalculator.computeTargets(for: profile)
        XCTAssertGreaterThan(targets.calories, 2500)
        XCTAssertEqual(targets.protein, 160)
    }
}

final class RecommendationEngineTests: XCTestCase {
    func testQuadrantFiltersCandidates() {
        var profile = UserProfile()
        profile.goal = .highProtein
        profile.targets = NutritionTargets(calories: 2400, protein: 160, carbs: 250, fat: 70)

        let items = [
            MenuItem(name: "A", venueName: "West End", restaurantName: "Grill", calories: 500, proteinG: 45, carbsG: 40, fatG: 15, venueSlug: "west-end-market"),
            MenuItem(name: "B", venueName: "Turner", restaurantName: "Qdoba", calories: 540, proteinG: 42, carbsG: 60, fatG: 14, venueSlug: "turner-place"),
        ]

        let nw = RecommendationEngine.recommend(
            items: items,
            context: RecommendationContext(profile: profile, meal: .lunch, quadrant: .NW)
        )
        XCTAssertTrue(nw.allSatisfy { $0.item.venueSlug == "west-end-market" })
    }
}
