import SwiftUI
import Observation

enum AppTheme: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .light:  return .light
        case .dark:   return .dark
        case .system: return nil
        }
    }

    var icon: String {
        switch self {
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}

@Observable
@MainActor
final class ThemeManager {

    // Stored var — properly tracked by @Observable.
    // @ObservationIgnored + @AppStorage was intentionally removed:
    // computed properties reading @ObservationIgnored storage are never re-tracked,
    // so theme changes never propagated to the view hierarchy.
    var selectedTheme: AppTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: "app_theme") }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: "app_theme") ?? ""
        selectedTheme = AppTheme(rawValue: stored) ?? .system
    }

    var colorScheme: ColorScheme? { selectedTheme.colorScheme }
}
