import Foundation

/// Sorunun kaynak sınavı (yalnızca bilgi amaçlı; uygulama artık YDS/YÖKDİL ayrımı yapmıyor).
enum QuestionExamTag: String, Codable, Hashable {
    case yds = "YDS"
    case yokdil = "YOKDIL"
    case both = "both"
}

struct Question: Codable, Identifiable, Hashable {
    let id: String
    let examType: QuestionExamTag
    let category: QuestionCategory
    let passage: String?
    let promptText: String
    let options: [String]
    let correctIndex: Int
    let explanation: String?
    let sourceNote: String?
}
