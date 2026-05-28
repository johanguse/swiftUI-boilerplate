import SwiftUI

struct ProPromoCard: View {
    let title: String
    let subtitle: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.15),
                                Color.appSecondary.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(alignment: .leading, spacing: 14) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.appPrimary)
                        .symbolEffect(.pulse)

                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appText)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.appSubtext)
                        .lineLimit(2)

                    Text(actionTitle)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.appPrimary)
                        .clipShape(Capsule())
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)

                ProBadge(fontSize: 11)
                    .padding(16)
            }
        }
        .buttonStyle(.plain)
        .borderBeam(cornerRadius: 20, beamColor: .appPrimary)
    }
}

#Preview {
    ProPromoCard(
        title: "Unlock Premium",
        subtitle: "Get access to all features and more",
        actionTitle: "Upgrade Now"
    ) {}
    .padding()
}
