import Foundation

@MainActor
protocol AuthRepositoryProtocol: AnyObject {
    var currentUser: User? { get }
    func restoreSession() async throws -> User?
    func seedCachedUser(_ user: User)
    func signIn(email: String, password: String) async throws -> User
    func signUp(name: String, email: String, password: String) async throws -> User
    func resetPassword(email: String) async throws
    func changePassword(currentPassword: String, newPassword: String) async throws
    func signOut() async throws
    func sendEmailCode(email: String) async throws
    func verifyEmailCode(email: String, code: String) async throws -> User
}
