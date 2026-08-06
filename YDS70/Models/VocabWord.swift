import Foundation

// Not: `allCases` bildirim sırasını izler ve Ezberle listesinin sırasını belirler.
// Tür String tabanlı olduğundan sırayı değiştirmek kayıtlı ilerlemeyi etkilemez.
enum WordType: String, Codable, CaseIterable, Identifiable, Hashable {
    case noun
    case verb
    case adjective
    case phrasalVerb
    case conjunction
    case preposition
    case adverb
    case general

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .verb: return "Fiil"
        case .phrasalVerb: return "Phrasal Verb"
        case .adjective: return "Sıfat"
        case .conjunction: return "Bağlaç"
        case .preposition: return "Preposition (Edat)"
        case .noun: return "İsim"
        case .adverb: return "Zarf"
        case .general: return "YDS'de En Çok Çıkanlar"
        }
    }
}

struct VocabWord: Codable, Identifiable, Hashable {
    let id: String
    let term: String
    let meaning: String
    let wordType: WordType
    /// İngilizce eş anlamlılar. Her kelime listesinde bulunmaz; eş anlamlı
    /// modu yalnızca bu alanı dolu olan kelimeler için kullanılabilir.
    var synonyms: [String]?
}
