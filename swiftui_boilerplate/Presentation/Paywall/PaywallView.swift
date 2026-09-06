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

// MARK: - Native StoreKit 2 paywall (no RevenueCat)

#else
import StoreKit

struct AppPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appContainer) private var container

    @State private var selectedIndex = 0

    private var loc: LocalizationManager { container.localizationManager }
    private var purchaseManager: PurchaseManager { container.purchaseManager }

    // Ordered: yearly, monthly, weekly — match your App Store Connect IDs
    private var orderedProducts: [Product] {
        let order = ["pro_yearly", "pro_monthly", "pro_weekly"]
        return order.compactMap { id in purchaseManager.products.first { $0.id == id } }
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                closeButton
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        heroSection
                        benefitsCard
                        if !orderedProducts.isEmpty {
                            pricingCards
                        }
                        ctaSection
                        disclaimer
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .task { await purchaseManager.loadProducts() }
        .errorAlert(message: Bindable(purchaseManager).errorMessage, localization: loc)
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            EllipticalGradient(
                colors: [Color.appPrimary.opacity(0.3), Color.clear],
                center: .top,
                endRadiusFraction: 0.65
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Close

    private var closeButton: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Label(loc.localizedString(for: .close), systemImage: "xmark")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appSubtext)
                    .frame(width: 36, height: 36)
                    .background(Color.appSubtext.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(loc.localizedString(for: .close))
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.15))
                    .frame(width: 110, height: 110)
                Image(systemName: "flame.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.appPrimary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 8) {
                Text(loc.localizedString(for: .paywallProTitle))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appText)

                Text(loc.localizedString(for: .paywallProSubtitle))
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Benefits

    private var benefitsCard: some View {
        VStack(spacing: 14) {
            PaywallBenefitRow(icon: "checkmark.seal.fill", text: loc.localizedString(for: .paywallBenefitAllFeatures))
            PaywallBenefitRow(icon: "eye.slash.fill", text: loc.localizedString(for: .paywallBenefitNoAds))
            PaywallBenefitRow(icon: "bolt.heart.fill", text: loc.localizedString(for: .paywallBenefitPrioritySupport))
            PaywallBenefitRow(icon: "star.fill", text: loc.localizedString(for: .paywallBenefitExclusive))
        }
        .padding(20)
        .clipShape(.rect(cornerRadius: 20))
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Pricing cards

    private var pricingCards: some View {
        VStack(spacing: 10) {
            ForEach(Array(orderedProducts.enumerated()), id: \.element.id) { index, product in
                PaywallPricingCard(
                    product: product,
                    badge: badge(for: index),
                    isSelected: selectedIndex == index
                ) {
                    selectedIndex = index
                }
            }
        }
    }

    private func badge(for index: Int) -> String? {
        switch index {
        case 0: return loc.localizedString(for: .paywallBestValue)
        case 1: return loc.localizedString(for: .paywallPopular)
        default: return nil
        }
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: 16) {
            if orderedProducts.isEmpty {
                PrimaryButton(title: loc.localizedString(for: .paywallStartPro), isLoading: true) {}
            } else {
                PrimaryButton(title: loc.localizedString(for: .paywallStartPro)) {
                    Task {
                        let product = orderedProducts[selectedIndex]
                        do {
                            try await purchaseManager.purchase(product)
                            if purchaseManager.isProUser { dismiss() }
                        } catch {
                            purchaseManager.errorMessage = error.localizedDescription
                        }
                    }
                }

                Button(loc.localizedString(for: .restorePurchases)) {
                    Task {
                        await purchaseManager.restorePurchases()
                        if purchaseManager.isProUser { dismiss() }
                    }
                }
                .font(.subheadline)
                .foregroundStyle(Color.appSubtext)
            }
        }
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {
        Text(loc.localizedString(for: .paywallSubscriptionDisclaimer))
            .font(.caption)
            .foregroundStyle(Color.appSubtext.opacity(0.6))
            .multilineTextAlignment(.center)
    }
}

// MARK: - Supporting views

private struct PaywallBenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.appText)
            Spacer()
        }
    }
}

private struct PaywallPricingCard: View {
    let product: Product
    let badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(product.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appText)
                    Text(product.displayPrice)
                        .font(.caption)
                        .foregroundStyle(Color.appSubtext)
                }

                Spacer()

                if let badge {
                    Text(badge)
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(Color.appBackground)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appPrimary)
                        .clipShape(Capsule())
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color.appPrimary : Color.appSubtext.opacity(0.4))
                    .padding(.leading, 8)
            }
            .padding(16)
            .clipShape(.rect(cornerRadius: 16))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.appPrimary.opacity(0.12) : Color.white.opacity(0.05))
                    .stroke(
                        isSelected ? Color.appPrimary.opacity(0.6) : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#endif
