import Foundation
import Observation

@Observable
@MainActor
final class ChangePasswordViewModel {
    var currentPassword: String = ""
    var newPassword: String = ""
    var confirmPassword: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var successMessage: String? = nil

    var isFormValid: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 8 &&
        newPassword == confirmPassword
    }

    var passwordMismatch: Bool {
        !confirmPassword.isEmpty && newPassword != confirmPassword
    }

    private let authRepository: any AuthRepositoryProtocol
    private let localization: LocalizationManager

    init(authRepository: any AuthRepositoryProtocol, localization: LocalizationManager) {
        self.authRepository = authRepository
        self.localization = localization
    }

    func changePassword() async -> Bool {
        guard isFormValid else { return false }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authRepository.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            HapticsManager.success()
            successMessage = localization.localizedString(for: .passwordChanged)
            return true
        } catch {
            HapticsManager.error()
            errorMessage = localization.localizedError(error)
            return false
        }
    }
}
