import Foundation

final class VocabBank {
    static let shared = VocabBank()

    private let bundledWords: [VocabWord]
    private var userWords: [VocabWord]
    private let userWordsFileURL: URL

    var allWords: [VocabWord] { bundledWords + userWords }

    private init() {
        bundledWords = Self.loadBundled()

        let supportDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        userWordsFileURL = supportDir.appendingPathComponent("user_vocabulary.json")

        userWords = Self.loadUserWords(from: userWordsFileURL)
    }

    private static func loadBundled() -> [VocabWord] {
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let words = try? JSONDecoder().decode([VocabWord].self, from: data) else {
            return []
        }
        return words
    }

    private static func loadUserWords(from url: URL) -> [VocabWord] {
        guard let data = try? Data(contentsOf: url),
              let words = try? JSONDecoder().decode([VocabWord].self, from: data) else {
            return []
        }
        return words
    }

    func words(of type: WordType?) -> [VocabWord] {
        guard let type else { return allWords }
        return allWords.filter { $0.wordType == type }
    }

    func count(of type: WordType?) -> Int {
        words(of: type).count
    }

    /// Yeni kelimeleri, terimi (büyük/küçük harf duyarsız) mevcut listelerin
    /// herhangi birinde zaten olanları atlayarak ekler.
    @discardableResult
    func addWords(_ newWords: [VocabWord]) -> (added: Int, duplicates: Int) {
        var seenTerms = Set(allWords.map { $0.term.lowercased() })
        var added = 0
        var duplicates = 0

        for word in newWords {
            let key = word.term.lowercased()
            guard !seenTerms.contains(key) else {
                duplicates += 1
                continue
            }
            seenTerms.insert(key)
            userWords.append(word)
            added += 1
        }

        if added > 0 {
            persistUserWords()
        }
        return (added, duplicates)
    }

    private func persistUserWords() {
        if let data = try? JSONEncoder().encode(userWords) {
            try? data.write(to: userWordsFileURL)
        }
    }
}
