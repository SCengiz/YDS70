import SwiftUI

struct HomeView: View {
    @State private var path = NavigationPath()
    @State private var selectedExamType: ExamType = .yds

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 24) {
                Picker("Sınav Türü", selection: $selectedExamType) {
                    ForEach(ExamType.allCases) { exam in
                        Text(exam.rawValue).tag(exam)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                VStack(spacing: 16) {
                    Button {
                        path.append(Route.topicList(selectedExamType))
                    } label: {
                        HomeMenuCard(
                            title: "Konu Bazlı Çalış",
                            subtitle: "Bir başlık seç, o başlıktan sorular çöz",
                            systemImage: "list.bullet.rectangle"
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        let exam = QuestionBank.shared.buildExam(for: selectedExamType)
                        path.append(Route.practice(questions: exam, title: "\(selectedExamType.rawValue) Deneme Sınavı"))
                    } label: {
                        HomeMenuCard(
                            title: "Deneme Sınavı Oluştur",
                            subtitle: "Gerçek soru dağılımına göre karma test",
                            systemImage: "doc.text.magnifyingglass"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle("YDS70")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .topicList(let examType):
                    TopicListView(examType: examType, path: $path)
                case .practice(let questions, let title):
                    PracticeSessionView(questions: questions, title: title) {
                        path = NavigationPath()
                    }
                }
            }
        }
    }
}

private struct HomeMenuCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .foregroundStyle(.primary)
    }
}

#Preview {
    HomeView()
}
