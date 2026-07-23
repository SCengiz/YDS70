import Foundation

final class VocabBank {
    static let shared = VocabBank()

    let allWords: [VocabWord]

    private init() {
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let words = try? JSONDecoder().decode([VocabWord].self, from: data) else {
            allWords = []
            return
        }
        allWords = words
    }

    func words(of type: WordType?) -> [VocabWord] {
        guard let type else { return allWords }
        return allWords.filter { $0.wordType == type }
    }

    func count(of type: WordType?) -> Int {
        words(of: type).count
    }
}
