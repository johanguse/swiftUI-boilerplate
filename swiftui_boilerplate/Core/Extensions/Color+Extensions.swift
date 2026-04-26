import SwiftUI

extension Color {
    // MARK: - Brand
    static let appPrimary   = Color.indigo
    static let appSecondary = Color.purple

    // MARK: - Backgrounds
    static let appBackground = Color(.systemBackground)
    static let appSurface    = Color(.secondarySystemBackground)
    static let appGrouped    = Color(.systemGroupedBackground)

    // MARK: - Text
    static let appText    = Color(.label)
    static let appSubtext = Color(.secondaryLabel)
    static let appTertiary = Color(.tertiaryLabel)

    // MARK: - Semantic
    static let appError   = Color.red
    static let appSuccess = Color.green
    static let appWarning = Color.orange
    static let appDivider = Color(.separator)
}
