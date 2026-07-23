import Foundation

enum QuestionCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case vocabulary = "Kelime ve Phrasal Verb"
    case grammar = "Gramer"
    case clozeTest = "Cloze Test"
    case sentenceCompletion = "Cümle Tamamlama"
    case translation = "Çeviri"
    case paragraph = "Paragraf"
    case dialogueCompletion = "Diyalog Tamamlama"
    case restatement = "Anlamca En Yakın Cümle"
    case paragraphCompletion = "Paragraf Tamamlama"
    case irrelevantSentence = "Anlam Bütünlüğünü Bozan Cümle"

    var id: String { rawValue }

    /// YÖKDİL'de diyalog tamamlama ve restatement soru tipleri yoktur.
    static func categories(for examType: ExamType) -> [QuestionCategory] {
        switch examType {
        case .yds:
            return allCases
        case .yokdil:
            return allCases.filter { $0 != .dialogueCompletion && $0 != .restatement }
        }
    }
}
