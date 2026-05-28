import SwiftUI

struct ProBadge: View {
    var isLocked: Bool = false
    var fontSize: CGFloat = 9

    var body: some View {
        Text("PRO")
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.appPrimary.opacity(isLocked ? 0.12 : 0.25))
            .foregroundStyle(isLocked ? Color.appSubtext : Color.appPrimary)
            .clipShape(.rect(cornerRadius: 4))
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack {
            Text("Feature Name")
            ProBadge()
        }

        HStack {
            Text("Locked Feature")
                .foregroundStyle(.secondary)
            ProBadge(isLocked: true)
        }
    }
    .padding()
}
