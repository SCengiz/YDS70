import SwiftUI

struct TopicListView: View {
    let examType: ExamType
    @Binding var path: NavigationPath

    var body: some View {
        List {
            ForEach(QuestionCategory.categories(for: examType)) { category in
                let count = QuestionBank.shared.count(category: category, examType: examType)
                Button {
                    let questions = QuestionBank.shared.questions(category: category, examType: examType).shuffled()
                    path.append(Route.practice(questions: questions, title: category.rawValue))
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.rawValue)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text("\(count) soru")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if count > 0 {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(count == 0)
            }
        }
        .navigationTitle("\(examType.rawValue) Konuları")
        .navigationBarTitleDisplayMode(.inline)
    }
}
