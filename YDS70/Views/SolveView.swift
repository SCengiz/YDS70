import SwiftUI

struct SolveView: View {
    @State private var path = NavigationPath()
    @State private var isShowingImportSheet = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Button {
                    let exam = QuestionBank.shared.buildExam()
                    path.append(SolveRoute.exam(questions: exam, title: "Çıkmış Sınav Tarzı Deneme"))
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 46, height: 46)
                            .background(
                                LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Çıkmış Sınav Tarzı Deneme")
                                .font(.body.weight(.semibold))
                            Text("Gerçek sınav formatında, tam dağılımlı özgün deneme")
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

                Button {
                    let mixed = Array(QuestionBank.shared.allQuestions.shuffled().prefix(15))
                    path.append(SolveRoute.exam(questions: mixed, title: "Karma Öneri"))
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 46, height: 46)
                            .background(
                                LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Karma Öneri")
                                .font(.body.weight(.semibold))
                            Text("Karışık kategorilerden kısa pratik test")
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

                Button {
                    let custom = QuestionBank.shared.questions(category: .custom)
                    path.append(SolveRoute.exam(questions: custom, title: "Eklenen Sorular"))
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: CategoryStyle.icon(for: .custom))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 46, height: 46)
                            .background(CategoryStyle.color(for: .custom).gradient, in: RoundedRectangle(cornerRadius: 14))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Eklenen Sorular")
                                .font(.body.weight(.semibold))
                            Text("\(QuestionBank.shared.count(category: .custom)) soru · kendi eklediğin sorular")
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
                .disabled(QuestionBank.shared.count(category: .custom) == 0)
            }
            .navigationTitle("Çöz")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingImportSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingImportSheet) {
                QuestionImportView()
            }
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
