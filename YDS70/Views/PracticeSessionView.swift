import SwiftUI

struct PracticeSessionView: View {
    let questions: [Question]
    let title: String
    let onFinishGoHome: () -> Void

    @State private var currentIndex = 0
    @State private var selectedOption: Int? = nil
    @State private var isAnswerRevealed = false
    @State private var correctCount = 0
    @State private var categoryResults: [QuestionCategory: (correct: Int, total: Int)] = [:]
    @State private var isFinished = false

    var body: some View {
        Group {
            if questions.isEmpty {
                ContentUnavailableView("Bu başlıkta henüz soru yok", systemImage: "tray")
            } else if isFinished {
                ResultView(
                    correctCount: correctCount,
                    total: questions.count,
                    categoryResults: categoryResults,
                    title: title,
                    onFinishGoHome: onFinishGoHome
                )
            } else {
                quizBody
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isFinished)
    }

    private var currentQuestion: Question { questions[currentIndex] }

    private var quizBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Soru \(currentIndex + 1)/\(questions.count) · \(currentQuestion.category.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let passage = currentQuestion.passage {
                    TranslatableText(text: passage, font: .callout)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }

                TranslatableText(text: currentQuestion.promptText, font: .body.weight(.medium))

                VStack(spacing: 12) {
                    ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                        optionButton(index: index, option: option)
                    }
                }

                if isAnswerRevealed, let explanation = currentQuestion.explanation {
                    Text(explanation)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }

                Button(action: advance) {
                    Text(isAnswerRevealed ? (currentIndex == questions.count - 1 ? "Sonucu Gör" : "Sonraki Soru") : "Cevabı Onayla")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedOption == nil ? Color.gray.opacity(0.3) : Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedOption == nil)
            }
            .padding()
        }
        .id(currentQuestion.id)
    }

    private func optionButton(index: Int, option: String) -> some View {
        let isSelected = selectedOption == index
        let isCorrect = index == currentQuestion.correctIndex

        let backgroundColor: Color = {
            guard isAnswerRevealed else {
                return isSelected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground)
            }
            if isCorrect { return Color.green.opacity(0.25) }
            if isSelected { return Color.red.opacity(0.25) }
            return Color(.secondarySystemBackground)
        }()

        return Button {
            guard !isAnswerRevealed else { return }
            selectedOption = index
        } label: {
            HStack {
                Text(option)
                Spacer()
                if isAnswerRevealed && isCorrect {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if isAnswerRevealed && isSelected {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                }
            }
            .padding()
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .disabled(isAnswerRevealed)
    }

    private func advance() {
        if !isAnswerRevealed {
            isAnswerRevealed = true
            var entry = categoryResults[currentQuestion.category] ?? (correct: 0, total: 0)
            entry.total += 1
            if selectedOption == currentQuestion.correctIndex {
                entry.correct += 1
                correctCount += 1
            }
            categoryResults[currentQuestion.category] = entry
            return
        }

        if currentIndex == questions.count - 1 {
            isFinished = true
        } else {
            currentIndex += 1
            selectedOption = nil
            isAnswerRevealed = false
        }
    }
}
