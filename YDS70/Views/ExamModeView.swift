import SwiftUI

/// Gerçek sınav simülasyonu: cevaplar sınav bitene kadar gösterilmez,
/// tüm sorular cevaplandıktan/gözden geçirildikten sonra tek seferde sonuç verilir.
struct ExamModeView: View {
    let questions: [Question]
    let title: String
    let onFinishGoHome: () -> Void

    @State private var currentIndex = 0
    @State private var selections: [Int: Int] = [:]
    @State private var isSubmitted = false

    var body: some View {
        Group {
            if questions.isEmpty {
                ContentUnavailableView("Soru bulunamadı", systemImage: "tray")
            } else if isSubmitted {
                ExamReviewView(questions: questions, selections: selections, onFinishGoHome: onFinishGoHome)
            } else {
                examBody
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var currentQuestion: Question { questions[currentIndex] }

    private var examBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Soru \(currentIndex + 1)/\(questions.count) · \(currentQuestion.category.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let passage = currentQuestion.passage {
                    Text(passage)
                        .font(.callout)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }

                Text(currentQuestion.promptText)
                    .font(.body.weight(.medium))

                VStack(spacing: 12) {
                    ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                        optionButton(index: index, option: option)
                    }
                }

                HStack(spacing: 12) {
                    if currentIndex > 0 {
                        Button {
                            currentIndex -= 1
                        } label: {
                            Text("Önceki")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        if currentIndex == questions.count - 1 {
                            isSubmitted = true
                        } else {
                            currentIndex += 1
                        }
                    } label: {
                        Text(currentIndex == questions.count - 1 ? "Sınavı Bitir" : "Sonraki")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .id(currentQuestion.id)
    }

    private func optionButton(index: Int, option: String) -> some View {
        let isSelected = selections[currentIndex] == index
        return Button {
            selections[currentIndex] = index
        } label: {
            HStack {
                Text(option)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding()
            .background(
                isSelected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }
}
