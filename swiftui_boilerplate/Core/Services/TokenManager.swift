import Foundation
import Security

/// Stores JWT access and refresh tokens in the Keychain; expiry in UserDefaults.
final class TokenManager {

    static let shared = TokenManager()
    private init() {}

    private let service = "com.swiftui-boilerplate.auth-token"
    private let accessTokenAccount = "access_token"
    private let refreshTokenAccount = "refresh_token"
    private let expiryKey = "auth_token_expiry"

    var token: String? {
        get { readKeychain(account: accessTokenAccount) }
        set { write(newValue, account: accessTokenAccount) }
    }

    var refreshToken: String? {
        get { readKeychain(account: refreshTokenAccount) }
        set { write(newValue, account: refreshTokenAccount) }
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

    func save(token: String, refreshToken: String?, expiresAt: Date) {
        self.token = token
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    func clear() {
        token = nil
        refreshToken = nil
        expiresAt = nil
    }

    // MARK: - Keychain helpers

    private func readKeychain(account: String) -> String? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var ref: AnyObject?
        guard SecItemCopyMatching(q as CFDictionary, &ref) == errSecSuccess,
              let data = ref as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func write(_ value: String?, account: String) {
        guard let value else { deleteKeychain(account: account); return }
        guard let data = value.data(using: .utf8) else { return }
        deleteKeychain(account: account)
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(q as CFDictionary, nil)
    }

    private func deleteKeychain(account: String) {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(q as CFDictionary)
    }
}
