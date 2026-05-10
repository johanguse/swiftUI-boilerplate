import Foundation

@MainActor
struct FetchUsersUseCase {
    // Placeholder — the Cloudflare Hono backend does not expose a users list endpoint.
    // To enable this feature, add a `/api/v1/users` route to the backend,
    // add `fetchUsers(limit:offset:)` to UserRepositoryProtocol, implement it in
    // APIUserRepository, and restore the real implementation here.
    let pageSize: Int

    init(repository: any UserRepositoryProtocol, pageSize: Int = 20) {
        self.pageSize = pageSize
    }

    func execute(offset: Int = 0) async throws -> [User] {
        return []
    }
}
