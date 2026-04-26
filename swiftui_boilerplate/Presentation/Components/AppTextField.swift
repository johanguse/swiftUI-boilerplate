import SwiftUI

struct AppTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var isSecure: Bool = false
    @State private var isSecureVisible: Bool = false

    private var autocapitalization: TextInputAutocapitalization {
        if isSecure || keyboardType == .emailAddress || keyboardType == .URL ||
            textContentType == .emailAddress || textContentType == .username {
            return .never
        }

        if textContentType == .name ||
            textContentType == .givenName ||
            textContentType == .familyName ||
            textContentType == .namePrefix ||
            textContentType == .nameSuffix {
            return .words
        }

        return .sentences
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.appSubtext)

            ZStack(alignment: .trailing) {
                Group {
                    if isSecure && !isSecureVisible {
                        SecureField(title, text: $text)
                    } else {
                        TextField(title, text: $text)
                    }
                }
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(autocapitalization)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .padding(.trailing, isSecure ? 44 : 0)
                .background(Color.appSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appDivider, lineWidth: 1)
                )

                if isSecure {
                    Button {
                        isSecureVisible.toggle()
                    } label: {
                        Image(systemName: isSecureVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(Color.appSubtext)
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var password = ""
    VStack(spacing: 16) {
        AppTextField(
            title: "Email",
            text: $email,
            keyboardType: .emailAddress,
            textContentType: .emailAddress
        )
        AppTextField(
            title: "Password",
            text: $password,
            textContentType: .password,
            isSecure: true
        )
    }
    .padding()
}
