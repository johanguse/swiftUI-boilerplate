import SwiftUI
import Observation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        }
    }

    var shortCode: String {
        switch self {
        case .english: return "EN"
        case .turkish: return "TR"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .turkish: return "🇹🇷"
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
        currentLanguage = AppLanguage(rawValue: stored) ?? .english
    }

    func localizedString(for key: LocalizationKey) -> String {
        let langCode = currentLanguage.rawValue
        guard let path = Bundle.main.path(forResource: langCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main.localizedString(forKey: key.rawValue, value: key.rawValue, table: nil)
        }
        return bundle.localizedString(forKey: key.rawValue, value: key.rawValue, table: nil)
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
