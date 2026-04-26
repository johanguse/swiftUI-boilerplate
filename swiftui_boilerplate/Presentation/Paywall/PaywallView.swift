import SwiftUI

// MARK: - RevenueCatUI paywall (when RevenueCatUI package is linked)

#if canImport(RevenueCatUI)
import RevenueCatUI
import RevenueCat

struct AppPaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PaywallView()
            .onPurchaseCompleted { _ in dismiss() }
            .onRestoreCompleted { _ in dismiss() }
    }
}

// MARK: - Placeholder (when RevenueCat packages are not yet linked)

#else

struct AppPaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "star.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.appPrimary)

                VStack(spacing: 8) {
                    Text("Upgrade to Pro")
                        .font(.title2.bold())
                        .foregroundStyle(Color.appText)

                    Text("Add the RevenueCat and RevenueCatUI Swift Packages to activate the paywall.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSubtext)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "checkmark.seal.fill", text: "Full access to all features")
                    FeatureRow(icon: "checkmark.seal.fill", text: "Priority support")
                    FeatureRow(icon: "checkmark.seal.fill", text: "No ads")
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.appSubtext)
                }
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.appPrimary)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.appText)
        }
    }
}

#endif
