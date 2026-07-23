import Foundation

final class QuestionBank {
    static let shared = QuestionBank()

    let allQuestions: [Question]

    private init() {
        allQuestions = Self.loadQuestions(resource: "seed_questions") + Self.loadQuestions(resource: "real_questions")
    }

    private static func loadQuestions(resource: String) -> [Question] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questions = try? JSONDecoder().decode([Question].self, from: data) else {
            return []
        }
        return questions
    }

    func questions(category: QuestionCategory) -> [Question] {
        allQuestions.filter { $0.category == category }
    }

    func count(category: QuestionCategory) -> Int {
        questions(category: category).count
    }

    /// Gerçek sınav dağılımına göre karma bir deneme sınavı oluşturur.
    /// Bir kategoride yeterli soru yoksa mevcut olan tüm sorular kullanılır.
    func buildExam() -> [Question] {
        var exam: [Question] = []
        for category in QuestionCategory.allCases {
            guard let needed = QuestionDistribution.counts[category] else { continue }
            let pool = questions(category: category).shuffled()
            exam.append(contentsOf: pool.prefix(needed))
        }
        return exam
    }
}
