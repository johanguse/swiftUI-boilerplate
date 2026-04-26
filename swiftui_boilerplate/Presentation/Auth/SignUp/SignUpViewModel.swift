import Foundation
import Observation

@Observable
@MainActor
final class SignUpViewModel {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let signUpUseCase: SignUpUseCase
    private let router: AppRouter
    private let localization: LocalizationManager
    private let analytics: any AnalyticsService

    init(
        signUpUseCase: SignUpUseCase,
        router: AppRouter,
        localization: LocalizationManager,
        analytics: any AnalyticsService
    ) {
        self.signUpUseCase = signUpUseCase
        self.router = router
        self.localization = localization
        self.analytics = analytics
    }

    var isFormValid: Bool {
        name.isNotEmpty && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty
    }

    func signUp() async {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = nil
        do {
            let user = try await signUpUseCase.execute(
                name: name,
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )
            HapticsManager.success()
            analytics.trackSignUp(method: "email")
            analytics.identify(userId: user.id)
            router.signIn()
        } catch {
            HapticsManager.error()
            errorMessage = localization.localizedError(error)
        }
        isLoading = false
    }
}
