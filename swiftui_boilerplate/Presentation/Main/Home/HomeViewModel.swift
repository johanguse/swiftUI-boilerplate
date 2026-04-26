import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {
    var users: [User] = []
    var currentUser: User?
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var hasMorePages: Bool = true

    private let fetchUsersUseCase: FetchUsersUseCase
    private let authRepository: any AuthRepositoryProtocol
    private var currentOffset: Int = 0

    init(
        fetchUsersUseCase: FetchUsersUseCase,
        authRepository: any AuthRepositoryProtocol
    ) {
        self.fetchUsersUseCase = fetchUsersUseCase
        self.authRepository = authRepository
        self.currentUser = authRepository.currentUser
    }

    func loadUsers() async {
        isLoading = true
        currentOffset = 0
        currentUser = authRepository.currentUser
        do {
            let fetched = try await fetchUsersUseCase.execute(offset: 0)
            users = fetched
            currentOffset = fetched.count
            hasMorePages = fetched.count >= fetchUsersUseCase.pageSize
        } catch {
            users = []
            hasMorePages = false
        }
        isLoading = false
    }

    func loadMore() async {
        guard hasMorePages, !isLoadingMore, !isLoading else { return }
        isLoadingMore = true
        do {
            let fetched = try await fetchUsersUseCase.execute(offset: currentOffset)
            users.append(contentsOf: fetched)
            currentOffset += fetched.count
            hasMorePages = fetched.count >= fetchUsersUseCase.pageSize
        } catch {
            hasMorePages = false
        }
        isLoadingMore = false
    }

    func refresh() async {
        currentOffset = 0
        currentUser = authRepository.currentUser
        do {
            let fetched = try await fetchUsersUseCase.execute(offset: 0)
            users = fetched
            currentOffset = fetched.count
            hasMorePages = fetched.count >= fetchUsersUseCase.pageSize
        } catch {
            users = []
            hasMorePages = false
        }
    }

}
