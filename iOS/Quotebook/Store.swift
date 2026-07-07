import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [QuoteEntry] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var isPro: Bool = false

    /// Free tier allows up to this many entries. Deliberately set well above
    /// the seed data count so a fresh install never trips the paywall.
    static let freeLimit = 14

    private let entriesFileName = "entries.json"
    private let settingsFileName = "settings.json"

    init() {
        load()
        if entries.isEmpty {
            seed()
            save()
        }
    }

    private var supportDirectory: URL {
        let fm = FileManager.default
        let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Quotebook", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private func seed() {
        entries = [
            QuoteEntry(name: "Not all those who wander are lost.", source: "The Fellowship of the Ring", page: "p.183", tag: "travel"),
            QuoteEntry(name: "It was the best of times, it was the worst of times.", source: "A Tale of Two Cities", page: "p.1", tag: "opening")
        ]
    }

    func load() {
        let entriesURL = supportDirectory.appendingPathComponent(entriesFileName)
        if let data = try? Data(contentsOf: entriesURL),
           let decoded = try? JSONDecoder().decode([QuoteEntry].self, from: data) {
            entries = decoded
        }
        let settingsURL = supportDirectory.appendingPathComponent(settingsFileName)
        if let data = try? Data(contentsOf: settingsURL),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }

    func save() {
        let entriesURL = supportDirectory.appendingPathComponent(entriesFileName)
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: entriesURL)
        }
        let settingsURL = supportDirectory.appendingPathComponent(settingsFileName)
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: settingsURL)
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    @discardableResult
    func add(name: String, f1: String, f2: String, f3: String) -> Bool {
        guard canAddMore else { return false }
        let entry = QuoteEntry(name: name, source: f1, page: f2, tag: f3)
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: QuoteEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: QuoteEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
}
