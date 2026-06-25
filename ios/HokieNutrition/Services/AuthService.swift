import Foundation
import Supabase

enum AuthServiceError: LocalizedError {
    case notConfigured
    case vtEmailRequired
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .notConfigured: "Supabase is not configured. Add ios/HokieNutrition/Supabase.plist."
        case .vtEmailRequired: "Please use your @vt.edu email."
        case .invalidCredentials: "Invalid email or password."
        }
    }
}

@MainActor
final class AuthService {
    private var client: SupabaseClient? { SupabaseManager.shared }

    var isConfigured: Bool { client != nil }

    func restoreSession() async throws -> Session? {
        guard let client else { return nil }
        return try? await client.auth.session
    }

    func signUp(email: String, password: String) async throws -> Session {
        guard let client else { throw AuthServiceError.notConfigured }
        guard VTEmailValidator.isValid(email) else { throw AuthServiceError.vtEmailRequired }

        let normalized = email.trimmingCharacters(in: .whitespaces).lowercased()
        let response = try await client.auth.signUp(email: normalized, password: password)

        if let session = response.session {
            return session
        }
        // Email confirmation may be enabled — sign in after verify
        throw AuthServiceError.invalidCredentials
    }

    func signIn(email: String, password: String) async throws -> Session {
        guard let client else { throw AuthServiceError.notConfigured }
        guard VTEmailValidator.isValid(email) else { throw AuthServiceError.vtEmailRequired }

        let normalized = email.trimmingCharacters(in: .whitespaces).lowercased()
        let session = try await client.auth.signIn(email: normalized, password: password)
        return session
    }

    func signOut() async throws {
        guard let client else { return }
        try await client.auth.signOut()
    }

    func currentUserId() async -> UUID? {
        guard let client else { return nil }
        return try? await client.auth.session.user.id
    }
}
