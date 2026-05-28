import Foundation

@MainActor
final class APIAuthRepository: AuthRepositoryProtocol {

    private let dataSource: APIDataSource

    init(dataSource: APIDataSource) {
        self.dataSource = dataSource
    }

    var currentUser: User? {
        dataSource.currentUserDTO?.toDomain()
    }

    func restoreSession() async throws -> User? {
        try await dataSource.restoreSession()?.toDomain()
    }

    func seedCachedUser(_ user: User) {
        dataSource.setCurrentUser(user.toAPIUserDTO())
    }

    func signIn(email: String, password: String) async throws -> User {
        let user = try await dataSource.signIn(email: email, password: password).toDomain()
        UserCache.save(user)
        return user
    }

    func signUp(name: String, email: String, password: String) async throws -> User {
        let user = try await dataSource.signUp(name: name, email: email, password: password).toDomain()
        UserCache.save(user)
        return user
    }

    func resetPassword(email: String) async throws {
        try await dataSource.resetPassword(email: email)
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        try await dataSource.changePassword(currentPassword: currentPassword, newPassword: newPassword)
    }

    func signOut() async throws {
        UserCache.clear()
        try await dataSource.signOut()
    }

    func sendEmailCode(email: String) async throws {
        throw AppError.unknown("Email code auth is not yet configured.")
    }

    func verifyEmailCode(email: String, code: String) async throws -> User {
        throw AppError.unknown("Email code auth is not yet configured.")
    }
}
