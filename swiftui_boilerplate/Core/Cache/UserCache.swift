import Foundation
import Security

/// Persists the last known User to the Keychain so the app can navigate
/// instantly on launch without waiting for a network response.
/// Uses Keychain instead of UserDefaults for secure storage of user data.
enum UserCache {
    private static let service = "com.swiftui-boilerplate.user-cache"
    private static let account = "cached_user_profile"

    // One-time migration key — checked once per install
    private static let migrationKey = "keychain_migration_done"

    static func save(_ user: User) {
        guard let data = try? JSONEncoder().encode(user) else { return }

        // Delete any existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add the new item
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    static func load() -> User? {
        migrateFromUserDefaultsIfNeeded()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    static func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Migration

    /// One-time migration from UserDefaults to Keychain for existing users.
    private static func migrateFromUserDefaultsIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: migrationKey) else { return }
        defer { defaults.set(true, forKey: migrationKey) }

        // If there's data in UserDefaults, move it to Keychain
        if let legacyData = defaults.data(forKey: "cached_user_profile"),
           let user = try? JSONDecoder().decode(User.self, from: legacyData) {
            save(user)
            defaults.removeObject(forKey: "cached_user_profile")
        }
    }
}
