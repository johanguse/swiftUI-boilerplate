import SwiftUI

extension View {
    func borderBeam(
        cornerRadius: CGFloat = 12,
        lineWidth: CGFloat = 1.5,
        beamColor: Color = .appPrimary,
        highlightColor: Color = .white,
        duration: Double = 2.5,
        showsGlow: Bool = true
    ) -> some View {
        modifier(BorderBeamModifier(
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            beamColor: beamColor,
            highlightColor: highlightColor,
            duration: duration,
            showsGlow: showsGlow
        ))
    }
}

private struct BorderBeamModifier: ViewModifier {
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let beamColor: Color
    let highlightColor: Color
    let duration: Double
    let showsGlow: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content.overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(beamColor.opacity(0.3), lineWidth: lineWidth)
            )
        } else {
            content.overlay(
                TimelineView(.animation) { context in
                    BorderBeamLayer(
                        cornerRadius: cornerRadius,
                        angle: angle(for: context.date),
                        width: lineWidth,
                        beamColor: beamColor,
                        highlightColor: highlightColor,
                        showsGlow: showsGlow
                    )
                }
            )
        }
    }

    @State private var startDate = Date.now

    private func angle(for date: Date) -> Angle {
        let elapsed = date.timeIntervalSince(startDate)
        let progress = (elapsed.truncatingRemainder(dividingBy: duration)) / duration
        return .degrees(progress * 360)
    }
}

private struct BorderBeamLayer: View {
    let cornerRadius: CGFloat
    let angle: Angle
    let width: CGFloat
    let beamColor: Color
    let highlightColor: Color
    let showsGlow: Bool

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let gradient = AngularGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .clear, location: 0.35),
                .init(color: beamColor.opacity(0.6), location: 0.42),
                .init(color: highlightColor, location: 0.5),
                .init(color: beamColor.opacity(0.6), location: 0.58),
                .init(color: .clear, location: 0.65),
                .init(color: .clear, location: 1)
            ],
            center: .center,
            angle: angle
        )

        ZStack {
            shape.strokeBorder(beamColor.opacity(0.16), lineWidth: width)
            if showsGlow {
                shape.strokeBorder(gradient, lineWidth: width + 5).blur(radius: 6).opacity(0.55)
                shape.strokeBorder(gradient, lineWidth: width + 2).blur(radius: 1.5).opacity(0.65)
            }
            shape.strokeBorder(gradient, lineWidth: width)
        }
    }
}
