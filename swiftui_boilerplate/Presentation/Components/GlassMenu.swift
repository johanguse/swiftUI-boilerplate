import SwiftUI

struct GlassMenu<Label: View>: View {
    let items: [GlassMenuItem]
    @ViewBuilder let label: () -> Label

    var body: some View {
        Menu {
            ForEach(items) { item in
                if item.isDivider {
                    Divider()
                } else {
                    Button(role: item.role) {
                        item.action()
                    } label: {
                        SwiftUI.Label(item.title, systemImage: item.icon)
                    }
                }
            }
        } label: {
            label()
                .padding(10)
                .glassCapsule()
        }
    }
}

struct GlassMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    var role: ButtonRole? = nil
    var isDivider: Bool = false
    var action: () -> Void = {}

    static func divider() -> GlassMenuItem {
        GlassMenuItem(title: "", icon: "", isDivider: true)
    }
}

struct GlassToolbar: View {
    let items: [GlassToolbarItem]

    var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: 12) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        Button(action: item.action) {
                            Image(systemName: item.icon)
                                .font(.title3)
                                .frame(width: 44, height: 44)
                        }
                        .glassEffect(.regular.interactive(), in: .circle)
                    }
                }
            }
        } else {
            HStack(spacing: 12) {
                ForEach(items) { item in
                    Button(action: item.action) {
                        Image(systemName: item.icon)
                            .font(.title3)
                            .frame(width: 44, height: 44)
                    }
                    .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
    }
}

struct GlassToolbarItem: Identifiable {
    let id = UUID()
    let icon: String
    let action: () -> Void
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 24) {
            GlassMenu(items: [
                GlassMenuItem(title: "Edit", icon: "pencil") {},
                GlassMenuItem(title: "Share", icon: "square.and.arrow.up") {},
                .divider(),
                GlassMenuItem(title: "Delete", icon: "trash", role: .destructive) {}
            ]) {
                Image(systemName: "ellipsis")
                    .font(.title3)
            }

            GlassToolbar(items: [
                GlassToolbarItem(icon: "pencil") {},
                GlassToolbarItem(icon: "eraser") {},
                GlassToolbarItem(icon: "scissors") {},
                GlassToolbarItem(icon: "square.and.arrow.up") {}
            ])
        }
    }
}
