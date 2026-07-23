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
}
