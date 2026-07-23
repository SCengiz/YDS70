import Foundation

enum Route: Hashable {
    case topicList(ExamType)
    case practice(questions: [Question], title: String)
}
