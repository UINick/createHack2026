import SwiftUI
import YouVersionPlatform

struct ZmodeScrollView: View {
    let versionId: Int
    let initialBookUSFM: String
    let initialChapter: Int

    @State private var bookUSFM: String
    @State private var chapter: Int
    @State private var verseCount: Int = 0
    @State private var currentVerse: Int = 1
    @State private var pendingScrollVerse: Int?
    @State private var isLoading = true
    @State private var showContext = false
    @State private var showPicker = false
    @StateObject private var contextProvider = ContextProvider()

    init(versionId: Int, bookUSFM: String, chapter: Int) {
        self.versionId = versionId
        self.initialBookUSFM = bookUSFM
        self.initialChapter = chapter
        _bookUSFM = State(initialValue: bookUSFM)
        _chapter = State(initialValue: chapter)
    }

    private var bookDisplayName: String {
        BibleBooks.name(for: bookUSFM)
    }

    var body: some View {
        ZStack {
            ZmodeTheme.background
                .ignoresSafeArea()

            if isLoading {
                loadingView
            } else {
                VStack(spacing: 0) {
                    headerBar
                    versePager
                }
            }
        }
        .sheet(isPresented: $showContext) {
            contextSheetContent
        }
        .sheet(isPresented: $showPicker) {
            VersePickerView(
                versionId: versionId,
                initialBook: bookUSFM,
                initialChapter: chapter
            ) { book, newChapter, verse in
                jumpTo(book: book, chapter: newChapter, verse: verse)
            }
            .presentationDetents([.fraction(0.8), .large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(ZmodeTheme.sheetBackground)
            .presentationCornerRadius(28)
        }
        .onChange(of: showContext) { _, isShowing in
            if isShowing {
                Task {
                    await contextProvider.loadContext(for: bookUSFM, chapter: chapter)
                }
            }
        }
        .task(id: "\(bookUSFM).\(chapter)") {
            await loadVerseCount()
        }
    }

    @ViewBuilder
    private var contextSheetContent: some View {
        if let context = contextProvider.currentContext {
            ContextSheetView(context: context) {
                showContext = false
            }
            .presentationDetents([.fraction(0.7), .large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(ZmodeTheme.sheetBackground)
            .presentationCornerRadius(28)
        } else if contextProvider.isLoading {
            VStack(spacing: 16) {
                ProgressView()
                    .tint(ZmodeTheme.accent)
                Text("Loading context...")
                    .font(.system(size: 13))
                    .foregroundStyle(ZmodeTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .presentationDetents([.fraction(0.4)])
            .presentationBackground(ZmodeTheme.sheetBackground)
            .presentationCornerRadius(28)
        } else {
            VStack(spacing: 16) {
                Image(systemName: "text.book.closed")
                    .font(.system(size: 32))
                    .foregroundStyle(ZmodeTheme.textSecondary)
                Text(contextProvider.errorMessage ?? "No context available for this chapter yet.")
                    .font(.system(size: 14))
                    .foregroundStyle(ZmodeTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .presentationDetents([.fraction(0.3)])
            .presentationBackground(ZmodeTheme.sheetBackground)
            .presentationCornerRadius(28)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(ZmodeTheme.accent)
            Text("Loading chapter...")
                .font(.system(size: 13))
                .foregroundStyle(ZmodeTheme.textSecondary)
        }
    }

    private var headerBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(bookDisplayName) • \(chapter):\(currentVerse)")
                    .font(.system(size: 10, weight: .regular))
                    .tracking(2)
                    .textCase(.uppercase)
                    .foregroundStyle(ZmodeTheme.textSecondary)

                Spacer()

                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "sun.min")
                            .font(.system(size: 12))
                        Text("Focus")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(ZmodeTheme.textSecondary)

                    HStack(spacing: 4) {
                        Text("BLT")
                            .font(.system(size: 11))
                        Text("▾")
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(ZmodeTheme.textSecondary)
                }
            }

            HStack {
                Button {
                    showPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Text("\(bookDisplayName) \(chapter)")
                            .font(.system(size: 9))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 7, weight: .semibold))
                    }
                    .foregroundStyle(ZmodeTheme.textSecondary)
                }

                Spacer()

                Button {
                    showContext = true
                } label: {
                    Text("CONTEXT")
                        .font(.system(size: 9))
                        .tracking(0.9)
                        .foregroundStyle(ZmodeTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(ZmodeTheme.background)
    }

    private var versePager: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(1...max(verseCount, 1), id: \.self) { verse in
                    VerseCardView(
                        versionId: versionId,
                        bookUSFM: bookUSFM,
                        chapter: chapter,
                        verseNumber: verse,
                        totalVerses: verseCount,
                        showContext: $showContext
                    )
                    .containerRelativeFrame(.vertical)
                    .id(verse)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: Binding(
            get: { currentVerse as Int? },
            set: { if let v = $0 { currentVerse = v } }
        ))
    }

    private func jumpTo(book: String, chapter newChapter: Int, verse: Int) {
        pendingScrollVerse = verse
        bookUSFM = book
        chapter = newChapter
    }

    private func loadVerseCount() async {
        isLoading = true

        guard let url = URL(string: "https://api.youversion.com/v1/bibles/\(versionId)/books/\(bookUSFM)/chapters/\(chapter)/verses") else {
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("8nZ6ypn8l1PchS90c73izURRSBQXOrYjULXEXIobGE0GQ0Vu", forHTTPHeaderField: "X-YVP-App-Key")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let verses = json["data"] as? [[String: Any]] {
                verseCount = verses.count
            }
        } catch {
            verseCount = 20
        }

        if let pending = pendingScrollVerse {
            currentVerse = min(max(pending, 1), max(verseCount, 1))
            pendingScrollVerse = nil
        } else {
            currentVerse = 1
        }

        isLoading = false
    }
}
