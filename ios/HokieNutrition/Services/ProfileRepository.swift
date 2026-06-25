import Foundation
import Supabase

struct ProfileRow: Codable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var dob: String
    var sex: String
    var class_year: String?
    var height_cm: Double
    var weight_kg: Double
    var target_weight_kg: Double?
    var units: String
    var workouts_per_week: Int
    var activity_level: String
    var goal: String
    var pace: String?
    var protein_emphasis: String
    var dietary_pattern: String
    var allergens: [String]
    var dislikes: [String]
    var calorie_target: Int
    var protein_target: Int
    var carb_target: Int
    var fat_target: Int
    var targets_overridden: Bool
    var onboarding_completed_at: String?
}

enum ProfileRepository {
    static func fetch(userId: UUID) async throws -> ProfileRow? {
        guard let client = SupabaseManager.shared else { return nil }
        let rows: [ProfileRow] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value
        return rows.first
    }

    static func upsert(userId: UUID, profile: UserProfile) async throws {
        guard let client = SupabaseManager.shared else { return }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        let row = ProfileRow(
            id: userId,
            name: profile.name,
            email: profile.email,
            phone: profile.phone.isEmpty ? nil : profile.phone,
            dob: formatter.string(from: profile.dob),
            sex: profile.sex.rawValue,
            class_year: profile.classYear?.rawValue,
            height_cm: profile.heightCm,
            weight_kg: profile.weightKg,
            target_weight_kg: profile.targetWeightKg,
            units: profile.units.rawValue,
            workouts_per_week: profile.workoutsPerWeek,
            activity_level: profile.activityLevel.rawValue,
            goal: profile.goal.rawValue,
            pace: (profile.goal == .cutting || profile.goal == .bulking) ? profile.pace.rawValue : nil,
            protein_emphasis: profile.proteinEmphasis.rawValue,
            dietary_pattern: profile.dietaryPattern.rawValue,
            allergens: profile.allergens,
            dislikes: profile.dislikes,
            calorie_target: profile.targets.calories,
            protein_target: profile.targets.protein,
            carb_target: profile.targets.carbs,
            fat_target: profile.targets.fat,
            targets_overridden: profile.targetsOverridden,
            onboarding_completed_at: ISO8601DateFormatter().string(from: Date())
        )

        try await client.from("profiles").upsert(row).execute()
    }

    static func toUserProfile(_ row: ProfileRow) -> UserProfile {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dob = formatter.date(from: row.dob) ?? Date()

        var profile = UserProfile()
        profile.name = row.name
        profile.email = row.email
        profile.phone = row.phone ?? ""
        profile.dob = dob
        profile.sex = UserSex(rawValue: row.sex) ?? .male
        profile.classYear = row.class_year.flatMap { ClassYear(rawValue: $0) }
        profile.heightCm = row.height_cm
        profile.weightKg = row.weight_kg
        profile.targetWeightKg = row.target_weight_kg
        profile.units = UnitsPreference(rawValue: row.units) ?? .imperial
        profile.workoutsPerWeek = row.workouts_per_week
        profile.activityLevel = ActivityLevel(rawValue: row.activity_level) ?? .moderate
        profile.goal = GymGoal(rawValue: row.goal) ?? .maintenance
        profile.pace = row.pace.flatMap { GoalPace(rawValue: $0) } ?? .steady
        profile.proteinEmphasis = ProteinEmphasis(rawValue: row.protein_emphasis) ?? .standard
        profile.dietaryPattern = DietaryPattern(rawValue: row.dietary_pattern) ?? .none
        profile.allergens = row.allergens
        profile.dislikes = row.dislikes
        profile.targets = NutritionTargets(
            calories: row.calorie_target,
            protein: row.protein_target,
            carbs: row.carb_target,
            fat: row.fat_target
        )
        profile.targetsOverridden = row.targets_overridden
        return profile
    }
}
