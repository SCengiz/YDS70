import Foundation

enum WordType: String, Codable, CaseIterable, Identifiable, Hashable {
    case verb
    case phrasalVerb
    case adjective
    case conjunction
    case preposition

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .verb: return "Fiil"
        case .phrasalVerb: return "Phrasal Verb"
        case .adjective: return "Sıfat"
        case .conjunction: return "Bağlaç"
        case .preposition: return "Preposition (Edat)"
        }
    }
}

struct VocabWord: Codable, Identifiable, Hashable {
    let id: String
    let term: String
    let meaning: String
    let wordType: WordType
}
