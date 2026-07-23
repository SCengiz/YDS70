import Foundation

enum StudyRoute: Hashable {
    case topicDetail(QuestionCategory)
    case practice(questions: [Question], title: String)
}
