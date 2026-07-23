import Foundation

enum VocabRoute: Hashable {
    case vocabPractice(words: [VocabWord], title: String)
    case masteredWords
}
