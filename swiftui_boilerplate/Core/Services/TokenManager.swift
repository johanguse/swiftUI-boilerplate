import Foundation
import Security

/// Stores the JWT access token and its expiry date in the Keychain / UserDefaults.
final class TokenManager {

    static let shared = TokenManager()
    private init() {}

    private let service = "com.swiftui-boilerplate.auth-token"
    private let tokenAccount = "access_token"
    private let expiryKey = "auth_token_expiry"

    var token: String? {
        get { readKeychain() }
        set { newValue == nil ? deleteKeychain() : writeKeychain(newValue!) }
    }

    var expiresAt: Date? {
        get {
            guard let ts = UserDefaults.standard.object(forKey: expiryKey) as? Double else { return nil }
            return Date(timeIntervalSince1970: ts)
        }
        set {
            if let d = newValue { UserDefaults.standard.set(d.timeIntervalSince1970, forKey: expiryKey) }
            else { UserDefaults.standard.removeObject(forKey: expiryKey) }
        }
    }

    var isExpired: Bool {
        guard let expiry = expiresAt else { return true }
        return Date() >= expiry
    }

    func save(token: String, expiresAt: Date) {
        self.token = token
        self.expiresAt = expiresAt
    }

    func clear() {
        token = nil
        expiresAt = nil
    }

    // MARK: - Keychain helpers

    private func readKeychain() -> String? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var ref: AnyObject?
        guard SecItemCopyMatching(q as CFDictionary, &ref) == errSecSuccess,
              let data = ref as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func writeKeychain(_ value: String) {
        guard let data = value.data(using: .utf8) else { return }
        deleteKeychain()
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(q as CFDictionary, nil)
    }

    private func deleteKeychain() {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenAccount
        ]
        SecItemDelete(q as CFDictionary)
    }
}
