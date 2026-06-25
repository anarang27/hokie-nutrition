import Foundation
import Supabase

struct SupabaseConfig {
    let url: URL
    let anonKey: String

    static func load() -> SupabaseConfig? {
        guard let path = Bundle.main.path(forResource: "Supabase", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let urlString = dict["SUPABASE_URL"] as? String,
              let anonKey = dict["SUPABASE_ANON_KEY"] as? String,
              !urlString.contains("YOUR_PROJECT"),
              !anonKey.contains("YOUR_ANON"),
              let url = URL(string: urlString) else {
            return nil
        }
        return SupabaseConfig(url: url, anonKey: anonKey)
    }
}

enum SupabaseManager {
    static let shared: SupabaseClient? = {
        guard let config = SupabaseConfig.load() else { return nil }
        return SupabaseClient(supabaseURL: config.url, supabaseKey: config.anonKey)
    }()
}
