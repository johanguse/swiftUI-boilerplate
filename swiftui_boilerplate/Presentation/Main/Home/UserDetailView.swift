import SwiftUI

struct UserDetailView: View {
    let user: User
    let localization: LocalizationManager

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                    .padding(.bottom, 24)

                statsSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                Divider()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                infoSection
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(user.fullName)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 14) {
            UserAvatarView(systemName: user.avatarSystemName, avatarUrl: user.avatarUrl, size: .large)

            VStack(spacing: 6) {
                Text(user.fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appText)

                Text(user.jobTitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.appPrimary)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appSubtext)
                    Text(user.location)
                        .font(.caption)
                        .foregroundStyle(Color.appSubtext)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.horizontal, 24)
    }

    private var statsSection: some View {
        HStack {
            StatCell(value: user.followersCount, label: localization.localizedString(for: .followers))
            Divider().frame(height: 40)
            StatCell(value: user.followingCount, label: localization.localizedString(for: .following))
        }
        .padding(.vertical, 16)
        .primaryCardStyle()
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            InfoRow(icon: "envelope.fill", label: localization.localizedString(for: .email), value: user.email)
            Divider()
            InfoRow(icon: "text.quote", label: localization.localizedString(for: .bio), value: user.bio)
            Divider()
            InfoRow(icon: "mappin.and.ellipse", label: localization.localizedString(for: .location), value: user.location)
        }
    }
}

// MARK: - Supporting Views

private struct StatCell: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value.formatted())
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.appText)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appSubtext)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.appSubtext)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(Color.appText)
            }
        }
    }
}
