import Foundation

@MainActor
final class APIUserRepository: UserRepositoryProtocol {

    private let dataSource: APIDataSource

    init(dataSource: APIDataSource) {
        self.dataSource = dataSource
    }

    func fetchUsers(limit: Int = 20, offset: Int = 0) async throws -> [User] {
        try await dataSource.fetchUsers(limit: limit, offset: offset).map { $0.toDomain() }
    }

    func updateProfile(_ user: User) async throws -> User {
        let updated = try await dataSource.updateProfile(user).toDomain()
        UserCache.save(updated)
        return updated
    }

    func uploadAvatar(userId: String, imageData: Data) async throws -> String {
        try await dataSource.uploadAvatar(userId: userId, imageData: imageData)
    }

    func registerPushToken(_ token: String) async throws {
        try? await dataSource.registerPushToken(token)
    }
}
