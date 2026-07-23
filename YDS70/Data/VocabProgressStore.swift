import Foundation

final class VocabProgressStore {
    static let shared = VocabProgressStore()

    private let key = "yds70.knownWordIDs"
    private var knownIDs: Set<String>

    private init() {
        knownIDs = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
    }

    func isKnown(_ id: String) -> Bool {
        knownIDs.contains(id)
    }

    func markKnown(_ id: String) {
        knownIDs.insert(id)
        persist()
    }

    func markUnknown(_ id: String) {
        knownIDs.remove(id)
        persist()
    }

    func knownCount(among words: [VocabWord]) -> Int {
        words.filter { knownIDs.contains($0.id) }.count
    }

    private func persist() {
        UserDefaults.standard.set(Array(knownIDs), forKey: key)
    }
}
