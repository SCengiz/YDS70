import Foundation

enum QuestionDistribution {
    /// Kategori başına soru sayısı, gerçek YDS/YÖKDİL sınav dağılımına yakın oranlarda.
    /// Uygulama artık YDS/YÖKDİL ayrımı yapmadığı için tek, birleşik bir dağılım kullanılır.
    static let counts: [QuestionCategory: Int] = [
        .vocabulary: 6,
        .grammar: 10,
        .clozeTest: 10,
        .sentenceCompletion: 8,
        .translation: 6,
        .paragraph: 20,
        .dialogueCompletion: 5,
        .restatement: 4,
        .paragraphCompletion: 4,
        .irrelevantSentence: 5
    ]
}
