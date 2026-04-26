import Foundation

@MainActor
struct FetchUsersUseCase {
    private let repository: any UserRepositoryProtocol
    let pageSize: Int

    init(repository: any UserRepositoryProtocol, pageSize: Int = 20) {
        self.repository = repository
        self.pageSize = pageSize
    }

    func execute(offset: Int = 0) async throws -> [User] {
        try await repository.fetchUsers(limit: pageSize, offset: offset)
    }
}
