import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValidEmail: Bool {
        let pattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var isValidPassword: Bool {
        guard count >= 8 else { return false }
        let hasUppercase   = range(of: "[A-Z]", options: .regularExpression) != nil
        let hasNumber      = range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChar = range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        return hasUppercase && hasNumber && hasSpecialChar
    }

    var isNotEmpty: Bool {
        !trimmed.isEmpty
    }

    var nilIfTrimmedEmpty: String? {
        let normalized = trimmed
        return normalized.isEmpty ? nil : normalized
    }
}
