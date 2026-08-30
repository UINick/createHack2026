import Foundation

struct BibleBook: Identifiable, Hashable {
    let usfm: String
    let name: String
    var id: String { usfm }
}

enum BibleBooks {
    static let all: [BibleBook] = [
        BibleBook(usfm: "GEN", name: "Genesis"),
        BibleBook(usfm: "EXO", name: "Exodus"),
        BibleBook(usfm: "LEV", name: "Leviticus"),
        BibleBook(usfm: "NUM", name: "Numbers"),
        BibleBook(usfm: "DEU", name: "Deuteronomy"),
        BibleBook(usfm: "JOS", name: "Joshua"),
        BibleBook(usfm: "JDG", name: "Judges"),
        BibleBook(usfm: "RUT", name: "Ruth"),
        BibleBook(usfm: "1SA", name: "1 Samuel"),
        BibleBook(usfm: "2SA", name: "2 Samuel"),
        BibleBook(usfm: "1KI", name: "1 Kings"),
        BibleBook(usfm: "2KI", name: "2 Kings"),
        BibleBook(usfm: "1CH", name: "1 Chronicles"),
        BibleBook(usfm: "2CH", name: "2 Chronicles"),
        BibleBook(usfm: "EZR", name: "Ezra"),
        BibleBook(usfm: "NEH", name: "Nehemiah"),
        BibleBook(usfm: "EST", name: "Esther"),
        BibleBook(usfm: "JOB", name: "Job"),
        BibleBook(usfm: "PSA", name: "Psalms"),
        BibleBook(usfm: "PRO", name: "Proverbs"),
        BibleBook(usfm: "ECC", name: "Ecclesiastes"),
        BibleBook(usfm: "SNG", name: "Song of Solomon"),
        BibleBook(usfm: "ISA", name: "Isaiah"),
        BibleBook(usfm: "JER", name: "Jeremiah"),
        BibleBook(usfm: "LAM", name: "Lamentations"),
        BibleBook(usfm: "EZK", name: "Ezekiel"),
        BibleBook(usfm: "DAN", name: "Daniel"),
        BibleBook(usfm: "HOS", name: "Hosea"),
        BibleBook(usfm: "JOL", name: "Joel"),
        BibleBook(usfm: "AMO", name: "Amos"),
        BibleBook(usfm: "OBA", name: "Obadiah"),
        BibleBook(usfm: "JON", name: "Jonah"),
        BibleBook(usfm: "MIC", name: "Micah"),
        BibleBook(usfm: "NAM", name: "Nahum"),
        BibleBook(usfm: "HAB", name: "Habakkuk"),
        BibleBook(usfm: "ZEP", name: "Zephaniah"),
        BibleBook(usfm: "HAG", name: "Haggai"),
        BibleBook(usfm: "ZEC", name: "Zechariah"),
        BibleBook(usfm: "MAL", name: "Malachi"),
        BibleBook(usfm: "MAT", name: "Matthew"),
        BibleBook(usfm: "MRK", name: "Mark"),
        BibleBook(usfm: "LUK", name: "Luke"),
        BibleBook(usfm: "JHN", name: "John"),
        BibleBook(usfm: "ACT", name: "Acts"),
        BibleBook(usfm: "ROM", name: "Romans"),
        BibleBook(usfm: "1CO", name: "1 Corinthians"),
        BibleBook(usfm: "2CO", name: "2 Corinthians"),
        BibleBook(usfm: "GAL", name: "Galatians"),
        BibleBook(usfm: "EPH", name: "Ephesians"),
        BibleBook(usfm: "PHP", name: "Philippians"),
        BibleBook(usfm: "COL", name: "Colossians"),
        BibleBook(usfm: "1TH", name: "1 Thessalonians"),
        BibleBook(usfm: "2TH", name: "2 Thessalonians"),
        BibleBook(usfm: "1TI", name: "1 Timothy"),
        BibleBook(usfm: "2TI", name: "2 Timothy"),
        BibleBook(usfm: "TIT", name: "Titus"),
        BibleBook(usfm: "PHM", name: "Philemon"),
        BibleBook(usfm: "HEB", name: "Hebrews"),
        BibleBook(usfm: "JAS", name: "James"),
        BibleBook(usfm: "1PE", name: "1 Peter"),
        BibleBook(usfm: "2PE", name: "2 Peter"),
        BibleBook(usfm: "1JN", name: "1 John"),
        BibleBook(usfm: "2JN", name: "2 John"),
        BibleBook(usfm: "3JN", name: "3 John"),
        BibleBook(usfm: "JUD", name: "Jude"),
        BibleBook(usfm: "REV", name: "Revelation"),
    ]

    private static let namesByUSFM: [String: String] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.usfm, $0.name) }
    )

    static func name(for usfm: String) -> String {
        namesByUSFM[usfm] ?? usfm
    }
}
