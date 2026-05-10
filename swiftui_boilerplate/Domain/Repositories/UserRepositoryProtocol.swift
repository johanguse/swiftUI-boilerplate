import Foundation

@MainActor
protocol UserRepositoryProtocol: AnyObject {
    func updateProfile(_ user: User) async throws -> User
    func uploadAvatar(userId: String, imageData: Data) async throws -> String
    func registerPushToken(_ token: String) async throws
}
