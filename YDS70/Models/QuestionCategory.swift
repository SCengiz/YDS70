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
    /// Kullanıcının Çöz sekmesinden kendi yüklediği sorular. Çalış'taki konu
    /// listesinde ve dağılıma dayalı Karma Deneme'de görünmez.
    case custom = "Eklenen Sorular"

    var id: String { rawValue }
}
