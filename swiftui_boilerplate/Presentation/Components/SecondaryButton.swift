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
            .background(Color.appBackground)
            .foregroundStyle(Color.appPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
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
