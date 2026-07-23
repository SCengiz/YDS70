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
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Karma Deneme Oluştur")
                                    .font(.body)
                                Text("Gerçek soru dağılımına göre karma test")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "doc.text.magnifyingglass")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Section("Konular") {
                    ForEach(QuestionCategory.allCases) { category in
                        let count = QuestionBank.shared.count(category: category)
                        Button {
                            path.append(StudyRoute.topicDetail(category))
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
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
