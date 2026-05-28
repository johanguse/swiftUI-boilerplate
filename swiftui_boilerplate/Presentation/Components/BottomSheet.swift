import SwiftUI

struct BottomSheetHeader: View {
    var title: String? = nil
    var showDragHandle: Bool = true
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            if showDragHandle {
                Capsule()
                    .fill(Color.appSubtext.opacity(0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
            }

            if title != nil || onDismiss != nil {
                HStack {
                    if let title {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    if let onDismiss {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.appSubtext.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, showDragHandle ? 12 : 20)
                .padding(.bottom, 16)
            }
        }
    }
}

extension View {
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.medium, .large],
        showDragIndicator: Visibility = .hidden,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            content()
                .presentationDetents(detents)
                .presentationDragIndicator(showDragIndicator)
        }
    }

    func bottomSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        detents: Set<PresentationDetent> = [.medium, .large],
        showDragIndicator: Visibility = .hidden,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        self.sheet(item: item) { value in
            content(value)
                .presentationDetents(detents)
                .presentationDragIndicator(showDragIndicator)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showSheet = false

        var body: some View {
            Button("Show Sheet") { showSheet = true }
                .bottomSheet(isPresented: $showSheet, detents: [.medium]) {
                    VStack(spacing: 0) {
                        BottomSheetHeader(title: "Options", onDismiss: { showSheet = false })

                        VStack(spacing: 12) {
                            Text("Sheet content goes here")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)

                        Spacer()
                    }
                }
        }
    }

    return PreviewWrapper()
}
