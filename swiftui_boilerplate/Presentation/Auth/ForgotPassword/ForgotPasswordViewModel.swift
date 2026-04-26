import Foundation
import Observation

@Observable
@MainActor
final class ForgotPasswordViewModel {
    var email: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isSuccess: Bool = false

    private let forgotPasswordUseCase: ForgotPasswordUseCase
    private let localization: LocalizationManager

    init(forgotPasswordUseCase: ForgotPasswordUseCase, localization: LocalizationManager) {
        self.forgotPasswordUseCase = forgotPasswordUseCase
        self.localization = localization
    }

    var isFormValid: Bool {
        email.isNotEmpty
    }

    func sendResetLink() async {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await forgotPasswordUseCase.execute(email: email)
            isSuccess = true
        } catch {
            errorMessage = localization.localizedError(error)
        }
        isLoading = false
    }
}
