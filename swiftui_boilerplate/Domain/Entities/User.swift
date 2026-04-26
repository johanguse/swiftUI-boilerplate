import Foundation

struct User: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let fullName: String
    let email: String
    let avatarSystemName: String
    let avatarUrl: String?          // Remote URL from Supabase Storage (nil → use SF Symbol)
    let jobTitle: String
    let location: String
    let bio: String
    let followersCount: Int
    let followingCount: Int

    // MARK: - Partial Update Helper

    /// Returns a new `User` with only the specified fields changed.
    /// Any parameter left as `nil` retains the current value.
    func updated(
        fullName: String? = nil,
        email: String? = nil,
        avatarSystemName: String? = nil,
        avatarUrl: String?? = nil,
        jobTitle: String? = nil,
        location: String? = nil,
        bio: String? = nil,
        followersCount: Int? = nil,
        followingCount: Int? = nil
    ) -> User {
        User(
            id: id,
            fullName: fullName ?? self.fullName,
            email: email ?? self.email,
            avatarSystemName: avatarSystemName ?? self.avatarSystemName,
            avatarUrl: avatarUrl ?? self.avatarUrl,
            jobTitle: jobTitle ?? self.jobTitle,
            location: location ?? self.location,
            bio: bio ?? self.bio,
            followersCount: followersCount ?? self.followersCount,
            followingCount: followingCount ?? self.followingCount
        )
    }
}
