import SwiftUI

struct SocialAuthButton: View {
    let title: String
    let symbol: String
    let badgeText: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                socialMark

                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appText)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .padding(.horizontal, 16)
            .clipShape(.rect(cornerRadius: 14))
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.06))
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var socialMark: some View {
        if let badgeText {
            Text(badgeText)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(Color.black)
                .frame(width: 24, height: 24)
                .background(Color.white)
                .clipShape(.rect(cornerRadius: 7))
        } else {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SocialAuthButton(title: "Continue with Apple", symbol: "apple.logo", badgeText: nil) {}
        SocialAuthButton(title: "Continue with Google", symbol: "", badgeText: "G") {}
        SocialAuthButton(title: "Continue with Email", symbol: "envelope.fill", badgeText: nil) {}
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
