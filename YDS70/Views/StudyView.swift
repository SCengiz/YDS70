import SwiftUI

struct StudyView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    Button {
                        let exam = QuestionBank.shared.buildExam()
                        path.append(StudyRoute.practice(questions: exam, title: "Karma Deneme"))
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 46, height: 46)
                                .background(
                                    LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 14)
                                )
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Karma Deneme Oluştur")
                                    .font(.body.weight(.semibold))
                                Text("Gerçek soru dağılımına göre karma test")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }

                Section("Konular") {
                    ForEach(QuestionCategory.allCases) { category in
                        let count = QuestionBank.shared.count(category: category)
                        let color = CategoryStyle.color(for: category)
                        Button {
                            path.append(StudyRoute.topicDetail(category))
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: CategoryStyle.icon(for: category))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(color)
                                    .frame(width: 36, height: 36)
                                    .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(category.rawValue)
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(.primary)
                                    Text("\(count) soru")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Çalış")
            .navigationDestination(for: StudyRoute.self) { route in
                switch route {
                case .topicDetail(let category):
                    TopicDetailView(category: category, path: $path)
                case .practice(let questions, let title):
                    PracticeSessionView(questions: questions, title: title) {
                        path = NavigationPath()
                    }
                }
            }
        }
    }
}
