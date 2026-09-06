import SwiftUI

extension View {
    // MARK: - Card Style
    func primaryCardStyle() -> some View {
        self
            .background(Color.appSurface)
            .clipShape(.rect(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Glassmorphic Card Style
    func glassmorphicCardStyle(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    // MARK: - Keyboard Dismissal
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }

    // MARK: - Localized Alerts
    func errorAlert(message: Binding<String?>, localization: LocalizationManager) -> some View {
        self.alert(
            localization.localizedString(for: .error),
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { if !$0 { message.wrappedValue = nil } }
            ),
            actions: {
                Button(localization.localizedString(for: .ok)) { message.wrappedValue = nil }
            },
            message: {
                if let msg = message.wrappedValue {
                    Text(msg)
                }
            }
        )
    }

    func successAlert(message: Binding<String?>, localization: LocalizationManager) -> some View {
        self.alert(
            localization.localizedString(for: .success),
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { if !$0 { message.wrappedValue = nil } }
            ),
            actions: {
                Button(localization.localizedString(for: .ok)) { message.wrappedValue = nil }
            },
            message: {
                if let msg = message.wrappedValue {
                    Text(msg)
                }
            }
        )
    }
}
