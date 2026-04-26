import Foundation

enum AuthRoute: Hashable {
    case signIn
    case signUp
    case forgotPassword
}

enum HomeRoute: Hashable {
    case userDetail(User)
}

enum SettingsRoute: Hashable {
    case changePassword
}
