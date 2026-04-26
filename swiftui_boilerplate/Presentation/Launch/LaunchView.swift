import SwiftUI

struct LaunchView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var dotScale: CGFloat = 0.5
    @State private var dotOpacity: Double = 0
    @State private var isPulsing: Bool = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.appPrimary.opacity(0.15), Color.appBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isPulsing ? 1.12 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                            value: isPulsing
                        )

                    Circle()
                        .fill(Color.appPrimary.gradient)
                        .frame(width: 96, height: 96)

                    Image(systemName: "person.2.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // App name
                VStack(spacing: 6) {
                    Text("Boilerplate")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appText)

                    Text("Connect with people")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSubtext)
                }
                .padding(.top, 24)
                .offset(y: titleOffset)
                .opacity(titleOpacity)

                Spacer()

                // Loading dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        LoadingDot(index: index)
                    }
                }
                .opacity(subtitleOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear { runAnimations() }
    }

    private func runAnimations() {
        // Logo pop in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Title slide up
        withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
            titleOffset = 0
            titleOpacity = 1.0
        }

        // Dots fade in
        withAnimation(.easeIn(duration: 0.3).delay(0.45)) {
            subtitleOpacity = 1.0
        }

        // Pulse ring
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPulsing = true
        }
    }
}

// MARK: - Loading Dot

private struct LoadingDot: View {
    let index: Int
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(Color.appPrimary)
            .frame(width: 8, height: 8)
            .scaleEffect(isAnimating ? 1.0 : 0.5)
            .opacity(isAnimating ? 1.0 : 0.3)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.15)
                ) {
                    isAnimating = true
                }
            }
    }
}
