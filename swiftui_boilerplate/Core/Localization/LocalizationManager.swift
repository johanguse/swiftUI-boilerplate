import SwiftUI
import Observation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"
    case spanish = "es"
    case portugueseBrazil = "pt-BR"
    case portuguesePortugal = "pt-PT"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:            return "English"
        case .turkish:            return "Türkçe"
        case .spanish:            return "Español"
        case .portugueseBrazil:   return "Português (Brasil)"
        case .portuguesePortugal: return "Português (Portugal)"
        }
    }

    var shortCode: String {
        switch self {
        case .english:            return "EN"
        case .turkish:            return "TR"
        case .spanish:            return "ES"
        case .portugueseBrazil:   return "PT-BR"
        case .portuguesePortugal: return "PT-PT"
        }
    }

    var flag: String {
        switch self {
        case .english:            return "🇺🇸"
        case .turkish:            return "🇹🇷"
        case .spanish:            return "🇪🇸"
        case .portugueseBrazil:   return "🇧🇷"
        case .portuguesePortugal: return "🇵🇹"
        }
    }

    static func matching(identifier: String) -> AppLanguage? {
        let normalizedIdentifier = identifier.replacingOccurrences(of: "_", with: "-")

        if normalizedIdentifier == "pt" {
            return .portugueseBrazil
        }

        if let exactMatch = AppLanguage(rawValue: normalizedIdentifier) {
            return exactMatch
        }

        let language = Locale.Language(identifier: normalizedIdentifier)
        switch language.languageCode?.identifier {
        case "en": return .english
        case "tr": return .turkish
        case "es": return .spanish
        case "pt":
            return language.region?.identifier == "PT" ? .portuguesePortugal : .portugueseBrazil
        default:
            return nil
        }
    }
}

@Observable
@MainActor
final class LocalizationManager {

    // Stored var — properly tracked by @Observable.
    // @ObservationIgnored + @AppStorage was intentionally removed:
    // computed properties reading @ObservationIgnored storage are never re-tracked,
    // so language changes never caused views to re-render.
    var currentLanguage: AppLanguage {
        didSet { UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language") }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: "app_language") ?? ""
        if let saved = AppLanguage.matching(identifier: stored) {
            currentLanguage = saved
        } else {
            let preferredIdentifier = Locale.preferredLanguages.first ?? Locale.current.identifier
            let detected = AppLanguage.matching(identifier: preferredIdentifier) ?? .english
            currentLanguage = detected
        }
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
    }

    func localizedString(for key: LocalizationKey) -> String {
        let langCode = currentLanguage.rawValue
        guard let path = Bundle.main.path(forResource: langCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main.localizedString(forKey: key.rawValue, value: key.rawValue, table: nil)
        }
        return bundle.localizedString(forKey: key.rawValue, value: key.rawValue, table: nil)
    }

    /// Returns a formatted string using the localized template for `key`.
    /// Use this for any string that contains `%d`, `%@`, or other format specifiers.
    func localizedFormat(for key: LocalizationKey, _ arguments: CVarArg...) -> String {
        let template = localizedString(for: key)
        return String(
            format: template,
            locale: Locale(identifier: currentLanguage.rawValue),
            arguments: arguments
        )
    }

    /// Localizes an `AppError` using the current language.
    /// Falls back to the raw message for `.unknown` errors.
    func localizedError(_ error: Error) -> String {
        if let appError = error as? AppError {
            if let key = appError.localizationKey {
                return localizedString(for: key)
            }
            return appError.rawMessage ?? localizedString(for: .errorGeneric)
        }
        return error.localizedDescription
    }
}
