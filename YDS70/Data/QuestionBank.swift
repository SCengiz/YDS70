import Foundation

final class QuestionBank {
    static let shared = QuestionBank()

    let allQuestions: [Question]

    private init() {
        guard let url = Bundle.main.url(forResource: "seed_questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questions = try? JSONDecoder().decode([Question].self, from: data) else {
            allQuestions = []
            return
        }
        allQuestions = questions
    }

    func questions(category: QuestionCategory, examType: ExamType) -> [Question] {
        allQuestions.filter { $0.category == category && $0.examType.matches(examType) }
    }

    func count(category: QuestionCategory, examType: ExamType) -> Int {
        questions(category: category, examType: examType).count
    }

    /// Gerçek sınav dağılımına göre karma bir deneme sınavı oluşturur.
    /// Bir kategoride yeterli soru yoksa mevcut olan tüm sorular kullanılır.
    func buildExam(for examType: ExamType) -> [Question] {
        var exam: [Question] = []
        let distribution = ExamDistribution.distribution(for: examType)
        for category in ExamDistribution.orderedCategories(for: examType) {
            guard let needed = distribution[category] else { continue }
            let pool = questions(category: category, examType: examType).shuffled()
            exam.append(contentsOf: pool.prefix(needed))
        }
        return exam
    }
}
