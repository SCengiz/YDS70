import SwiftUI

struct TopicDetailView: View {
    let category: QuestionCategory
    @Binding var path: NavigationPath

    private var content: TopicContent { TopicContent.content(for: category) }
    private var questionCount: Int { QuestionBank.shared.count(category: category) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Konu Anlatımı")
                        .font(.headline)
                    Text(content.explanation)
                        .font(.body)
                }

                if !content.tips.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Taktikler")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(content.tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                    Text(tip)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                }

                Button {
                    let questions = QuestionBank.shared.questions(category: category).shuffled()
                    path.append(StudyRoute.practice(questions: questions, title: category.rawValue))
                } label: {
                    Text("Örnek Sorularla Pratik Yap (\(questionCount))")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(questionCount == 0 ? Color.gray.opacity(0.3) : Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(questionCount == 0)
            }
            .padding()
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}
