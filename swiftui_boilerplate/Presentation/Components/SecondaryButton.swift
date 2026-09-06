import SwiftUI

struct SecondaryButton: View {
    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(Color.appPrimary)
                } else {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(Color.appPrimary)
            .clipShape(.rect(cornerRadius: 14))
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.appBackground)
                    .stroke(Color.appPrimary, lineWidth: 1.5)
            )
        }
        .disabled(isLoading)
        .animation(.easeInOut, value: isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        SecondaryButton(title: "Create Account") {}
        SecondaryButton(title: "Loading", isLoading: true) {}
    }
    .padding()
}
