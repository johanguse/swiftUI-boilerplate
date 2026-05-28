import SwiftUI

struct LaunchView: View {
    @State private var ringTrim: CGFloat = 0
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var wordmarkOffset: CGFloat = 16
    @State private var wordmarkOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    // Sweep ring
                    Circle()
                        .trim(from: 0, to: ringTrim)
                        .stroke(
                            AngularGradient(
                                colors: [Color.appPrimary.opacity(0), Color.appPrimary],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 110, height: 110)
                        .rotationEffect(.degrees(-90))

                    // Logo
                    Circle()
                        .fill(Color.appPrimary.gradient)
                        .frame(width: 88, height: 88)
                        .overlay {
                            Image(systemName: "swift")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                // Wordmark
                VStack(spacing: 4) {
                    Text("Boilerplate")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appText)

                    Text("launch_tagline")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSubtext)
                }
                .offset(y: wordmarkOffset)
                .opacity(wordmarkOpacity)
                .padding(.top, 20)

                Spacer()
            }
        }
        .onAppear { runAnimations() }
    }

    private func runAnimations() {
        // Logo spring in
        withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Ring sweep clockwise
        withAnimation(.easeInOut(duration: 0.9).delay(0.15)) {
            ringTrim = 1.0
        }

        // Wordmark slide up
        withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
            wordmarkOffset = 0
            wordmarkOpacity = 1.0
        }
    }
}
