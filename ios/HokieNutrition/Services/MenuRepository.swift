import Foundation
import Supabase

struct MenuItemRow: Codable {
    let id: UUID
    let name: String
    let description: String?
    let meal: String?
    let calories: Int?
    let protein_g: Double?
    let carbs_g: Double?
    let fat_g: Double?
    let ingredients: String?
    let allergens: [String]
    let dietary_tags: [String]
    let menu_date: String
    let venue_name: String
    let venue_slug: String
    let quadrant: String
    let restaurant_name: String?
}

struct VenueRow: Codable {
    let id: UUID
    let name: String
    let slug: String
    let quadrant: String
    let is_active: Bool
}

enum MenuRepository {
    static func fetchTodayMenu() async throws -> ([MenuItem], [DiningVenue]) {
        guard let client = SupabaseManager.shared else { return ([], []) }

        let today = ISO8601DateFormatter().string(from: Date()).prefix(10)

        let itemRows: [MenuItemRow] = try await client
            .from("menu_items_enriched")
            .select()
            .eq("menu_date", value: String(today))
            .limit(500)
            .execute()
            .value

        let venueRows: [VenueRow] = try await client
            .from("dining_venues")
            .select()
            .eq("is_active", value: true)
            .execute()
            .value

        let items = itemRows.compactMap(mapMenuItem)
        let venues = venueRows.map(mapVenue)
        return (items, venues)
    }

    static func latestMenuDate() async throws -> String? {
        guard let client = SupabaseManager.shared else { return nil }
        struct DateRow: Codable { let menu_date: String }
        let rows: [DateRow] = try await client
            .from("menu_items")
            .select("menu_date")
            .order("menu_date", ascending: false)
            .limit(1)
            .execute()
            .value
        return rows.first?.menu_date
    }

    static func fetchMenu(for date: String) async throws -> ([MenuItem], [DiningVenue]) {
        guard let client = SupabaseManager.shared else { return ([], []) }

        let itemRows: [MenuItemRow] = try await client
            .from("menu_items_enriched")
            .select()
            .eq("menu_date", value: date)
            .limit(500)
            .execute()
            .value

        let venueRows: [VenueRow] = try await client
            .from("dining_venues")
            .select()
            .eq("is_active", value: true)
            .execute()
            .value

        return (itemRows.compactMap(mapMenuItem), venueRows.map(mapVenue))
    }

    private static func mapMenuItem(_ row: MenuItemRow) -> MenuItem? {
        guard let calories = row.calories, calories > 0 else { return nil }
        return MenuItem(
            id: row.id,
            name: row.name,
            venueName: row.venue_name,
            restaurantName: row.restaurant_name ?? "General",
            calories: calories,
            proteinG: row.protein_g ?? 0,
            carbsG: row.carbs_g ?? 0,
            fatG: row.fat_g ?? 0,
            allergens: row.allergens,
            dietaryTags: row.dietary_tags,
            ingredients: row.ingredients,
            meal: MealPeriod(rawValue: row.meal ?? "lunch") ?? .lunch,
            venueSlug: row.venue_slug
        )
    }

    private static func mapVenue(_ row: VenueRow) -> DiningVenue {
        DiningVenue(
            id: row.id,
            name: row.name,
            slug: row.slug,
            quadrant: CampusQuadrant(rawValue: row.quadrant) ?? .NW,
            isOpen: row.is_active,
            categories: "",
            macroTags: []
        )
    }
}
