import Foundation
import Observation

enum EmailAuthStep {
    case email
    case code
}

@Observable
@MainActor
final class EmailAuthViewModel {
    var email: String = ""
    var code: String = ""
    var step: EmailAuthStep = .email
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let sendCodeUseCase: SendEmailCodeUseCase
    private let verifyCodeUseCase: VerifyEmailCodeUseCase
    private let router: AppRouter
    private let localization: LocalizationManager
    private let analytics: any AnalyticsService

    init(
        sendCodeUseCase: SendEmailCodeUseCase,
        verifyCodeUseCase: VerifyEmailCodeUseCase,
        router: AppRouter,
        localization: LocalizationManager,
        analytics: any AnalyticsService
    ) {
        self.sendCodeUseCase = sendCodeUseCase
        self.verifyCodeUseCase = verifyCodeUseCase
        self.router = router
        self.localization = localization
        self.analytics = analytics
    }

    var isEmailValid: Bool { email.isValidEmail }
    var isCodeValid: Bool { code.count >= 4 }

    func sendCode() async {
        guard isEmailValid else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await sendCodeUseCase.execute(email: email)
            step = .code
        } catch {
            HapticsManager.error()
            errorMessage = localization.localizedError(error)
        }
        isLoading = false
    }

    func verifyCode() async {
        guard isCodeValid else { return }
        isLoading = true
        errorMessage = nil
        do {
            let user = try await verifyCodeUseCase.execute(email: email, code: code)
            HapticsManager.success()
            analytics.trackSignIn(method: "email_code")
            analytics.identify(userId: user.id)
            router.signIn()
        } catch {
            HapticsManager.error()
            errorMessage = localization.localizedError(error)
        }
        isLoading = false
    }

    func resendCode() async {
        code = ""
        errorMessage = nil
        isLoading = true
        do {
            try await sendCodeUseCase.execute(email: email)
        } catch {
            errorMessage = localization.localizedError(error)
        }
        isLoading = false
    }

    func backToEmail() {
        step = .email
        code = ""
        errorMessage = nil
    }
}
