import SwiftUI

struct SolveView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Button {
                    let exam = QuestionBank.shared.buildExam()
                    path.append(SolveRoute.exam(questions: exam, title: "Çıkmış Sınav Tarzı Deneme"))
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Çıkmış Sınav Tarzı Deneme")
                                .font(.body)
                            Text("Gerçek sınav formatında, tam dağılımlı özgün deneme")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    let mixed = Array(QuestionBank.shared.allQuestions.shuffled().prefix(15))
                    path.append(SolveRoute.exam(questions: mixed, title: "Karma Öneri"))
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Karma Öneri")
                                .font(.body)
                            Text("Karışık kategorilerden kısa pratik test")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "shuffle")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Çöz")
            .navigationDestination(for: SolveRoute.self) { route in
                switch route {
                case .exam(let questions, let title):
                    ExamModeView(questions: questions, title: title) {
                        path = NavigationPath()
                    }
                }
            }
        }
    }
}
