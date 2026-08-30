import SwiftUI

struct ContextSheetView: View {
    let context: ChapterContext
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            handleBar
            headerSection
            Divider().background(ZmodeTheme.border)
            contentScroll
        }
        .background(ZmodeTheme.sheetBackground)
    }

    private var handleBar: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 100)
                .fill(ZmodeTheme.sheetHandle)
                .frame(width: 40, height: 3)
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("CONTEXT")
                    .font(.system(size: 9, weight: .regular))
                    .tracking(0.9)
                    .textCase(.uppercase)
                    .foregroundStyle(ZmodeTheme.accent)

                Text(context.referenceDisplay)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ZmodeTheme.textPrimary)
            }

            Spacer()

            Button(action: onDismiss) {
                Text("✕")
                    .font(.system(size: 13))
                    .foregroundStyle(ZmodeTheme.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color(red: 0.118, green: 0.133, blue: 0.212))
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    private var contentScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                summarySection

                ForEach(context.sections) { section in
                    contextSectionView(section)
                }

                exploreButton
            }
            .padding(.bottom, 32)
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(context.summaryTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ZmodeTheme.textPrimary)

            Text(context.summary)
                .font(.system(size: 14, weight: .regular))
                .lineSpacing(8)
                .foregroundStyle(ZmodeTheme.textSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    private func contextSectionView(_ section: ContextSection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(ZmodeTheme.border)
                .frame(height: 0.5)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 8) {
                Text(section.label)
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundStyle(ZmodeTheme.accent)

                if let title = section.title {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(ZmodeTheme.textPrimary)
                }

                Text(section.body)
                    .font(.system(size: 14, weight: .regular))
                    .lineSpacing(8)
                    .foregroundStyle(ZmodeTheme.textSecondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 4)
        }
    }

    private var exploreButton: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(ZmodeTheme.border)
                .frame(height: 0.5)
                .padding(.top, 4)

            Button(action: {}) {
                Text("Explore full context →")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(ZmodeTheme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }
}
