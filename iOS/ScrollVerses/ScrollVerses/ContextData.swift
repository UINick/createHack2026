import Combine
import Foundation
import Supabase

struct ContextSection: Identifiable, Decodable {
    let id: UUID
    let label: String
    let title: String?
    let body: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, label, title, body
        case sortOrder = "sort_order"
    }
}

struct ChapterContext: Identifiable, Decodable {
    let id: UUID
    let bookUSFM: String
    let chapter: Int
    let verseRange: String
    let summaryTitle: String
    let summary: String
    var sections: [ContextSection]

    enum CodingKeys: String, CodingKey {
        case id
        case bookUSFM = "book_usfm"
        case chapter
        case verseRange = "verse_range"
        case summaryTitle = "summary_title"
        case summary
        case sections = "context_sections"
    }

    var referenceDisplay: String {
        let names: [String: String] = [
            "GEN": "Genesis", "EXO": "Exodus", "MAT": "Matthew",
            "MRK": "Mark", "LUK": "Luke", "JHN": "John",
            "ACT": "Acts", "ROM": "Romans", "PSA": "Psalms",
            "PRO": "Proverbs", "REV": "Revelation",
            "1CO": "1 Corinthians", "2CO": "2 Corinthians",
            "GAL": "Galatians", "EPH": "Ephesians",
            "PHP": "Philippians", "COL": "Colossians"
        ]
        let book = names[bookUSFM] ?? bookUSFM
        return "\(book) \(verseRange)"
    }
}

private struct GenerateContextRequest: Encodable {
    let bookUSFM: String
    let chapter: Int

    enum CodingKeys: String, CodingKey {
        case bookUSFM = "book_usfm"
        case chapter
    }
}

enum ContextProviderError: Error {
    case rateLimited
    case invalidChapter
    case generationFailed
    case moderationFlagged
    case unknown
}

@MainActor
final class ContextProvider: ObservableObject {
    @Published var currentContext: ChapterContext?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cache: [String: ChapterContext] = [:]

    /// Loads context for a chapter. Tries the local cache first, then the
    /// database (previously generated contexts), and finally falls back to
    /// asking the `generate-context` Edge Function to create one on-demand
    /// using OpenAI, guarded by the guardrails enforced server-side.
    func loadContext(for bookUSFM: String, chapter: Int) async {
        let key = "\(bookUSFM).\(chapter)"

        if let cached = cache[key] {
            currentContext = cached
            errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let context = try await fetchOrGenerateContext(bookUSFM: bookUSFM, chapter: chapter)
            cache[key] = context
            currentContext = context
        } catch ContextProviderError.rateLimited {
            errorMessage = "Too many requests right now. Please try again in a moment."
            currentContext = nil
        } catch ContextProviderError.invalidChapter {
            errorMessage = "This chapter reference could not be verified."
            currentContext = nil
        } catch ContextProviderError.moderationFlagged {
            errorMessage = "Context could not be generated for this passage."
            currentContext = nil
        } catch {
            errorMessage = "Couldn't load context for this chapter."
            currentContext = nil
        }
    }

    private func fetchOrGenerateContext(bookUSFM: String, chapter: Int) async throws -> ChapterContext {
        // 1. Check the database directly first (fast path, no function invocation).
        let existing: [ChapterContext] = try await SupabaseManager.client
            .from("chapter_contexts")
            .select("*, context_sections(*)")
            .eq("book_usfm", value: bookUSFM)
            .eq("chapter", value: chapter)
            .execute()
            .value

        if var found = existing.first {
            found.sections.sort { $0.sortOrder < $1.sortOrder }
            return found
        }

        // 2. Not cached yet — ask the guarded Edge Function to generate it with AI.
        return try await generateContext(bookUSFM: bookUSFM, chapter: chapter)
    }

    private func generateContext(bookUSFM: String, chapter: Int) async throws -> ChapterContext {
        do {
            var response = try await SupabaseManager.client.functions
                .invoke(
                    "generate-context",
                    options: FunctionInvokeOptions(
                        body: GenerateContextRequest(bookUSFM: bookUSFM, chapter: chapter)
                    )
                ) as ChapterContext

            response.sections.sort { $0.sortOrder < $1.sortOrder }
            return response
        } catch {
            throw mapFunctionError(error)
        }
    }

    private func mapFunctionError(_ error: Error) -> ContextProviderError {
        let description = error.localizedDescription.lowercased()
        if description.contains("rate_limited") {
            return .rateLimited
        }
        if description.contains("invalid_chapter") || description.contains("chapter_out_of_range") || description.contains("invalid_book") {
            return .invalidChapter
        }
        if description.contains("moderation_flagged") || description.contains("guardrail_violation") {
            return .moderationFlagged
        }
        return .generationFailed
    }
}
