import SwiftUI

struct ExamReviewView: View {
    let questions: [Question]
    let selections: [Int: Int]
    let onFinishGoHome: () -> Void

    private var correctCount: Int {
        questions.indices.filter { selections[$0] == questions[$0].correctIndex }.count
    }

    private var percentage: Double {
        questions.isEmpty ? 0 : Double(correctCount) / Double(questions.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color(.secondarySystemBackground), lineWidth: 14)
                    Circle()
                        .trim(from: 0, to: percentage)
                        .stroke(
                            LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text("\(correctCount)/\(questions.count)")
                            .font(.system(size: 34, weight: .bold))
                        Text("Doğru Cevap")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 160, height: 160)
                .padding(.top, 32)

                VStack(spacing: 16) {
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        reviewCard(index: index, question: question)
                    }
                }
                .padding(.horizontal)

                Button(action: onFinishGoHome) {
                    Text("Ana Sayfaya Dön")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Sonuç")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func reviewCard(index: Int, question: Question) -> some View {
        let selected = selections[index]
        let isCorrect = selected == question.correctIndex
        return VStack(alignment: .leading, spacing: 8) {
            Label("Soru \(index + 1) · \(question.category.rawValue)", systemImage: CategoryStyle.icon(for: question.category))
                .font(.caption)
                .foregroundStyle(CategoryStyle.color(for: question.category))
            Text(question.promptText)
                .font(.subheadline)
            if let selected {
                Text("Cevabın: \(question.options[selected])")
                    .font(.caption)
                    .foregroundStyle(isCorrect ? .green : .red)
            } else {
                Text("Boş bırakıldı")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            if !isCorrect {
                Text("Doğru cevap: \(question.options[question.correctIndex])")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            if let explanation = question.explanation {
                Text(explanation)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
