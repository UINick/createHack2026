import SwiftUI
import YouVersionPlatform

enum AppTab: String, CaseIterable {
    case read = "Read"
    case together = "Together"
    case you = "You"

    var icon: String {
        switch self {
        case .read: return "book.fill"
        case .together: return "person.2.fill"
        case .you: return "person.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .read

    var body: some View {
        ZStack(alignment: .bottom) {
            ZmodeTheme.background
                .ignoresSafeArea()

            switch selectedTab {
            case .read:
                ZmodeScrollView(
                    versionId: 3254,
                    bookUSFM: "JHN",
                    chapter: 15
                )
            case .together:
                placeholderTab(title: "Together", icon: "person.2.fill")
            case .you:
                placeholderTab(title: "You", icon: "person.fill")
            }

            tabBar
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20))
                            .frame(height: 24)

                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .medium))
                            .tracking(-0.25)
                    }
                    .foregroundStyle(
                        selectedTab == tab ? ZmodeTheme.accent : ZmodeTheme.tabInactive
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
        .padding(.horizontal, 8)
        .background(
            ZmodeTheme.background
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(ZmodeTheme.border)
                        .frame(height: 0.5)
                }
        )
    }

    private func placeholderTab(title: String, icon: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(ZmodeTheme.textSecondary)
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(ZmodeTheme.textPrimary)
            Text("Coming soon")
                .font(.system(size: 13))
                .foregroundStyle(ZmodeTheme.textSecondary)
        }
    }
}

#Preview {
    ContentView()
}
