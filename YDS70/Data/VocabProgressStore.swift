import Foundation

/// Bir kelime, doğru cevaplanma sayacı eşiğe ulaşınca "ezberlenmiş" sayılır
/// ve pratik havuzundan çıkarılır. Yanlış cevaplanınca sayaç bir azalır.
/// Kullanıcı ayrıca bir kelimeyi listeden kalıcı olarak çıkarabilir.
final class VocabProgressStore {
    static let shared = VocabProgressStore()
    static let masteryThreshold = 5

    private let countsKey = "yds70.vocabCorrectCounts"
    private let removedKey = "yds70.removedWordIDs"

    private var correctCounts: [String: Int]
    private var removedIDs: Set<String>

    private init() {
        correctCounts = UserDefaults.standard.dictionary(forKey: countsKey) as? [String: Int] ?? [:]
        removedIDs = Set(UserDefaults.standard.stringArray(forKey: removedKey) ?? [])
    }

    // MARK: - Mastery

    func correctCount(for id: String) -> Int {
        correctCounts[id] ?? 0
    }

    func isMastered(_ id: String) -> Bool {
        correctCount(for: id) >= Self.masteryThreshold
    }

    func registerCorrectAnswer(for id: String) {
        let current = correctCounts[id] ?? 0
        guard current < Self.masteryThreshold else { return }
        correctCounts[id] = current + 1
        persistCounts()
    }

    /// Yanlış cevapta sayacı bir azaltır (sıfırın altına inmez).
    func registerWrongAnswer(for id: String) {
        let current = correctCounts[id] ?? 0
        guard current > 0 else { return }
        correctCounts[id] = current - 1
        persistCounts()
    }

    func masteredCount(among words: [VocabWord]) -> Int {
        words.filter { isMastered($0.id) }.count
    }

    // MARK: - Removed words

    func isRemoved(_ id: String) -> Bool {
        removedIDs.contains(id)
    }

    func removeWord(_ id: String) {
        removedIDs.insert(id)
        persistRemoved()
    }

    func restoreWord(_ id: String) {
        removedIDs.remove(id)
        persistRemoved()
    }

    var removedWordCount: Int { removedIDs.count }

    // MARK: - Persistence

    private func persistCounts() {
        UserDefaults.standard.set(correctCounts, forKey: countsKey)
    }

    private func persistRemoved() {
        UserDefaults.standard.set(Array(removedIDs), forKey: removedKey)
    }
}
