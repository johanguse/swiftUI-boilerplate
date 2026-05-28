import Foundation

// MARK: - Domain-specific localization helpers
//
// Add convenience methods here as the app grows to keep LocalizationManager.swift
// focused on the core mechanics. Group by feature with // MARK: comments.
//
// Example:
//
// extension LocalizationManager {
//
//     // MARK: - Home
//
//     func greetingForHour(_ hour: Int) -> String {
//         switch hour {
//         case 0..<12: localizedString(for: .goodMorning)
//         case 12..<18: localizedString(for: .goodAfternoon)
//         default:     localizedString(for: .goodEvening)
//         }
//     }
// }

extension LocalizationManager {

    // MARK: - Home

    var currentGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return localizedString(for: .goodMorning)
        case 12..<18: return localizedString(for: .goodAfternoon)
        default:     return localizedString(for: .goodEvening)
        }
    }
}
