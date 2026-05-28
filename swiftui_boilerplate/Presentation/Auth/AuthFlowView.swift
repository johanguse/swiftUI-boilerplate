import SwiftUI

struct AuthFlowView: View {
    @Bindable var router: AppRouter
    let container: AppContainer
    var showsCloseButton: Bool = false
    var onClose: (() -> Void)? = nil

    var body: some View {
        NavigationStack(path: $router.authPath) {
            WelcomeView(
                container: container,
                showsCloseButton: showsCloseButton,
                onClose: onClose
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .signIn:
                    SignInView(container: container)
                case .signUp:
                    SignUpView(container: container)
                case .forgotPassword:
                    ForgotPasswordView(container: container)
                case .emailAuth:
                    EmailAuthView(container: container)
                }
            }
        }
    }
}
