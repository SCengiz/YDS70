import Foundation

final class QuestionBank {
    static let shared = QuestionBank()

    private let bundledQuestions: [Question]
    private var userQuestions: [Question]
    private let userQuestionsFileURL: URL

    var allQuestions: [Question] { bundledQuestions + userQuestions }

    private init() {
        bundledQuestions = Self.loadQuestions(resource: "seed_questions") + Self.loadQuestions(resource: "real_questions")

        let supportDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        userQuestionsFileURL = supportDir.appendingPathComponent("user_questions.json")

        if let data = try? Data(contentsOf: userQuestionsFileURL),
           let questions = try? JSONDecoder().decode([Question].self, from: data) {
            userQuestions = questions
        } else {
            userQuestions = []
        }
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

    @discardableResult
    func addUserQuestions(_ newQuestions: [Question]) -> Int {
        userQuestions.append(contentsOf: newQuestions)
        if let data = try? JSONEncoder().encode(userQuestions) {
            try? data.write(to: userQuestionsFileURL)
        }
        return newQuestions.count
    }
}
