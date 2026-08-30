import Foundation
import Supabase

enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://yllrfrejlhinwtambpmr.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlsbHJmcmVqbGhpbnd0YW1icG1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgwNDczNTMsImV4cCI6MjEwMzYyMzM1M30.w8l68aGIHKHtT87eQl19fGDVWHU1-0aqpE19kTwIVss"
    )
}
