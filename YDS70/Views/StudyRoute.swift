import Foundation

enum StudyRoute: Hashable {
    case topicDetail(QuestionCategory)
    case practice(questions: [Question], title: String)
    /// Uygulamayla gelen PDF konu anlatımı (uzantısız dosya adı + başlık).
    case document(resource: String, title: String)
}
