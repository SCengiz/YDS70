import Foundation

enum QuestionExamTag: String, Codable, Hashable {
    case yds = "YDS"
    case yokdil = "YOKDIL"
    case both = "both"

    func matches(_ examType: ExamType) -> Bool {
        switch self {
        case .both: return true
        case .yds: return examType == .yds
        case .yokdil: return examType == .yokdil
        }
    }
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
