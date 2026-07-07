import Foundation

struct QuoteEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var source: String
    var page: String
    var tag: String
    var dateAdded: Date = Date()
}

struct AppSettings: Codable, Equatable {
    var categoryToggleOne: Bool = true
    var categoryToggleTwo: Bool = true
}
