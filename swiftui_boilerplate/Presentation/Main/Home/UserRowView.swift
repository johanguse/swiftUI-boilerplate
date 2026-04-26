import SwiftUI

struct UserRowView: View {
    let user: User

    var body: some View {
        HStack(spacing: 14) {
            UserAvatarView(systemName: user.avatarSystemName, avatarUrl: user.avatarUrl, size: .medium)

            VStack(alignment: .leading, spacing: 3) {
                Text(user.fullName)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appText)

                Text(user.jobTitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appTertiary)
                    Text(user.location)
                        .font(.caption)
                        .foregroundStyle(Color.appTertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTertiary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    UserRowView(user: User(
        id: "1",
        fullName: "Alex Johnson",
        email: "alex@test.com",
        avatarSystemName: "swift",
        avatarUrl: nil,
        jobTitle: "iOS Engineer",
        location: "San Francisco, CA",
        bio: "Passionate about crafting beautiful iOS experiences.",
        followersCount: 1_240,
        followingCount: 380
    ))
    .padding(.horizontal)
}
