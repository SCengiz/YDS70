import Foundation

enum ExamType: String, Codable, CaseIterable, Identifiable, Hashable {
    case yds = "YDS"
    case yokdil = "YÖKDİL"

    var id: String { rawValue }
}
