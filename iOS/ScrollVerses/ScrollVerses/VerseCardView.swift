import SwiftUI
import YouVersionPlatform

struct VerseCardView: View {
    let versionId: Int
    let bookUSFM: String
    let chapter: Int
    let verseNumber: Int
    let totalVerses: Int
    @Binding var showContext: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZmodeTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    ZStack(alignment: .trailing) {
                        Text("\(verseNumber)")
                            .font(.system(size: 120, weight: .light, design: .serif))
                            .foregroundStyle(ZmodeTheme.verseNumberColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, -8)

                        BibleTextView(
                            BibleReference(
                                versionId: versionId,
                                bookUSFM: bookUSFM,
                                chapter: chapter,
                                verse: verseNumber
                            )
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 40)
                    }
                    .padding(.horizontal, 32)

                    Spacer()

                    verseFooter
                        .padding(.horizontal, 32)
                        .padding(.bottom, 28)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var verseFooter: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BLT — Biblia Livre Para Todos")
                .font(.system(size: 9))
                .tracking(0.45)
                .foregroundStyle(ZmodeTheme.textSecondary)

            HStack {
                contextButton

                Spacer()

                scrollIndicator
            }
        }
    }

    private var contextButton: some View {
        Button {
            showContext = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                Text("Context")
                    .font(.system(size: 12))
            }
            .foregroundStyle(ZmodeTheme.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(ZmodeTheme.cardBackground)
            .clipShape(Capsule())
        }
    }

    private var scrollIndicator: some View {
        HStack(spacing: 6) {
            Image(systemName: "chevron.down")
                .font(.system(size: 8, weight: .medium))
            Text("SCROLL")
                .font(.system(size: 9))
                .tracking(0.9)
        }
        .foregroundStyle(ZmodeTheme.textSecondary)
    }
}
