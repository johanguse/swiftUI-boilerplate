import SwiftUI

struct UserAvatarView: View {

    let systemName: String
    var avatarUrl: String? = nil
    var size: AvatarSize = .medium

    enum AvatarSize {
        case small, medium, large

        var dimension: CGFloat {
            switch self {
            case .small:  return 40
            case .medium: return 56
            case .large:  return 100
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small:  return 18
            case .medium: return 24
            case .large:  return 44
            }
        }
    }

    var body: some View {
        if let urlString = avatarUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Circle()
                        .fill(Color.appSurface)
                        .frame(width: size.dimension, height: size.dimension)
                        .overlay { ProgressView().tint(.appSubtext) }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                case .failure:
                    fallbackView
                @unknown default:
                    fallbackView
                }
            }
        } else {
            fallbackView
        }
    }

    private var fallbackView: some View {
        ZStack {
            Circle()
                .fill(Color.appPrimary.gradient)
                .frame(width: size.dimension, height: size.dimension)

            Image(systemName: systemName)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        UserAvatarView(systemName: "person.fill", size: .small)
        UserAvatarView(systemName: "swift", size: .medium)
        UserAvatarView(systemName: "paintbrush.fill", size: .large)
    }
    .padding()
}
