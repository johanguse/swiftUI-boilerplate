import Foundation
import Observation

@Observable
@MainActor
final class SignInViewModel {
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let signInUseCase: SignInUseCase
    private let router: AppRouter
    private let localization: LocalizationManager
    private let analytics: any AnalyticsService

    init(
        signInUseCase: SignInUseCase,
        router: AppRouter,
        localization: LocalizationManager,
        analytics: any AnalyticsService
    ) {
        self.signInUseCase = signInUseCase
        self.router = router
        self.localization = localization
        self.analytics = analytics
    }

    var isFormValid: Bool {
        email.isNotEmpty && password.isNotEmpty
    }

    func signIn() async {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = nil
        do {
            let user = try await signInUseCase.execute(email: email, password: password)
            HapticsManager.success()
            analytics.trackSignIn(method: "email")
            analytics.identify(userId: user.id)
            router.signIn()
        } catch {
            HapticsManager.error()
            errorMessage = localization.localizedError(error)
        }
        isLoading = false
    }
}
