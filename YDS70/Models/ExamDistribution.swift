import Foundation

enum ExamDistribution {
    /// Kategori başına soru sayısı, gerçek sınav dağılımına yakın oranlarda.
    static let yds: [QuestionCategory: Int] = [
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

    static let yokdil: [QuestionCategory: Int] = [
        .vocabulary: 6,
        .grammar: 10,
        .clozeTest: 10,
        .sentenceCompletion: 11,
        .translation: 12,
        .paragraph: 15,
        .paragraphCompletion: 6,
        .irrelevantSentence: 6
    ]

    static func distribution(for examType: ExamType) -> [QuestionCategory: Int] {
        switch examType {
        case .yds: return yds
        case .yokdil: return yokdil
        }
    }

    /// Dağılımdaki kategori sırasını korur (Paragraf gibi ağırlıklı kategoriler önce/sonra karışmasın diye kullanışlı).
    static func orderedCategories(for examType: ExamType) -> [QuestionCategory] {
        QuestionCategory.categories(for: examType)
    }
}
