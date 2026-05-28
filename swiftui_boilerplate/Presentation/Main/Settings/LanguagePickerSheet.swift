import SwiftUI

struct LanguagePickerSheet: View {
    let localization: LocalizationManager
    @Binding var languageBinding: AppLanguage
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(localization.localizedString(for: .language))
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider()

            ForEach(AppLanguage.allCases) { language in
                Button {
                    languageBinding = language
                    isPresented = false
                } label: {
                    HStack(spacing: 12) {
                        Text(language.flag)
                            .font(.title3)
                        Text(language.displayName)
                            .font(.subheadline)
                            .foregroundStyle(Color.appText)
                        Spacer()
                        if languageBinding == language {
                            Image(systemName: "checkmark")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appPrimary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if language != AppLanguage.allCases.last {
                    Divider().padding(.horizontal, 24)
                }
            }
        }
        .background(Color.appSurface.ignoresSafeArea())
    }
}
