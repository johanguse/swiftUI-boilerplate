import Foundation

enum AppError: Error, Sendable {
    case invalidEmail
    case weakPassword
    case invalidCredentials
    case passwordMismatch
    case emptyName
    case userNotFound
    case networkError
    case unknown(String)

    /// Returns the `LocalizationKey` corresponding to this error,
    /// so the presentation layer can localize it via `LocalizationManager`.
    var localizationKey: LocalizationKey? {
        switch self {
        case .invalidEmail:       return .invalidEmail
        case .weakPassword:       return .weakPassword
        case .invalidCredentials: return .invalidCredentials
        case .passwordMismatch:   return .passwordsDoNotMatch
        case .emptyName:          return .emptyName
        case .userNotFound:       return .errorGeneric
        case .networkError:       return .errorGeneric
        case .unknown:            return nil
        }
    }

    /// Raw message for `.unknown` errors; nil otherwise.
    var rawMessage: String? {
        if case .unknown(let msg) = self { return msg }
        return nil
    }
}
