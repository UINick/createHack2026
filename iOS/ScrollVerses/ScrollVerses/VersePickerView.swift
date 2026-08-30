import SwiftUI

struct VersePickerView: View {
    let versionId: Int
    let initialBook: String
    let initialChapter: Int
    let onSelect: (String, Int, Int) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var step: Step = .book
    @State private var selectedBook: String
    @State private var currentChapterSelection: Int
    @State private var chapterCount: Int = 0
    @State private var verseCount: Int = 0
    @State private var isLoading = false

    private enum Step {
        case book, chapter, verse
    }

    init(versionId: Int, initialBook: String, initialChapter: Int, onSelect: @escaping (String, Int, Int) -> Void) {
        self.versionId = versionId
        self.initialBook = initialBook
        self.initialChapter = initialChapter
        self.onSelect = onSelect
        _selectedBook = State(initialValue: initialBook)
        _currentChapterSelection = State(initialValue: initialChapter)
    }

    var body: some View {
        VStack(spacing: 0) {
            handleBar
            header

            Rectangle()
                .fill(ZmodeTheme.border)
                .frame(height: 0.5)

            if isLoading {
                Spacer()
                ProgressView()
                    .tint(ZmodeTheme.accent)
                Spacer()
            } else {
                switch step {
                case .book:
                    bookList
                case .chapter:
                    numberGrid(count: chapterCount) { chapter in
                        selectChapter(chapter)
                    }
                case .verse:
                    numberGrid(count: verseCount) { verse in
                        onSelect(selectedBook, currentChapterSelection, verse)
                        dismiss()
                    }
                }
            }
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

    private var header: some View {
        HStack {
            if step != .book {
                Button {
                    withAnimation { goBack() }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(ZmodeTheme.accent)
                        .frame(width: 32, height: 32)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(stepLabel)
                    .font(.system(size: 9, weight: .regular))
                    .tracking(0.9)
                    .textCase(.uppercase)
                    .foregroundStyle(ZmodeTheme.accent)

                Text(stepTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ZmodeTheme.textPrimary)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
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

    private var stepLabel: String {
        switch step {
        case .book: return "Go to"
        case .chapter: return "Chapter"
        case .verse: return "Verse"
        }
    }

    private var stepTitle: String {
        switch step {
        case .book: return "Choose a book"
        case .chapter: return BibleBooks.name(for: selectedBook)
        case .verse: return "\(BibleBooks.name(for: selectedBook)) \(currentChapterSelection)"
        }
    }

    private var bookList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(BibleBooks.all) { book in
                    Button {
                        selectedBook = book.usfm
                        loadChapters()
                    } label: {
                        HStack {
                            Text(book.name)
                                .font(.system(size: 15))
                                .foregroundStyle(ZmodeTheme.textPrimary)
                            Spacer()
                            if book.usfm == selectedBook {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(ZmodeTheme.accent)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                    }

                    Rectangle()
                        .fill(ZmodeTheme.border)
                        .frame(height: 0.5)
                        .padding(.leading, 24)
                }
            }
        }
    }

    private func numberGrid(count: Int, onTap: @escaping (Int) -> Void) -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                ForEach(1...max(count, 1), id: \.self) { number in
                    Button {
                        onTap(number)
                    } label: {
                        Text("\(number)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(ZmodeTheme.textPrimary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(ZmodeTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(24)
        }
    }

    private func selectChapter(_ chapter: Int) {
        currentChapterSelection = chapter
        loadVerses(for: chapter)
    }

    private func goBack() {
        switch step {
        case .book:
            break
        case .chapter:
            step = .book
        case .verse:
            step = .chapter
        }
    }

    private func loadChapters() {
        isLoading = true
        Task {
            let url = URL(string: "https://api.youversion.com/v1/bibles/\(versionId)/books/\(selectedBook)/chapters")
            var count = 1
            if let url {
                var request = URLRequest(url: url)
                request.setValue("8nZ6ypn8l1PchS90c73izURRSBQXOrYjULXEXIobGE0GQ0Vu", forHTTPHeaderField: "X-YVP-App-Key")
                if let (data, _) = try? await URLSession.shared.data(for: request),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let chapters = json["data"] as? [[String: Any]] {
                    count = max(chapters.count, 1)
                }
            }
            await MainActor.run {
                chapterCount = count
                isLoading = false
                step = .chapter
            }
        }
    }

    private func loadVerses(for chapter: Int) {
        isLoading = true
        Task {
            let url = URL(string: "https://api.youversion.com/v1/bibles/\(versionId)/books/\(selectedBook)/chapters/\(chapter)/verses")
            var count = 1
            if let url {
                var request = URLRequest(url: url)
                request.setValue("8nZ6ypn8l1PchS90c73izURRSBQXOrYjULXEXIobGE0GQ0Vu", forHTTPHeaderField: "X-YVP-App-Key")
                if let (data, _) = try? await URLSession.shared.data(for: request),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let verses = json["data"] as? [[String: Any]] {
                    count = max(verses.count, 1)
                }
            }
            await MainActor.run {
                verseCount = count
                isLoading = false
                step = .verse
            }
        }
    }
}
