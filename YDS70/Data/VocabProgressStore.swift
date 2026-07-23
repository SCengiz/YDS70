import Foundation

/// Bir kelime, doğru cevaplanma sayısı eşiğe ulaşınca "ezberlenmiş" sayılır
/// ve pratik havuzundan çıkarılır.
final class VocabProgressStore {
    static let shared = VocabProgressStore()
    static let masteryThreshold = 20

    private let key = "yds70.vocabCorrectCounts"
    private var correctCounts: [String: Int]

    private init() {
        correctCounts = UserDefaults.standard.dictionary(forKey: key) as? [String: Int] ?? [:]
    }

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
        persist()
    }

    func masteredCount(among words: [VocabWord]) -> Int {
        words.filter { isMastered($0.id) }.count
    }

    private func persist() {
        UserDefaults.standard.set(correctCounts, forKey: key)
    }
}
