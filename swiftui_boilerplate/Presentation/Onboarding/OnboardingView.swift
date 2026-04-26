import SwiftUI

struct OnboardingView: View {
    let localization: LocalizationManager
    let onComplete: () -> Void

    @State private var currentPage = 0
    private let totalPages = 3

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                featuresPage.tag(1)
                readyPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            if currentPage < 2 {
                Button(localization.localizedString(for: .onboardingSkip)) {
                    HapticsManager.impact(.light)
                    withAnimation { currentPage = 2 }
                }
                .font(.subheadline)
                .foregroundStyle(Color.appSubtext)
                .padding(.top, 60)
                .padding(.trailing, 24)
                .transition(.opacity)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.12))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(Color.appPrimary.opacity(0.2))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(Color.appPrimary.gradient)
                    .frame(width: 88, height: 88)
                Image(systemName: "person.2.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 48)

            VStack(spacing: 12) {
                Text(localization.localizedString(for: .onboardingWelcomeTitle))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appText)

                Text(localization.localizedString(for: .onboardingWelcomeSubtitle))
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()
            pageIndicator
            bottomButton(title: localization.localizedString(for: .onboardingNext)) {
                withAnimation { currentPage = 1 }
            }
        }
        .padding(.bottom, 48)
    }

    // MARK: - Page 2: Features

    private var featuresPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                Text(localization.localizedString(for: .onboardingFeaturesTitle))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appText)
                    .multilineTextAlignment(.center)

                Text(localization.localizedString(for: .onboardingFeaturesSubtitle))
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 40)

            VStack(spacing: 16) {
                FeatureRow(
                    icon: "lock.shield.fill",
                    color: .indigo,
                    title: localization.localizedString(for: .featureSecureTitle),
                    description: localization.localizedString(for: .featureSecureDesc)
                )
                FeatureRow(
                    icon: "bolt.fill",
                    color: .orange,
                    title: localization.localizedString(for: .featureFastTitle),
                    description: localization.localizedString(for: .featureFastDesc)
                )
                FeatureRow(
                    icon: "globe.americas.fill",
                    color: .green,
                    title: localization.localizedString(for: .featureGlobalTitle),
                    description: localization.localizedString(for: .featureGlobalDesc)
                )
            }
            .padding(.horizontal, 24)

            Spacer()
            pageIndicator
            bottomButton(title: localization.localizedString(for: .onboardingNext)) {
                withAnimation { currentPage = 2 }
            }
        }
        .padding(.bottom, 48)
    }

    // MARK: - Page 3: Ready

    private var readyPage: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.appSuccess.opacity(0.12))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(Color.appSuccess.opacity(0.2))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(Color.appSuccess)
                    .frame(width: 88, height: 88)
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 48)

            VStack(spacing: 12) {
                Text(localization.localizedString(for: .onboardingReadyTitle))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appText)

                Text(localization.localizedString(for: .onboardingReadySubtitle))
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()
            pageIndicator
            bottomButton(title: localization.localizedString(for: .onboardingGetStarted)) {
                HapticsManager.success()
                onComplete()
            }
        }
        .padding(.bottom, 48)
    }

    // MARK: - Shared components

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? Color.appPrimary : Color.appSubtext.opacity(0.3))
                    .frame(width: currentPage == index ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
        .padding(.bottom, 24)
    }

    private func bottomButton(title: String, action: @escaping () -> Void) -> some View {
        PrimaryButton(title: title, action: action)
            .padding(.horizontal, 24)
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(color.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appText)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.appSubtext)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
