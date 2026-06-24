import Foundation

enum VTEmailValidator {
    private static let pattern = #"^[A-Za-z0-9._%+-]+@vt\.edu$"#

    static func isValid(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }
}

enum NutritionCalculator {
    static func age(from dob: Date, now: Date = Date()) -> Int {
        Calendar.current.dateComponents([.year], from: dob, to: now).year ?? 0
    }

    static func bmr(sex: UserSex, weightKg: Double, heightCm: Double, age: Int) -> Double {
        switch sex {
        case .male:
            10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
        case .female:
            10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
        }
    }

    static func goalAdjustment(goal: GymGoal, pace: GoalPace) -> Int {
        switch goal {
        case .cutting:
            switch pace {
            case .relaxed: -250
            case .steady: -500
            case .aggressive: -750
            }
        case .bulking:
            switch pace {
            case .relaxed: 150
            case .steady: 300
            case .aggressive: 500
            }
        default:
            0
        }
    }

    static func calorieFloor(sex: UserSex, bmr: Double) -> Int {
        let hard = sex == .female ? 1200 : 1500
        return Int(max(bmr, Double(hard)).rounded())
    }

    static func defaultProteinEmphasis(for goal: GymGoal) -> ProteinEmphasis {
        switch goal {
        case .cutting, .bulking, .lean, .highProtein: .high
        default: .standard
        }
    }

    static func computeTargets(for profile: UserProfile) -> NutritionTargets {
        let age = age(from: profile.dob)
        let bmrVal = bmr(sex: profile.sex, weightKg: profile.weightKg, heightCm: profile.heightCm, age: age)
        let tdee = bmrVal * profile.activityLevel.factor
        let adjustment = goalAdjustment(goal: profile.goal, pace: profile.pace)
        let floor = calorieFloor(sex: profile.sex, bmr: bmrVal)
        let calories = max(floor, Int((tdee + Double(adjustment)).rounded()))

        let emphasis = profile.proteinEmphasis == .high ? 2.0 : 1.6
        let protein = Int((emphasis * profile.weightKg).rounded())
        let fat = Int(((Double(calories) * 0.25) / 9).rounded())
        let proteinCals = protein * 4
        let fatCals = fat * 9
        let carbs = max(0, Int(((Double(calories - proteinCals - fatCals)) / 4).rounded()))

        return NutritionTargets(calories: calories, protein: protein, carbs: carbs, fat: fat)
    }
}

enum UnitConverter {
    static func cmToFeetInches(_ cm: Double) -> (feet: Int, inches: Int) {
        let totalInches = cm / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.rounded()) - feet * 12
        return (feet, inches)
    }

    static func feetInchesToCm(feet: Int, inches: Int) -> Double {
        Double(feet * 12 + inches) * 2.54
    }

    static func kgToLbs(_ kg: Double) -> Double { kg * 2.20462 }
    static func lbsToKg(_ lbs: Double) -> Double { lbs / 2.20462 }
}

enum CampusLocation {
    static let center = (lat: 37.2285, lng: -80.4234)

    static func resolveQuadrant(lat: Double, lng: Double) -> CampusQuadrant {
        let north = lat >= center.lat
        let east = lng >= center.lng
        switch (north, east) {
        case (true, false): return .NW
        case (true, true): return .NE
        case (false, false): return .SW
        case (false, true): return .SE
        }
    }

    static let quadrantVenueSlugs: [CampusQuadrant: [String]] = [
        .NW: ["d2-dietrick", "west-end-market"],
        .NE: ["owens-food-court", "deets-place"],
        .SW: ["turner-place"],
        .SE: ["turner-place", "owens-food-court"],
    ]
}
