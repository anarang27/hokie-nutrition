import Foundation

enum UserSex: String, CaseIterable, Codable, Identifiable {
    case male, female
    var id: String { rawValue }
}

enum ClassYear: String, CaseIterable, Codable, Identifiable {
    case freshman, sophomore, junior, senior, grad, other
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

enum ActivityLevel: String, CaseIterable, Codable, Identifiable {
    case sedentary, light, moderate, active, veryActive = "very_active"
    var id: String { rawValue }

    var label: String {
        switch self {
        case .sedentary: "Sedentary"
        case .light: "Light (1-3 days/week)"
        case .moderate: "Moderate (3-5 days/week)"
        case .active: "Active (6-7 days/week)"
        case .veryActive: "Very active"
        }
    }

    var factor: Double {
        switch self {
        case .sedentary: 1.2
        case .light: 1.375
        case .moderate: 1.55
        case .active: 1.725
        case .veryActive: 1.9
        }
    }
}

enum GymGoal: String, CaseIterable, Codable, Identifiable {
    case cutting, bulking, lean, maintenance, highProtein = "high_protein", balanced
    var id: String { rawValue }

    var label: String {
        switch self {
        case .cutting: "Cutting"
        case .bulking: "Bulking"
        case .lean: "Staying Lean"
        case .maintenance: "Maintenance"
        case .highProtein: "High Protein"
        case .balanced: "Balanced Eating"
        }
    }
}

enum GoalPace: String, CaseIterable, Codable, Identifiable {
    case relaxed, steady, aggressive
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

enum ProteinEmphasis: String, Codable {
    case standard, high
}

enum DietaryPattern: String, CaseIterable, Codable, Identifiable {
    case none, vegetarian, vegan, pescatarian, halal
    var id: String { rawValue }
    var label: String { rawValue == .none ? "None" : rawValue.capitalized }
}

enum UnitsPreference: String, Codable {
    case imperial, metric
}

enum CampusQuadrant: String, CaseIterable, Codable {
    case NW, NE, SW, SE
}

enum MealPeriod: String, CaseIterable, Codable {
    case breakfast, lunch, dinner, snack
}

struct NutritionTargets: Codable, Equatable {
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
}

struct UserProfile: Codable, Equatable {
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var dob: Date = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    var sex: UserSex = .male
    var classYear: ClassYear?
    var heightCm: Double = 175
    var weightKg: Double = 75
    var targetWeightKg: Double?
    var units: UnitsPreference = .imperial
    var workoutsPerWeek: Int = 3
    var activityLevel: ActivityLevel = .moderate
    var goal: GymGoal = .maintenance
    var pace: GoalPace = .steady
    var proteinEmphasis: ProteinEmphasis = .standard
    var dietaryPattern: DietaryPattern = .none
    var allergens: [String] = []
    var dislikes: [String] = []
    var targets: NutritionTargets = .init(calories: 2000, protein: 150, carbs: 200, fat: 65)
    var targetsOverridden: Bool = false
}

struct MenuItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var venueName: String
    var restaurantName: String
    var calories: Int
    var proteinG: Double
    var carbsG: Double
    var fatG: Double
    var allergens: [String]
    var dietaryTags: [String]
    var ingredients: String?
    var meal: MealPeriod
    var venueSlug: String
    var explanationTags: [String] = []

    init(
        id: UUID = UUID(),
        name: String,
        venueName: String,
        restaurantName: String,
        calories: Int,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        allergens: [String] = [],
        dietaryTags: [String] = [],
        ingredients: String? = nil,
        meal: MealPeriod = .lunch,
        venueSlug: String = "",
        explanationTags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.venueName = venueName
        self.restaurantName = restaurantName
        self.calories = calories
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.allergens = allergens
        self.dietaryTags = dietaryTags
        self.ingredients = ingredients
        self.meal = meal
        self.venueSlug = venueSlug
        self.explanationTags = explanationTags
    }
}

struct SavedBowl: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var venueName: String
    var restaurantName: String
    var ingredientsSummary: String
    var calories: Int
    var proteinG: Double
    var carbsG: Double
    var fatG: Double
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        name: String,
        venueName: String,
        restaurantName: String,
        ingredientsSummary: String,
        calories: Int,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.venueName = venueName
        self.restaurantName = restaurantName
        self.ingredientsSummary = ingredientsSummary
        self.calories = calories
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.isFavorite = isFavorite
    }
}

struct DiningVenue: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var slug: String
    var quadrant: CampusQuadrant
    var isOpen: Bool
    var distanceMiles: Double?
    var categories: String
    var macroTags: [String]

    init(
        id: UUID = UUID(),
        name: String,
        slug: String,
        quadrant: CampusQuadrant,
        isOpen: Bool = true,
        distanceMiles: Double? = nil,
        categories: String = "",
        macroTags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.quadrant = quadrant
        self.isOpen = isOpen
        self.distanceMiles = distanceMiles
        self.categories = categories
        self.macroTags = macroTags
    }
}
