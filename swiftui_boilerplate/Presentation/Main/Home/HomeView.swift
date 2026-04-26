import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    private let router: AppRouter
    private let localization: LocalizationManager

    init(container: AppContainer) {
        self.router = container.router
        self.localization = container.localizationManager
        _viewModel = State(initialValue: HomeViewModel(
            fetchUsersUseCase: FetchUsersUseCase(repository: container.userRepository),
            authRepository: container.authRepository
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    skeletonView
                } else {
                    greetingCard
                    peopleSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(localization.localizedString(for: .homeTitle))
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.loadUsers() }
        .refreshable { await viewModel.refresh() }
    }

    // MARK: - Greeting Card

    private var greetingCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)
                Text(viewModel.currentUser?.fullName ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appText)
                if let jobTitle = viewModel.currentUser?.jobTitle, !jobTitle.isEmpty {
                    Text(jobTitle)
                        .font(.caption)
                        .foregroundStyle(Color.appPrimary)
                }
            }
            Spacer()
            if let user = viewModel.currentUser {
                UserAvatarView(
                    systemName: user.avatarSystemName,
                    avatarUrl: user.avatarUrl,
                    size: .medium
                )
            }
        }
        .padding(20)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - People Section

    private var peopleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localizedString(for: .people).uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appSubtext)
                .padding(.horizontal, 4)

            if viewModel.users.isEmpty {
                emptyState
            } else {
                userList
            }
        }
    }

    private var userList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.users) { user in
                Button {
                    router.navigate(to: .userDetail(user))
                } label: {
                    UserRowView(user: user)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .onAppear {
                    if user.id == viewModel.users.last?.id {
                        Task { await viewModel.loadMore() }
                    }
                }

                if user.id != viewModel.users.last?.id {
                    Divider().padding(.leading, 72)
                }
            }

            if viewModel.isLoadingMore {
                ProgressView()
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.appSubtext.opacity(0.5))
            Text(localization.localizedString(for: .noUsersYet))
                .font(.subheadline)
                .foregroundStyle(Color.appSubtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Skeleton

    private var skeletonView: some View {
        VStack(spacing: 20) {
            // Greeting card skeleton
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    SkeletonBox(width: 80, height: 13, cornerRadius: 6)
                    SkeletonBox(width: 160, height: 22, cornerRadius: 6)
                    SkeletonBox(width: 100, height: 12, cornerRadius: 6)
                }
                Spacer()
                SkeletonCircle(size: 56)
            }
            .padding(20)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)

            // People section skeleton
            VStack(alignment: .leading, spacing: 12) {
                SkeletonBox(width: 55, height: 11, cornerRadius: 5)
                    .padding(.horizontal, 4)

                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { i in
                        skeletonUserRow
                        if i < 3 {
                            Divider().padding(.leading, 72)
                        }
                    }
                }
                .background(Color.appSurface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
        }
    }

    private var skeletonUserRow: some View {
        HStack(spacing: 12) {
            SkeletonCircle(size: 44)
            VStack(alignment: .leading, spacing: 6) {
                SkeletonBox(width: 130, height: 14, cornerRadius: 6)
                SkeletonBox(width: 85, height: 12, cornerRadius: 5)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Helpers

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let key: LocalizationKey = hour < 12 ? .goodMorning : hour < 17 ? .goodAfternoon : .goodEvening
        return localization.localizedString(for: key)
    }
}
