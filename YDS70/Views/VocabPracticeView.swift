import SwiftUI

/// Çoktan seçmeli kelime ezberleme: rastgele bir kelime ve 4 anlam seçeneği gösterir.
/// Bir kelime 20 kez doğru cevaplanınca ezberlenmiş sayılır ve havuzdan çıkar.
struct VocabPracticeView: View {
    let words: [VocabWord]
    let title: String

    @State private var currentWord: VocabWord?
    @State private var options: [VocabWord] = []
    @State private var selectedIndex: Int?
    @State private var isAnswerRevealed = false
    @State private var isPoolExhausted = false

    var body: some View {
        Group {
            if words.isEmpty {
                ContentUnavailableView("Bu kategoride henüz kelime yok", systemImage: "text.book.closed")
            } else if isPoolExhausted {
                finishedView
            } else if let currentWord {
                quizBody(for: currentWord)
            } else {
                Color.clear
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if currentWord == nil && !isPoolExhausted {
                pickNextWord()
            }
        }
    }

    private var remainingPool: [VocabWord] {
        words.filter { !VocabProgressStore.shared.isMastered($0.id) }
    }

    private var masteredCount: Int {
        words.count - remainingPool.count
    }

    private func pickNextWord() {
        guard let next = remainingPool.randomElement() else {
            currentWord = nil
            isPoolExhausted = true
            return
        }
        currentWord = next
        options = makeOptions(for: next)
        selectedIndex = nil
        isAnswerRevealed = false
    }

    private func makeOptions(for word: VocabWord) -> [VocabWord] {
        var distractorPool = words.filter { $0.id != word.id && $0.wordType == word.wordType }
        if distractorPool.count < 3 {
            distractorPool = words.filter { $0.id != word.id }
        }
        let distractors = Array(distractorPool.shuffled().prefix(3))
        return ([word] + distractors).shuffled()
    }

    private func quizBody(for word: VocabWord) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("\(masteredCount)/\(words.count) ezberlendi")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 16)

                Text(word.term)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                        optionButton(index: index, option: option, correctID: word.id)
                    }
                }
                .padding(.horizontal)

                if isAnswerRevealed {
                    Button {
                        pickNextWord()
                    } label: {
                        Text("Sonraki Kelime")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 24)
        }
        .id(word.id)
    }

    private func optionButton(index: Int, option: VocabWord, correctID: String) -> some View {
        let isSelected = selectedIndex == index
        let isCorrectOption = option.id == correctID

        let backgroundColor: Color = {
            guard isAnswerRevealed else {
                return Color(.secondarySystemBackground)
            }
            if isCorrectOption { return Color.green.opacity(0.25) }
            if isSelected { return Color.red.opacity(0.25) }
            return Color(.secondarySystemBackground)
        }()

        return Button {
            guard !isAnswerRevealed else { return }
            selectedIndex = index
            isAnswerRevealed = true
            if isCorrectOption {
                VocabProgressStore.shared.registerCorrectAnswer(for: correctID)
            }
        } label: {
            HStack {
                Text(option.meaning)
                Spacer()
                if isAnswerRevealed && isCorrectOption {
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

    private var finishedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("Tebrikler!")
                .font(.title2.bold())
            Text("Bu kategorideki tüm kelimeleri ezberledin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
        .padding(.top, 64)
    }
}
